from firebase_functions import https_fn
from firebase_admin import initialize_app, firestore
from datetime import datetime, timedelta, timezone
import json

initialize_app()
db = firestore.client()

# --- Utility Fonksiyonu ---
def convert_dates_to_iso(data):
    # ... (Bu fonksiyonunuz aynı kalabilir, tarih formatı dönüştürme) ...
    if isinstance(data, dict):
        new_data = {}
        for key, value in data.items():
            if isinstance(value, datetime):
                new_data[key] = value.isoformat()
            elif isinstance(value, dict) or isinstance(value, list):
                new_data[key] = convert_dates_to_iso(value)
            else:
                new_data[key] = value
        return new_data
    elif isinstance(data, list):
        return [convert_dates_to_iso(item) for item in data]
    else:
        return data

# --- SRS Mantığı (Basitleştirilmiş) ---
def calculate_next_review(quality):
    """
    Basitleştirilmiş Tekrar Mantığı: Bildiyse 1 gün sonra, Bilemediyse Hemen.
    """
    now = datetime.now(timezone.utc)
    
    # 45 yıllık interval'ı engellemek için reps ve ef sabit tutulur (veya basit değerler alır)
    new_ef = 2.5
    
    if quality < 3:  # Bilemedi veya zorlandı (learned: false)
        new_interval = 0
        next_review_date = now
        new_reps = 0
    else:  # Bildi (learned: true)
        new_interval = 1
        next_review_date = now + timedelta(days=1)
        new_reps = 1 # İlk tekrar olarak kabul edilebilir
        
    return {
        'nextReviewDate': next_review_date,
        'ef': new_ef,
        'reps': new_reps,
        'interval': new_interval
    }

# --- API Uç Noktaları ---

@https_fn.on_request()
def set_user_level(request: https_fn.Request) -> https_fn.Response:
    # ... (Bu fonksiyon aynı kalabilir) ...
    if request.method != 'POST':
        return https_fn.Response("Hata: Sadece POST metodu kabul edilir.", status=405)
    try:
        request_json = request.get_json()
        user_id = request_json.get('userId') if request_json else None
        new_level = request_json.get('level') if request_json else None
        if not user_id or not new_level:
            return https_fn.Response(json.dumps({"status": "error", "message": "Hata: userId ve level parametreleri gerekli."}), status=400, mimetype="application/json")
        user_ref = db.collection('users').document(user_id)
        user_ref.set({'currentLevel': new_level, 'lastUpdated': firestore.SERVER_TIMESTAMP}, merge=True)
        print(f"Kullanıcı {user_id} için seviye başarıyla {new_level} olarak ayarlandı.")
        return https_fn.Response(json.dumps({'status': 'success', 'message': f'Seviye {new_level} olarak ayarlandı.'}), status=200, mimetype="application/json")
    except Exception as e:
        print(f"Genel Hata (set_user_level): {e}")
        return https_fn.Response(json.dumps({'status': 'error', 'message': f'Sunucu hatası: {e}'}), status=500, mimetype="application/json")


@https_fn.on_request()
def get_daily_lesson(request: https_fn.Request) -> https_fn.Response:
    if request.method != 'GET':
        return https_fn.Response("Hata: Sadece GET metodu kabul edilir.", status=405)

    try:
        user_id = request.args.get('userId')
        lesson_size_str = request.args.get('lessonSize', '10') # 10 olarak sabitliyoruz
        current_level = request.args.get('level', 'A1')

        if not user_id:
            return https_fn.Response(json.dumps({"status": "error", "message": "Hata: userId parametresi gerekli."}), status=400, mimetype="application/json")

        lesson_size = int(lesson_size_str)
        today = datetime.now(timezone.utc)
        
        # ⭐️ KRİTİK FİLTRE: Kullanıcının daha önce review yaptığı TÜM kelimelerin ID'lerini çek (Sonsuz döngüyü engeller)
        all_reviewed_ids = {
            doc.get('wordId') for doc in db.collection('userReviews')
            .where('userId', '==', user_id).stream()
        }
        
        words_data = []
        
        # 1. SM-2'nin İstediği Kelimeleri Çekme (nextReviewDate <= today olanlar)
        reviews_to_review = (
            db.collection('userReviews')
            .where('userId', '==', user_id)
            .where('nextReviewDate', '<=', today)
            .order_by('nextReviewDate')
            .order_by('ef')
            .limit(lesson_size)
            .stream()
        )

        for review in reviews_to_review:
            review_dict = review.to_dict()
            word_id = review_dict.get('wordId')
            if not word_id: continue

            word_doc = db.collection('words').document(word_id).get()
            if not word_doc.exists: continue

            word_dict = word_doc.to_dict()
            word_dict.update({
                'id': word_id,
                'nextReviewDate': review_dict.get('nextReviewDate').isoformat() if review_dict.get('nextReviewDate') else None,
                'ef': review_dict.get('ef', 2.5),
                'reps': review_dict.get('reps', 0),
                'interval': review_dict.get('interval', 0),
            })
            words_data.append(word_dict)

        # 2. Yeni Kelime Arama (Kontenjan kalmışsa)
        if len(words_data) < lesson_size:
            print(f"DEBUG: Ders kontenjanı açık ({len(words_data)}/{lesson_size}). Yeni kelime aranıyor.")

            new_words_query = db.collection('words').where('level', '==', current_level).stream()
            
            for word_doc in new_words_query:
                word_id = word_doc.id
                
                # ⭐️ KRİTİK FİLTRE: Kelime daha önce HİÇ İNCELENMEMİŞ olmalı.
                if word_id not in all_reviewed_ids:
                    
                    if len(words_data) >= lesson_size:
                        break
                        
                    word_dict = word_doc.to_dict()
                    word_dict.update({'id': word_id, 'ef': 2.5, 'reps': 0, 'interval': 0})
                    words_data.append(word_dict)
                    
                    print(f"DEBUG: Yeni kelime eklendi: {word_id}. Toplam: {len(words_data)}")

        print(f"DEBUG: Nihai olarak döndürülen kelime sayısı: {len(words_data)}")
        
        cleaned_words_data = convert_dates_to_iso(words_data)
        return https_fn.Response(json.dumps({'status': 'success', 'words': cleaned_words_data}), status=200, mimetype="application/json")

    except Exception as e:
        print(f"Genel Hata (get_daily_lesson): {e}")
        return https_fn.Response(json.dumps({'status': 'error', 'message': f'Sunucu hatası: {e}'}), status=500, mimetype="application/json")

@https_fn.on_request()
def process_review(request: https_fn.Request) -> https_fn.Response:
    if request.method != 'POST':
        return https_fn.Response("Hata: Sadece POST metodu kabul edilir.", status=405)
    try:
        request_json = request.get_json()
        user_id = request_json.get("userId")
        word_id = request_json.get("wordId")
        quality = request_json.get("quality")
        if not user_id or not word_id or quality is None:
            return https_fn.Response(json.dumps({"status": "error", "message": "Gerekli parametreler eksik."}), status=400, mimetype="application/json")
            
        review_doc_id = f"{user_id}_{word_id}"
        review_ref = db.collection('userReviews').document(review_doc_id)
        review_snapshot = review_ref.get()
        
        # ❌ EF, Reps, Interval gibi eski verileri artık SM-2 için kullanmıyoruz.
        # Sadece kalite puanını calculate_next_review'a gönderiyoruz.
        srs_results = calculate_next_review(quality)

        review_update_data = {
            'wordId': word_id,
            'userId': user_id,
            'reviewDate': firestore.SERVER_TIMESTAMP,
            'nextReviewDate': srs_results['nextReviewDate'],
            'ef': srs_results['ef'],
            'reps': srs_results['reps'],
            'interval': srs_results['interval'],
            'lastQuality': quality
        }
        
        review_ref.set(review_update_data, merge=True)
        
        print(f"DEBUG: {word_id} güncellendi. Yeni Interval: {srs_results['interval']} gün.")

        return https_fn.Response(json.dumps({
            'status': 'success',
            'message': 'İnceleme başarıyla işlendi ve güncellendi.',
            'nextReviewDate': srs_results['nextReviewDate'].isoformat()
        }), status=200, mimetype="application/json")

    except Exception as e:
        print(f"Genel Hata (process_review): {e}")
        return https_fn.Response(json.dumps({'status': 'error', 'message': f'Sunucu hatası: {e}'}), status=500, mimetype="application/json")


@https_fn.on_request()
def reset_level_reviews(request: https_fn.Request) -> https_fn.Response:
    # ... (Bu fonksiyon aynı kalabilir) ...
    if request.method != 'POST':
        return https_fn.Response("Hata: Sadece POST metodu kabul edilir.", status=405)
    try:
        request_json = request.get_json()
        user_id = request_json.get('userId')
        level_to_reset = request_json.get('level')
        if not user_id or not level_to_reset:
            return https_fn.Response(json.dumps({"status": "error", "message": "userId ve level parametreleri gerekli."}), status=400, mimetype="application/json")
        word_ids_to_reset = [doc.id for doc in db.collection('words').where('level', '==', level_to_reset).stream()]
        if not word_ids_to_reset:
            return https_fn.Response(json.dumps({"status": "success", "message": f"{level_to_reset} seviyesinde silinecek kelime bulunamadı."}), status=200, mimetype="application/json")
        batch = db.batch()
        review_refs = db.collection('userReviews')
        for word_id in word_ids_to_reset:
            doc_id = f"{user_id}_{word_id}"
            batch.delete(review_refs.document(doc_id))
        batch.commit()
        return https_fn.Response(json.dumps({'status': 'success', 'message': f'{level_to_reset} seviyesinin geçmişi başarıyla sıfırlandı.'}), status=200, mimetype="application/json")
    except Exception as e:
        print(f"Genel Hata (reset_level_reviews): {e}")
        return https_fn.Response(json.dumps({"status": "error", "message": f"Sunucu hatası: {e}"}), status=500, mimetype="application/json")


@https_fn.on_request()
def get_learned_words(request: https_fn.Request) -> https_fn.Response:
    # ... (Bu fonksiyon aynı kalabilir) ...
    if request.method != 'GET':
        return https_fn.Response("Hata: Sadece GET metodu kabul edilir.", status=405)
    try:
        user_id = request.args.get('userId')
        if not user_id:
            return https_fn.Response(json.dumps({"status": "error", "message": "Hata: userId parametresi gerekli."}), status=400, mimetype="application/json")
        
        words_data = []
        user_reviews = db.collection('userReviews').where('userId', '==', user_id).stream()
        unique_word_ids = {review.get('wordId') for review in user_reviews if review.get('wordId')}

        for word_id in unique_word_ids:
            word_doc = db.collection('words').document(word_id).get()
            if word_doc.exists:
                word_dict = word_doc.to_dict()
                word_dict['id'] = word_id
                words_data.append(word_dict)
        
        words_data.sort(key=lambda x: x.get('englishWord', '').lower())
        
        print(f"DEBUG: Sözlük için çekilen toplam kelime sayısı: {len(words_data)}")
        return https_fn.Response(json.dumps({'status': 'success', 'words': words_data}), status=200, mimetype="application/json")
    except Exception as e:
        print(f"Genel Hata (get_learned_words): {e}")
        return https_fn.Response(json.dumps({'status': 'error', 'message': f'Sunucu hatası: {e}'}), status=500, mimetype="application/json")


@https_fn.on_request()
def normalize_review_dates(request: https_fn.Request) -> https_fn.Response:
    # ... (Bu fonksiyon da eklenmiş oldu, eski 45 yıllık verileri yarına çeker) ...
    if request.method != 'POST':
        return https_fn.Response("Hata: Sadece POST metodu kabul edilir.", status=405)

    try:
        req = request.get_json()
        user_id = req.get('userId') if req else None
        if not user_id:
            return https_fn.Response(json.dumps({"status":"error","message":"userId gerekli"}), status=400, mimetype="application/json")

        now = datetime.now(timezone.utc)
        max_allowed = now + timedelta(days=1)

        reviews = db.collection('userReviews').where('userId', '==', user_id).stream()

        batch = db.batch()
        count = 0

        for r in reviews:
            data = r.to_dict()
            next_dt = data.get('nextReviewDate')

            if next_dt and hasattr(next_dt, 'replace'):
                if next_dt > max_allowed:
                    batch.update(r.reference, {
                        'nextReviewDate': max_allowed,
                        'interval': 1,
                        'reps': 1,
                        'ef': 2.5
                    })
                    count += 1

        batch.commit()

        return https_fn.Response(json.dumps({
            "status":"success",
            "message": f"{count} kayıt normalize edildi. Eski kayıtlar yarına çekildi."
        }), status=200, mimetype="application/json")

    except Exception as e:
        return https_fn.Response(json.dumps({"status":"error","message":str(e)}), status=500, mimetype="application/json")
