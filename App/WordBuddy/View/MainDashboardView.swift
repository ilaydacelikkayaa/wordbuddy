//
import SwiftUI
import FirebaseAuth
import Combine

struct MainDashboardView: View {
    @StateObject var viewModel = UserProfileViewModel()
    @EnvironmentObject var appCoordinator: AppCoordinatorViewModel
    @EnvironmentObject var vm : DailyLessonViewModel
    let gradientStart = Color(red: 255/255, green: 173/255, blue: 96/255)   // Canlı turuncu/şeftali
    let gradientEnd   = Color(red: 60/255,  green: 190/255, blue: 190/255)  // Parlak turkuaz
    var body: some View {
        
        
        VStack(spacing: 30) {
            ZStack{
                LinearGradient(
                    gradient: Gradient(colors: [gradientStart, gradientEnd]),
                    startPoint: .top, // Yukarıdan başla
                    endPoint: .bottom // Aşağıda bitir
                )
                .ignoresSafeArea() //
                VStack(spacing:30){
                    HStack {
                        if viewModel.isLoading {
                            Text("Hoş Geldiniz!")
                                .font(.largeTitle)
                                .bold()
                        } else {
                            Text("Merhaba, \(viewModel.userName)!")
                                .font(.largeTitle)
                                .bold()
                        }
                        Spacer()
                        NavigationLink {
                            ProfileView()
                        }label:{
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3))
                        }
                        
                        
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 40)
                    
                    VStack(spacing: 15) {
                        
                        // 4.1. Kelime Öğrenme Modülü
                        NavigationLink {
                            // İleride Kelime Öğrenme View'ı buraya gelecek
                            Text("Kelime Öğrenme Ekranı (Yapım Aşamasında)")
                        } label: {
                            FeatureCard(title: "Günlük Dersler", icon: "book.fill", color: .blue)
                        }
                        
                        // 4.2. Test (Quiz) Modülü
                        NavigationLink {
                            Text("Test Başlatılıyor...")
                        } label: {
                            FeatureCard(title: "Bilgileri Test Et", icon: "questionmark.circle.fill", color: .purple)
                        }
                        
                        // 4.3. Kelime Ekleme / Sözlük
                        NavigationLink {
                            LevelSelectionView()
                        } label: {
                            FeatureCard(title: "Kelimeleri Test Et", icon: "list.bullet.rectangle.fill", color: .green)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                }
                .onAppear {
                    viewModel.fetchUser()
                }
                // NavigationStack'te geri gitme butonunu gizler (isteğe bağlı, daha temiz bir görünüm sağlar)
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}
struct FeatureCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .padding(10)
                .background(color)
                .cornerRadius(8)
            
            Text(title)
                .font(.headline)
                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3))
            
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    
    NavigationStack {
        MainDashboardView()
            .environmentObject(AppCoordinatorViewModel())
            .environmentObject(DailyLessonViewModel())
    }

}
