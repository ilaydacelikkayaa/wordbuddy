//
//  WordCardView.swift
//  WordBuddy
//
//  Created by İlayda Çelikkaya on 1.12.2025.
//

import SwiftUI

struct WordCardView: View {
    let word: WordModel
    
    let beige = Color(red: 245/255, green: 245/255, blue: 220/255)
    let darkNavy = Color(red: 25/255, green: 25/255, blue: 112/255) //
    let backColor  = Color.blue.opacity(0.08)
    
    @State private var isFlipped: Bool = false
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 20)
                .fill(isFlipped ? backColor : beige)
                .opacity(0.9)
                .shadow(radius: 8)
                .frame(width: 300, height: 400)
            
            VStack {
                
              
                Text(isFlipped ? word.turkishMeaning : word.englishWord)
                    .font(.custom("Palatino", size: 40)) // Yazı tipi örneği
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                    .padding(.horizontal)
                
                Divider()
                    .frame(width: 200)
                    .padding(.vertical, 5)
                
                Text(isFlipped ? word.partOfSpeech : word.exampleSentence)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .frame(maxHeight: .infinity)
            }
            .foregroundColor(darkNavy)
            .padding(20)
            .opacity(isFlipped ? 0.0 : 1.0)
            
          
            VStack {
                Text(word.turkishMeaning)
                    .font(.custom("Palatino", size: 40))
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
                    .padding(.horizontal)
                
                Divider()
                    .frame(width: 200)
                    .padding(.vertical, 5)
                
                Text(word.partOfSpeech)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .frame(maxHeight: .infinity)
            }
            .foregroundColor(darkNavy)
            .padding(20)
           
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            .opacity(isFlipped ? 1.0 : 0.0)
        }

        .frame(width: 300, height: 400)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        
        .animation(.easeInOut(duration: 0.4), value: isFlipped)
        .onTapGesture {
            isFlipped.toggle()
        }
    }
}

#Preview {
    let mockWord = WordModel(
        englishWord: "Ambiguous",
        turkishMeaning: "Belirsiz",
        exampleSentence: "The instructions were ambiguous, leading to confusion.",
        partOfSpeech: "Adjective",
        level:.C2
    )
    
    WordCardView(word: mockWord)
        .padding()
}
