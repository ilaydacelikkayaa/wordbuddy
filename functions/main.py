from firebase_functions import https_fn
from firebase_admin import initialize_app, firestore
from datetime import datetime
import json
import random

initialize_app()
db = firestore.client()

def convert_dates_to_iso(data):
    if isinstance(data, dict):
        new_data = {}
        for key, value in data.items():
            if isinstance(value, datetime):
                new_data[key] = value.isoformat()
            elif isinstance(value, (dict, list)):
                new_data[key] = convert_dates_to_iso(value)
            else:
                new_data[key] = value
        return new_data
    elif isinstance(data, list):
        return [convert_dates_to_iso(item) for item in data]
    else:
        return data

@https_fn.on_request()
def set_user_level(request: https_fn.Request) -> https_fn.Response:
    if request.method != "POST":
        return https_fn.Response("Hata: Sadece POST metodu kabul edilir.", status=405)

    try:
        request_json = request.get_json()
        user_id = request_json.get("userId") if request_json else None
        new_level = request_json.get("level") if request_json else None

        if not user_id or not new_level:
            return https_fn.Response(
                json.dumps({"status": "error", "message": "Hata: userId ve level parametreleri gerekli."}),
                status=400,
                mimetype="application/json",
            )

        user_ref = db.collection("users").document(user_id)
        user_ref.set(
            {"currentLevel": new_level, "lastUpdated": firestore.SERVER_TIMESTAMP},
            merge=True,
        )

        return https_fn.Response(
            json.dumps({"status": "success", "message": f"Seviye {new_level} olarak ayarlandı."}),
            status=200,
            mimetype="application/json",
        )
    except Exception as e:
        return https_fn.Response(json.dumps({"status": "error", "message": str(e)}), status=500, mimetype="application/json")

@https_fn.on_request()
def get_daily_lesson(request: https_fn.Request) -> https_fn.Response:
    if request.method != "GET":
        return https_fn.Response("Hata: Sadece GET metodu kabul edilir.", status=405)

    try:
        user_id = request.args.get("userId")
        current_level = request.args.get("level", "A1")
        lesson_size = int(request.args.get("lessonSize", "10"))


        if not user_id:
            return https_fn.Response(json.dumps({"status": "error", "message": "userId parametresi gerekli."}), status=400, mimetype="application/json")
        
        all_words_query = db.collection("words").where("level", "==", current_level).stream()
        all_words = {doc.id: doc.to_dict() for doc in all_words_query}
        
        if not all_words:
            return https_fn.Response(json.dumps({"status": "success", "words": [], "isLevelCompleted": True}), status=200, mimetype="application/json")
    
        learned_query = db.collection("userReviews").where("userId", "==", user_id).where("isLearned", "==", True).stream()
        learned_word_ids = {r.to_dict().get("wordId") for r in learned_query if r.to_dict().get("wordId") in all_words}
        unlearned_ids = [wid for wid in all_words.keys() if wid not in learned_word_ids]
        if not unlearned_ids:
            return https_fn.Response(
                json.dumps({"status": "success", "words": [], "isLevelCompleted": True}),
                status=200,
                mimetype="application/json"
            )
        picked_ids = random.sample(unlearned_ids, k=min(lesson_size, len(unlearned_ids)))



        words_data = []
        for word_id in picked_ids:
            temp_word = all_words[word_id].copy()
            temp_word["id"] = word_id
            temp_word["isLearned"] = False
            words_data.append(temp_word)


        is_level_completed = len(learned_word_ids) >= len(all_words)
        random.shuffle(words_data)
        cleaned_data = convert_dates_to_iso(words_data)
        
        return https_fn.Response(
            json.dumps({
                "status": "success",
                "words": cleaned_data,
                "isLevelCompleted": is_level_completed
            }),
            status=200,
            mimetype="application/json"
        )
    except Exception as e:
        return https_fn.Response(json.dumps({"status": "error", "message": str(e)}), status=500, mimetype="application/json")

@https_fn.on_request()
def process_review(request: https_fn.Request) -> https_fn.Response:
    if request.method != "POST":
        return https_fn.Response("Hata: Sadece POST metodu kabul edilir.", status=405)

    try:
        request_json = request.get_json()
        user_id = request_json.get("userId")
        word_id = request_json.get("wordId")
        learned = request_json.get("learned")
        
        if not user_id or not word_id or learned is None:
            return https_fn.Response(json.dumps({"status": "error", "message": "Eksik parametre."}), status=400, mimetype="application/json")

        review_doc_id = f"{user_id}_{word_id}"
        review_ref = db.collection("userReviews").document(review_doc_id)
        
        review_ref.set({
            "wordId": word_id,
            "userId": user_id,
            "isLearned": learned,
            "reviewDate": firestore.SERVER_TIMESTAMP,
        }, merge=True)

        return https_fn.Response(json.dumps({"status": "success"}), status=200, mimetype="application/json")
    except Exception as e:
        return https_fn.Response(json.dumps({"status": "error", "message": str(e)}), status=500, mimetype="application/json")

@https_fn.on_request()
def reset_level_reviews(request: https_fn.Request) -> https_fn.Response:
    if request.method != "POST":
        return https_fn.Response("Hata: Sadece POST metodu kabul edilir.", status=405)

    try:
        request_json = request.get_json()
        user_id = request_json.get("userId")
        level_to_reset = request_json.get("level")

        if not user_id or not level_to_reset:
            return https_fn.Response(json.dumps({"status": "error", "message": "Eksik parametre."}), status=400, mimetype="application/json")

        word_ids_to_reset = [doc.id for doc in db.collection("words").where("level", "==", level_to_reset).stream()]

        if not word_ids_to_reset:
            return https_fn.Response(json.dumps({"status": "success", "message": "Kelime bulunamadı."}), status=200, mimetype="application/json")

        batch = db.batch()
        for word_id in word_ids_to_reset:
            doc_id = f"{user_id}_{word_id}"
            batch.delete(db.collection("userReviews").document(doc_id))
        
        batch.commit()
        return https_fn.Response(json.dumps({"status": "success"}), status=200, mimetype="application/json")
    except Exception as e:
        return https_fn.Response(json.dumps({"status": "error", "message": str(e)}), status=500, mimetype="application/json")

@https_fn.on_request()
def get_learned_words(request: https_fn.Request) -> https_fn.Response:
    if request.method != "GET":
        return https_fn.Response("Hata: Sadece GET metodu kabul edilir.", status=405)

    try:
        user_id = request.args.get("userId")
        if not user_id:
            return https_fn.Response(json.dumps({"status": "error"}), status=400, mimetype="application/json")

        user_reviews = db.collection("userReviews").where("userId", "==", user_id).where("isLearned", "==", True).stream()
        unique_word_ids = {review.to_dict().get("wordId") for review in user_reviews}
        unique_word_ids.discard(None)

        words_data = []
        for word_id in unique_word_ids:
            word_doc = db.collection("words").document(word_id).get()
            if word_doc.exists:
                d = word_doc.to_dict()
                d["id"] = word_id
                words_data.append(d)
                
        cleaned = convert_dates_to_iso(words_data)
        cleaned.sort(key=lambda x: x.get("englishWord", "").lower())
        return https_fn.Response(json.dumps({"status": "success", "words": cleaned}), status=200, mimetype="application/json")
    except Exception as e:
        return https_fn.Response(json.dumps({"status": "error", "message": str(e)}), status=500, mimetype="application/json")

@https_fn.on_request()
def set_word_learned_status(request: https_fn.Request) -> https_fn.Response:
    if request.method != "POST":
        return https_fn.Response("Hata: Sadece POST metodu kabul edilir.", status=405)

    try:
        request_json = request.get_json()
        user_id = request_json.get("userId")
        word_id = request_json.get("wordId")
        learned = request_json.get("learned")

        review_doc_id = f"{user_id}_{word_id}"
        db.collection("userReviews").document(review_doc_id).set({
            "userId": user_id,
            "wordId": word_id,
            "isLearned": bool(learned),
            "reviewDate": firestore.SERVER_TIMESTAMP,
        }, merge=True)

        return https_fn.Response(json.dumps({"status": "success"}), status=200, mimetype="application/json")
    except Exception as e:
        return https_fn.Response(json.dumps({"status": "error", "message": str(e)}), status=500, mimetype="application/json")
