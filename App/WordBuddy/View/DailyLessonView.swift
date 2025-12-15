//
//  DailyLessonView.swift
//  WordBuddy
//
//  Created by İlayda Çelikkaya on 1.12.2025.
//

// DailyLessonView.swift

import SwiftUI

struct DailyLessonView: View {
    @EnvironmentObject var vm : DailyLessonViewModel
    let darkNavy = Color(red: 25/255, green: 25/255, blue: 112/255) //
    let gradientStart = Color(red: 255/255, green: 173/255, blue: 96/255)   // Canlı turuncu/şeftali
    let gradientEnd   = Color(red: 60/255,  green: 190/255, blue: 190/255)  // Parlak turkuaz
    
    var body: some View {
        ZStack{
            LinearGradient(
                gradient: Gradient(colors: [gradientStart, gradientEnd]),
                startPoint: .top, // Yukarıdan başla
                endPoint: .bottom // Aşağıda bitir
            )
            .ignoresSafeArea()
            
            VStack {
                Text("Günlük Ders")
                    .font(.custom("Palatino", size: 25))
                    .foregroundStyle(darkNavy)
                    .padding()
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 1. İLERLEME ÇUBUĞU (Tamamlanma Eğrisi)
                Text("İlerleme: \(vm.currentLessonCompletedCount) / \(vm.totalWord)")
                    .font(.custom("Palatino", size: 15))
                    .bold()
                    .padding(.bottom, 10)
                
                
                ProgressView(value: vm.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .green))
                    .padding(.horizontal, 40)
                
                Spacer()
                
                ZStack {
                    if let topWord = vm.activeWords.last {
                        WordCardView(word:topWord) // En üstteki kartı göster
                            .frame(width: 300, height: 400)
                            .id(topWord.id ?? topWord.uuid)
                    }
                    else if vm.isLoading{
                        ProgressView("Kelimeler Yükleniyor...")
                            .font(.custom("Palatino", size: 20))
                            .padding()
                            .foregroundStyle(darkNavy)
                    }
                    else {
                        VStack{
                            Text("Ders Tamamlandı!")
                                .font(.custom("Palatino", size: 30))
                                .font(.title)
                                .padding()
                            Button("Baştan Başlat")
                            {
                                vm.restartLesson()
                            }
                            .padding()
                            .background(darkNavy)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 20)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                if vm.activeWords.last != nil {
                    HStack(spacing: 40) {
                        
                        ActionButton(systemName: "xmark", color: .red) {
                            vm.handleCardAction(learned: false)
                        }
                        
                        ActionButton(systemName: "checkmark", color: .green) {
                            vm.handleCardAction(learned: true)
                        }
                    }
                    .padding(.bottom, 50)
                    
                }
              
                
            }
            .onAppear {
                
                vm.updateProgress()
            }
        }
    }
    // Buton View'ı (Tekrar Kullanılabilir Yapı)
    struct ActionButton: View {
        let systemName: String
        let color: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Image(systemName: systemName)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(20)
                    .background(color)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }
        }
    }
}
#Preview {
    NavigationStack{
        DailyLessonView()
            .environmentObject(DailyLessonViewModel())
    }

}
