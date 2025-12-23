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
                    else if vm.isCurrentLevelExhausted{
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
                    
                        else if let message = vm.errorMessage{
                            VStack{
                                Text(message)
                                    .font(.custom("Palatino", size: 20))
                                    .padding()
                                Button("Tekrar Dene") {
                                    vm.fetchWords()
                                }
                                .padding()
                                .background(darkNavy)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 20)
                                
                            }
                        }
                    
                    else{
                        VStack {
                        Text("Ders hazır. Başlamak ister misin?")
                            .font(.custom("Palatino", size: 20))
                            .padding()
                            
                        Button("Dersi Başlat") {
                                        vm.fetchWords()
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
                    VStack(spacing: 40) {
                        Text("Do you remember this?")
                            .padding(.top,20)
                            .font(.headline)
                            .bold()
                            .foregroundStyle(Color.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        
                        HStack(spacing:16){
                            ActionButton(color: .gray, title:"No") {
                                vm.handleCardAction(learned: false)
                            }
                            
                            ActionButton( color: darkNavy,title:"Yes") {
                                vm.handleCardAction(learned: true)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 50)

                    }
                    
                }
                
                
            }
            .onAppear {
                if vm.activeWords.isEmpty && !vm.isLoading && !vm.isCurrentLevelExhausted  && vm.errorMessage == nil  {
                    vm.fetchWords()
                }
            }
        }
    }
    // Buton View'ı (Tekrar Kullanılabilir Yapı)
    struct ActionButton: View {
        let color: Color
        let title:String
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing:10){

                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(color)
                .shadow(radius: 10)
                .cornerRadius(20)


            }
        }
    }

#Preview {
    NavigationStack{
        DailyLessonView()
            .environmentObject(DailyLessonViewModel())
    }

}
