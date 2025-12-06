// DictionaryView.swift
import SwiftUI

struct DictionaryView: View {
    @EnvironmentObject var vm: DailyLessonViewModel
    let gradientStart = Color(red: 255/255, green: 173/255, blue: 96/255)
    let gradientEnd = Color(red: 60/255, green: 190/255, blue: 190/255)
    let darkNavy = Color(red: 25/255, green: 25/255, blue: 112/255)
    let beige = Color(red: 245/255, green: 245/255, blue: 220/255)

    var body: some View {
       
            
            NavigationStack {
                ZStack{
                    LinearGradient(
                        gradient: Gradient(colors: [gradientStart, gradientEnd]),
                        startPoint: .top,
                        endPoint: .bottom)
                    .ignoresSafeArea()
                VStack {
                
                    ScrollView {
                        Text("Sözlüğüm")
                            .font(.custom("Palatino", size: 25))
                            .foregroundStyle(darkNavy)
                            .padding()
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ForEach(vm.learnedWords.sorted(by:{ $0.englishWord<$1.englishWord}),id: \.englishWord){
                            word in
                            VStack(alignment: .leading, spacing: 5){
                                Text(word.englishWord)
                                    
                                    .font(.headline)
                                    .foregroundColor(darkNavy)
                                
                                Text(word.turkishMeaning)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text("Seviye: \(word.level.rawValue)")
                                    .font(.caption)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(beige)               .cornerRadius(8)
                            .shadow(radius: 1)
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
                .toolbarBackground(.hidden, for: .navigationBar)
                .background(Color.clear)
            }
        }
        
    }
}
#Preview {
    // 💡 1. DictionaryViewModel için örnek veriler içeren bir instance hazırlayın.
    let mockVM = DailyLessonViewModel()

    // 💡 2. Örnek kelimeleri öğrenilmiş listeye ekleyin (Test Amaçlı).
    // NOT: loadStaticData() içinde oluşturulan kelimeleri kullanmalıyız.
    // DailyLessonViewModel'inizdeki kelime tanımına göre A1'den Acquire ve Book'u kullanalım:

    let mockWord1 = WordModel(
        englishWord: "Acquire",
        turkishMeaning: "Edinmek, kazanmak",
        exampleSentence: "She hopes to acquire new skills during the internship.",
        partOfSpeech: "Verb",
        level: .A1
    )
    let mockWord2 = WordModel(
        englishWord: "Ubiquitous",
        turkishMeaning: "Her yerde bulunan",
        exampleSentence: "Smartphones have become ubiquitous in modern society.",
        partOfSpeech: "Adjective",
        level: .C2
    )

    // Learned listesini bu kelimelerle manuel olarak doldurun.
    mockVM.learnedWords = [mockWord1, mockWord2]

    return DictionaryView()
        .environmentObject(mockVM)
}
