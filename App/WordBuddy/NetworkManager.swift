//
//  NetworkManager.swift
//  WordBuddy
//
//  Created by İlayda Çelikkaya on 8.12.2025.
//
import Foundation
import FirebaseAuth
struct DailyLessonResponse: Decodable {
    let status: String
    let words: [WordModel]
    let isLevelCompleted: Bool // YENİ EKLENEN BAYRAK
}
struct DictionaryResponse: Decodable {
    let status: String
    let words: [WordModel]
    // isLevelCompleted BU YAPIDA YOK
}
class NetworkManager{
    private let baseURL = "http://127.0.0.1:5001/wordbuddy-app/us-central1"
    
    func setUserlevel(level:String) async throws{ //kullanıcının seviyesini kaydeder
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturumu açık değil."])
        }
        let endpoint = "\(baseURL)/set_user_level"
        guard let url = URL(string: endpoint) else { return }
        let body: [String: Any] = [
            "userId": userId,
            "level": level
        ]
        let finalBody = try JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Python'a JSON gönderdiğimizi söylüyoruz
        request.httpBody = finalBody
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            // Python API'sinden 200 (OK) dışında bir yanıt gelirse (400, 500 gibi) hata fırlat
            throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Seviye ayarlama başarısız."])
        }
        
    }
    
    func fetchDailyLesson(level:String,lessonSize:Int) async throws -> ([WordModel], Bool){ // DÖNÜŞ TİPİ GÜNCELLENDİ
        //Python'dan, SM-2 algoritmasının seçtiği 10 kelimelik dersi ister ve alır.
        
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturumu açık değil."])
        }
        
        let endpoint="\(baseURL)/get_daily_lesson"
        guard var components=URLComponents(string:endpoint) else{
            throw NSError(domain: "URLError", code: 400, userInfo: [NSLocalizedDescriptionKey: "URL oluşturulamadı."])
        }
        let queryItems:[URLQueryItem]=[
            URLQueryItem(name: "userId", value: userId),
            URLQueryItem(name: "lessonSize", value: String(lessonSize)),
            URLQueryItem(name: "level", value: level)
        ]
        components.queryItems=queryItems
        
        
        guard let url=components.url else{
            throw URLError(.badURL)
        }
        var request=URLRequest(url:url)
        request.httpMethod = "GET"
        
        let (data,response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
            throw NSError(domain: "APIError",
                          code: statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "Ders listesi alınamadı. Hata Kodu: \(statusCode)"])
        }
        
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let apiResponse = try decoder.decode(DailyLessonResponse.self, from: data)
            // DÖNÜŞ DEĞERİ GÜNCELLENDİ
            return (apiResponse.words, apiResponse.isLevelCompleted)
            
        } catch {
            
            print(" FATAL DECODE HATASI TÜRÜ: \(error)")
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API'den Gelen Hatalı JSON Verisi:\n\(jsonString)")
            } else {
                print("API'den gelen veri okunabilir metin formatında değil.")
            }
            
            throw error
        }
    }
    
    
    func resetLevelReviews(level: String) async throws {
        //Kullanıcının o seviyedeki tüm öğrenme geçmişini Firestore'dan silmesi için Python'a komut gönderir.
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturumu açık değil."])
        }
        
        let endpoint = "\(baseURL)/reset_level_reviews"
        guard let url = URL(string: endpoint) else { throw URLError(.badURL) }
        
        let body: [String: Any] = [
            "userId": userId,
            "level": level
        ]
        let finalBody = try JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = finalBody
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let statusCode = httpResponse.statusCode
            throw NSError(domain: "APIError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Seviye sıfırlama başarısız. Hata Kodu: \(statusCode)"])
        }
    }
    
    
    func processReview(wordId: String?, learned: Bool) async throws {
        //Kullanıcı bir kartı (Doğru/Yanlış) kaydırdığında, bu bilgiyi ve quality puanını Python'a gönderir.
        // wordId opsiyonel olduğu için, nil ise hata fırlat
        guard let wordId = wordId, !wordId.isEmpty, let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı veya kelime ID'si eksik."])
        }
        
        let endpoint = "\(baseURL)/process_review"
        guard let url = URL(string: endpoint) else { throw URLError(.badURL) }
        
        let body: [String: Any] = [
            "userId": userId,
            "wordId": wordId,
            "learned": learned
        ]
        let finalBody = try JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = finalBody
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let statusCode = httpResponse.statusCode
            throw NSError(domain: "APIError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "İnceleme kaydı başarısız. Hata Kodu: \(statusCode)"])
        }
    }
    
    func setWordLearnedStatus(wordId: String, learned: Bool) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturumu açık değil."])
        }

        let endpoint = "\(baseURL)/set_word_learned_status"
        guard let url = URL(string: endpoint) else { throw URLError(.badURL) }

        let body: [String: Any] = [
            "userId": userId,
            "wordId": wordId,
            "learned": learned
        ]
        let finalBody = try JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = finalBody

        let (_, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw NSError(domain: "APIError", code: httpResponse.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: "Kelime güncellenemedi."])
        }
    }

    
    
    func fetchLearnedWords() async throws ->[WordModel]{
        
        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturumu açık değil."])
        }
        let endpoint = "\(baseURL)/get_learned_words"
        guard var components = URLComponents(string: endpoint) else { throw URLError(.badURL) }
        components.queryItems = [
                URLQueryItem(name: "userId", value: userId)
            ]
        guard let url = components.url else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Sadece veri alıyoruz, bu yüzden GET.
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
                throw NSError(domain: "APIError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Sözlük listesi alınamadı."])
            }
        do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
            let apiResponse = try decoder.decode(DictionaryResponse.self, from: data)
            return apiResponse.words
            } catch {
                print("Sözlük Decode Hatası: \(error)")
                throw error
            }
        }
    }


