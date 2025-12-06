//
//  WordModel.swift
//  WordBuddy
//
//  Created by İlayda Çelikkaya on 30.11.2025.
//
import Foundation
import FirebaseFirestore
enum Level:String,Codable{
    case A1,A2,B1,B2,C1,C2
}

struct WordModel: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    
    var uuid: String? = UUID().uuidString
    let englishWord: String
    let turkishMeaning: String
    let exampleSentence: String
    let partOfSpeech: String
    
    var status: LearningStatus? = .notLearned
    var reviewCount: Int? = 0
    
    let level: Level
    var nextReviewDate: Date? = nil
    var ef: Double = 2.5
    var reps: Int = 0
    var interval: Int = 0
}

enum LearningStatus: String, Codable {
    case notLearned  // Sola kaydırdı/Ezberlemedi
    case reviewing   // Tekrar etmesi gerekiyor
    case learned     // Sağa kaydırdı/Ezberledi
}
