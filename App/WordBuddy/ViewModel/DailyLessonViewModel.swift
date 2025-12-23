//
//  DailyLessonViewModel.swift
//  WordBuddy
//
//  Created by İlayda Çelikkaya on 30.11.2025.

import Foundation
import Combine
import FirebaseAuth

class DailyLessonViewModel: ObservableObject {

    @Published var activeWords: [WordModel] = [] //derste gösterilecek aktif kelime
    @Published var progress: Double = 0.0 //ilerleme yüzdesi
    
    @Published var currentLevel: Level = .A1//mevcut level
    @Published var totalWord:Int=0 //mevcut dersteki kelime sayısı
    @Published var currentLessonCompletedCount: Int = 0 //ogrenildi olark isaretlenen kelime sayısı
    
    @Published var isLoading = false // sadece fetchword kısmında true firestoredan veri cekerken true oluyor
    @Published var errorMessage: String?
    
    private let networkManager = NetworkManager()
    
    @Published var isLessonCompleted: Bool = false //mevcut dersin tamamlanıp tamamlanmadığı
    
    @Published var learnedWordsInDictionary: [WordModel] = [] //kullanıcının ogrendigi kelimeler sözlük
    @Published var isDictionaryLoading = false //Sözlük verisinin yüklenme durumu
    
    @Published private(set) var lastLessonTotalWord: Int = 0
    
    
    @Published private(set) var exhaustedLevels: Set<Level>=[]
    
    var isCurrentLevelExhausted: Bool {
        exhaustedLevels.contains(currentLevel)
    }
    init(){}
    
    
    func fetchWords(force:Bool=false){
        let requestedLevel = currentLevel
        
        if !force && exhaustedLevels.contains(requestedLevel) {
            return
        }
        
        isLoading=true
        errorMessage=nil
        isLessonCompleted = false
        let levelString = requestedLevel.rawValue
        
        Task{
            do{
                let (fetchedWords, isCompleted) = try await networkManager.fetchDailyLesson(level: levelString,lessonSize: 10)
                
                await MainActor.run{
                    self.isLoading = false
                    
                    // Kontenjan boşsa VEYA sunucu seviyenin tamamlandığını bildiriyorsa
                    if fetchedWords.isEmpty || isCompleted {
                        self.exhaustedLevels.insert(requestedLevel)
                        
                        self.activeWords = []
                        let total = max(self.lastLessonTotalWord, self.totalWord)
                        
                        self.totalWord = total
                        self.currentLessonCompletedCount = total
                        self.progress = total > 0 ? 1.0 : 0.0
                        self.isLessonCompleted = true
                        
                        print("INFO: Ders tamamlandı/seviye bitti. isLevelExhausted: \(isCompleted)")
                    }
                    else{
                        self.exhaustedLevels.remove(requestedLevel)
                        
                        self.isLessonCompleted = false
                        self.activeWords = fetchedWords.shuffled()
                        self.lastLessonTotalWord = fetchedWords.count
                        self.totalWord = fetchedWords.count
                        self.currentLessonCompletedCount = 0
                        self.updateProgress()
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
    
    func removeFromDictionary(word: WordModel) {
        guard let id = word.id else { return }
        
        Task {
            do {
                try await networkManager.setWordLearnedStatus(wordId: id, learned: false)
                
                await MainActor.run {
                    self.learnedWordsInDictionary.removeAll { $0.id == id }
                    self.exhaustedLevels.remove(word.level)
                    if self.currentLevel == word.level {
                                        self.fetchWords(force: true)
                                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Kelime sözlükten kaldırılamadı."
                }
            }
        }
    }
    
    
    func changeLevel(to newLevel:Level){
        isLoading=true
        errorMessage=nil
        
        Task{
            do{
                try await networkManager.setUserlevel(level: newLevel.rawValue)
                
                await MainActor.run {
                    // UI state reset (önemli: C1’den kalan state A1’e taşınmasın)
                    self.currentLevel = newLevel
                    self.activeWords = []
                    self.totalWord = 0
                    self.currentLessonCompletedCount = 0
                    self.progress = 0
                    self.isLessonCompleted = false
                    self.isLoading = false
                }
                fetchWords()
                
            }
            catch{
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Seviye ayarlanamadı."
                }
            }
        }
        
    }
    
    func handleCardAction(learned:Bool){
        guard let word = activeWords.popLast() else { return }
        
        
        if learned {
            self.currentLessonCompletedCount += 1
        }
        else{
            self.activeWords.insert(word, at: 0)
        }
        updateProgress()
        
        Task {
            do {
                try await networkManager.processReview(wordId: word.id, learned: learned)
                
                if learned{
                    if !self.learnedWordsInDictionary.contains(where: {$0.id==word.id}){
                        self.learnedWordsInDictionary.append(word)
                        self.learnedWordsInDictionary.sort{
                            $0.englishWord.lowercased() < $1.englishWord.lowercased()
                        }
                        
                    }
                    if self.activeWords.isEmpty {
                        self.fetchWords()
                    }
                }
                
            }  catch {
                await MainActor.run{
                    self.isDictionaryLoading = false
                    self.errorMessage = "Sözlük yüklenirken hata oluştu."
                }
            }
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
    
    func getPlaceHolderSentence(for word:WordModel)->String{
        let sentence=word.exampleSentence
        let target=word.englishWord
        return sentence.replacingOccurrences(of: target, with: "____",options: .caseInsensitive)
        
    }
    func getOptions(for word:WordModel) -> [String]{
        var options=[word.englishWord]
        let otherWords = activeWords.filter { $0.id != word.id }.map { $0.englishWord }
        options.append(contentsOf: otherWords.shuffled().prefix(3))
            return options.shuffled() // Seçenekleri karıştır
    }
    
        
        func updateProgress() {
            let total = Double(totalWord) // Total kelime sayısı (Payda)
            self.progress = total > 0 ? Double(currentLessonCompletedCount) / total : 0.0
        }
        
    @Published var quizPool: [WordModel] = []
    @Published var isQuizLoading: Bool = false

    func fetchAllLevelsForQuiz() {
        isQuizLoading = true
        errorMessage = nil

        Task {
            do {
                var collected: [WordModel] = []
                var seenIds = Set<String>()

                let levels: [Level] = [.A1, .A2, .B1, .B2, .C1, .C2]

                for level in levels {
                    // tek seferde çok çekmeyi dene
                    let (words, _) = try await networkManager.fetchDailyLesson(level: level.rawValue, lessonSize: 500)

                    // id ile duplicate engelle
                    let newOnes = words.filter { w in
                        guard let id = w.id else { return true }
                        if seenIds.contains(id) { return false }
                        seenIds.insert(id)
                        return true
                    }

                    collected.append(contentsOf: newOnes)
                }

                await MainActor.run {
                    self.quizPool = collected.shuffled()
                    self.isQuizLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isQuizLoading = false
                    self.errorMessage = "Quiz verileri çekilemedi."
                }
            }
        }
    }
    func processQuizAnswer(word: WordModel, learned: Bool) {
        Task {
            do {
                try await networkManager.processReview(wordId: word.id, learned: learned)
            } catch {
                await MainActor.run {
                    self.errorMessage = "Cevap kaydedilemedi."
                }
            }
        }
    }


    
        func restartLesson(){
            let levelToReset = currentLevel
            
            isLoading = true
            errorMessage = nil
            
            Task {
                do {
                    try await networkManager.resetLevelReviews(level: levelToReset.rawValue)
                    await MainActor.run {
                        self.exhaustedLevels.remove(levelToReset)
                        self.lastLessonTotalWord = 0
                        self.totalWord = 0
                        self.currentLessonCompletedCount = 0
                        self.progress = 0
                        self.isLessonCompleted = false
                        self.isLoading = false
                    }
                    fetchLearnedWordsForDictionary()
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

