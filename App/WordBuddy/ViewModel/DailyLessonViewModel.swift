//
//  DailyLessonViewModel.swift
//  WordBuddy
//
//  Created by İlayda Çelikkaya on 30.11.2025.

import Foundation
import Combine
import FirebaseAuth

class DailyLessonViewModel: ObservableObject {
    @Published var activeWords: [WordModel] = []
    @Published var progress: Double = 0.0
    
    @Published var currentLevel: Level = .A1
    @Published var totalWord:Int=0
    @Published var currentLessonCompletedCount: Int = 0
    
    @Published var isLoading = false // sadece fetchword kısmında true firestoredan veri cekerken true oluyor
    @Published var errorMessage: String?
    
    private let networkManager = NetworkManager()
    
    @Published var isLevelExhausted: Bool = false
    @Published var isLessonCompleted: Bool = false
    
    @Published var learnedWordsInDictionary: [WordModel] = [] //Sözlük kelimelerini tutan yeni liste
    @Published var isDictionaryLoading = false //Sözlük verisinin yüklenme durumu
    init(){
        fetchWords()
    }
    
    
    func fetchWords(){
        if isLevelExhausted {
            return
        }
        
        isLoading=true // uygulama kelime ceklemi islemi basladı
        errorMessage=nil
        isLessonCompleted = false
        
        let currentlevelString=self.currentLevel.rawValue
        Task{ //asenkron çağrı için task başlatıyoruz
            do{
                //günlük ders büyüklüğü
                let fetchedWords=try await networkManager.fetchDailyLesson(level: currentlevelString,lessonSize: 10)
                
                await MainActor.run{
                    self.isLoading = false
                    
                    
                    if fetchedWords.isEmpty {
                        self.isLevelExhausted = true
                        self.activeWords = []
                        self.totalWord=0
                        self.currentLessonCompletedCount = 0
                        self.progress = 0
                        self.isLessonCompleted = true
                        print("INFO: API'den kelime gelmedi, seviye bitmiş sayılıyor.")
                    }
                    else{
                        self.isLevelExhausted = false // Bitmiş değil
                        self.isLessonCompleted = false
                        self.activeWords = fetchedWords.shuffled()
                        self.totalWord = fetchedWords.count
                        self.currentLessonCompletedCount = 0
                        
                        self.updateProgress()
                        print("DEBUG: API'den gelen toplam kelime sayısı: \(self.totalWord)")
                    }
                    
                }
            }
            
            catch{
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Ders yüklenirken sunucu hatası oluştu."
                    
                    print("Hata: Günlük ders çekilemedi: \(error.localizedDescription)")
                }
            }
            
        }
        
    }
        func handleCardAction(learned:Bool){
            guard let word = activeWords.popLast() else { return } //kartı listeden cıkarırken ıdsini alıyorum
            let quality = learned ? 5 : 0
            if learned {
                self.currentLessonCompletedCount += 1        }
            updateProgress()
            
            Task {
                do {
                    try await networkManager.processReview(wordId: word.id, quality: quality)
                    print("INFO: \(word.englishWord) için SM-2 güncellemesi başarılı (Quality: \(quality)).")
                } catch {
                    print("Hata: processReview API çağrısı başarısız oldu: \(error.localizedDescription)")
                    await MainActor.run {
                        self.activeWords.insert(word, at: 0)
                        self.errorMessage = "Kaydetme hatası. Tekrar deneyin."
                    }
                }
            }
            if activeWords.isEmpty {
                fetchWords()
            }
        }
    
    func fetchLearnedWordsForDictionary(){
        isDictionaryLoading=true
        Task{
            do{
                let words=try await networkManager.fetchLearnedWords()
                await MainActor.run{
                    self.learnedWordsInDictionary = words
                    self.isDictionaryLoading = false
                }
            }
            catch{
                await MainActor.run{
                    self.isDictionaryLoading = false
                    self.errorMessage = "Sözlük yüklenirken hata oluştu."
                    print("Hata: Sözlük çekilemedi: \(error.localizedDescription)")
                }
            }
        }
        
    }
        
        func updateProgress() {
            let total = Double(totalWord) // Total kelime sayısı (Payda)
            self.progress = total > 0 ? Double(currentLessonCompletedCount) / total : 0.0
        }
        
        func restartLesson(){
            let levelString = currentLevel.rawValue
            isLoading = true
            errorMessage = nil
            
            Task {
                do {
                    try await networkManager.resetLevelReviews(level: levelString)
                    await MainActor.run {
                        self.currentLessonCompletedCount = 0
                        self.progress = 0
                        self.isLevelExhausted = false
                        self.isLessonCompleted = false
                        self.isLoading = false
                    }
                    fetchWords()
                } catch {
                    await MainActor.run {
                        self.isLoading = false
                        self.errorMessage = "Seviye sıfırlanamadı."
                    }
                }
            }
        }
        
    }

