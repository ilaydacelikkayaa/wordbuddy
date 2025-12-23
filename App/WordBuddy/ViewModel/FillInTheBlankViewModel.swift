//
//  FillInTheBlankViewModel.swift
//  WordBuddy
//
//  Created by İlayda Çelikkaya on 20.12.2025.
//

import Foundation
import SwiftUI
import Combine

class FillInTheBlankViewModel: ObservableObject {
    @Published  var quizWords: [WordModel] = [] //quiz boyunca sorulacak kelimeler
    @Published  var currentIndex: Int = 0 //kaçıncı sorudayız

    @Published  var options: [String] = [] //3 sık
    @Published  var selectedOption: String? = nil //kullanıcının sectigi sık
    @Published  var isCorrect: Bool? = nil //dogru mu yanlıs mı
    let darkNavy = Color(red: 25/255, green: 25/255, blue: 112/255)

    var currentWord: WordModel? {
        if currentIndex < quizWords.count {
            return quizWords[currentIndex]
        } else {
            return nil
        }
    }
     func startQuizIfNeeded(pool:[WordModel]) {
        guard quizWords.isEmpty else { return }
        guard !pool.isEmpty else { return }

        quizWords = pool // snapshot
        currentIndex = 0
        prepareQuestion()
    }

    func restartQuiz() {
        guard !quizWords.isEmpty else { return }
        currentIndex = 0
        selectedOption = nil
        isCorrect = nil
        prepareQuestion()
    }

     func prepareQuestion() {
        guard let word = currentWord else { return }
        options = make3Options(for: word)
        selectedOption = nil
        isCorrect = nil
    }

     func make3Options(for word: WordModel) -> [String] {
        var opts: [String] = [word.englishWord]

        let pool = quizWords
            .map { $0.englishWord }
            .filter { $0.lowercased() != word.englishWord.lowercased() }
            .shuffled()

        opts.append(contentsOf: pool.prefix(2))

        // garanti 3 unique olsun
        opts = Array(Set(opts))
        while opts.count < 3, let extra = pool.randomElement(), !opts.contains(extra) {
            opts.append(extra)
        }
        return opts.shuffled()
    }

   func handleAnswer(_ option: String, correctWord: String, word: WordModel,
                     onRecord: (WordModel, Bool) -> Void) {
        selectedOption = option
       let learned = option.lowercased() == correctWord.lowercased()

       isCorrect = learned

       onRecord(word, learned)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.currentIndex += 1
            self.prepareQuestion()
        }
    }

 func buttonColor(for option: String, correctWord: String) -> Color {
        if let selected = selectedOption, selected == option {
            return option.lowercased() == correctWord.lowercased() ? .green : .red
        }
        return Color(red: 0.1, green: 0.1, blue: 0.3)
    }
}
