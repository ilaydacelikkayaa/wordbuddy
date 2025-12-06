//
//  DailyLessonViewModel.swift
//  WordBuddy
//
//  Created by İlayda Çelikkaya on 30.11.2025.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

class DailyLessonViewModel: ObservableObject {
    @Published var activeWords: [WordModel] = []
    @Published var learnedWords: [WordModel] = []
    @Published var progress: Double = 0.0
    @Published var currentLevel: Level = .A1
    @Published var totalWord:Int=0
    @Published var currentLessonCompletedCount: Int = 0
    @Published var isLoading = false //firestoredan veri cekerken true oluyor
    @Published var errorMessage: String?
    private var db = Firestore.firestore()
    init(){
        fetchWords()
    }
    
    func fetchWords(){
        isLoading=true
        errorMessage=nil
        print("DEBUG: Sorgulanan Seviye Başlatıldı -> \(currentLevel.rawValue)")
        db.collection("words")
            .whereField("level", isEqualTo: currentLevel.rawValue) //rawvalue degerine esit olanı getir
        
            .getDocuments{//firestore a bu isteği gonderdim
                [weak self](result,error) in //selfi zayıf referansla tutuyorum
                guard let self=self else{return}
                self.isLoading=false
                if let error=error{
                    print("Firestore Hata: \(error.localizedDescription)")
                    self.errorMessage = "Kelime yüklenemedi."
                    return
                }
                guard let documents = result?.documents else {
                    self.totalWord = 0
                    self.activeWords = []
                    return
                }
                //Firestore to Word Model
                let newWords:[WordModel]=documents.compactMap{
                    doc in
                    try? doc.data(as: WordModel.self)
                    //compactMap → nil olanları çöpe atar, kalanlarla yeni bir dizi oluşturur.
                }
                
                let learnedEnglishWords = Set(self.learnedWords.map(\.englishWord))
                self.activeWords = newWords.filter { word in
                    !learnedEnglishWords.contains(word.englishWord)
                }.shuffled() //kart sırası random olsun diye
                self.totalWord=newWords.count
                self.currentLessonCompletedCount = 0
                self.updateProgress()
            }
    }
    
    func handleCardAction(learned:Bool){
        guard var word = activeWords.popLast() else { return } //kartı listeden cıkarırken ıdsini alıyorum
        if learned {
            saveReviewToFirestore(wordId: word.id,learned:learned)
            if !learnedWords.contains(where: {  $0.englishWord == word.englishWord }) {
                learnedWords.append(word)
            }
            
            self.currentLessonCompletedCount += 1
            
            } else {
                activeWords.insert(word, at: 0)
                saveReviewToFirestore(wordId: word.id, learned: learned)
            }
            
            updateProgress()
        }
    
    private func saveReviewToFirestore(wordId:String?,learned:Bool){
        guard let wordId = wordId, let userId = Auth.auth().currentUser?.uid else {
        print("Hata: Kart ID veya Kullanıcı ID (Auth) bulunamadı. Lütfen giriş yapın.")
        return
                }
        let reviewData: [String: Any] = [
                    "wordId": wordId,
                    "userId": userId,
                    "reviewDate": FieldValue.serverTimestamp(),
                    "qualityResponse": learned ? 5 : 0 // 5 (Kolay) veya 0 (Zor)
                ]
        db.collection("userReviews").addDocument(data: reviewData) { error in
            if let error = error {
                print("Cevap kaydı hatası: \(error.localizedDescription)")
            }
        }

    }
    
        func updateProgress() {
            let totalKnown = self.currentLessonCompletedCount
            let total = Double(totalWord) // Total kelime sayısı (Payda)
            self.progress = total > 0 ? Double(totalKnown) / total : 0.0
        }
    
    func restartLesson(){
        self.learnedWords.removeAll{
            word in
            word.level==self.currentLevel
        }
            
            self.currentLessonCompletedCount = 0
            self.progress = 0.0
            
            fetchWords()
    }
    
}
