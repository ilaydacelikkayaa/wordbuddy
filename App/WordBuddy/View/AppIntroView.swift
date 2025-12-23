//
//  AppIntroView.swift
//  WordBuddy
//
//  Created by İlayda Çelikkaya on 23.12.2025.
//

import SwiftUI

struct IntroStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

let introSteps = [
    IntroStep(title: "Kelime Hazneni Geliştir",
              description: "Seviyene özel seçilmiş binlerce İngilizce kelime ile dağarcığını her gün büyüt.",
              imageName: "uyglogo.png"),
    IntroStep(title: "Hızlı Pratik Yap",
              description: "Günde sadece 3 dakikanı ayırarak cümle tamamlama testleri ile öğrendiklerini pekiştir.",
              imageName: "onb")
]
struct AppIntroView: View {
    @State private var selectedPage = 0
    @AppStorage("hasSeenIntro") var hasSeenIntro: Bool = false
    let darkNavy = Color(red: 0, green: 0, blue: 0.5)

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                TabView(selection: $selectedPage) {
                    ForEach(0..<introSteps.count, id: \.self) { index in
                        VStack(spacing: 20) {
                            Image(introSteps[index].imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 250)
                                .padding()
                            
                            Text(introSteps[index].title)
                                .font(.title.bold())
                                .foregroundColor(darkNavy)
                            
                            Text(introSteps[index].description)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 30)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                VStack(spacing: 15) {
                    Button(action: {
                        if selectedPage < introSteps.count - 1 {
                            withAnimation { selectedPage += 1 }
                        } else {
                          
                            hasSeenIntro = true
                        }
                    }) {
                        Text(selectedPage == introSteps.count - 1 ? "Hadi Başlayalım!" : "İleri")
                            .font(.headline)
                            .frame(maxWidth: 300)
                            .padding()
                            .background(darkNavy)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    if selectedPage == introSteps.count - 1 {
                        Button("Giriş Yap") {
                            hasSeenIntro = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}
#Preview {
    AppIntroView()
}
