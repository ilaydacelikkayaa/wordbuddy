import SwiftUI
import FirebaseAuth
import Combine

struct MainDashboardView: View {
    @StateObject var viewModel = UserProfileViewModel()
    @EnvironmentObject var appCoordinator: AppCoordinatorViewModel
    @EnvironmentObject var vm : DailyLessonViewModel
    
    let gradientStart = Color(red: 255/255, green: 173/255, blue: 96/255)
    let gradientEnd   = Color(red: 60/255,  green: 190/255, blue: 190/255)
    let darkNavy      = Color(red: 25/255, green: 25/255, blue: 112/255)
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [gradientStart.opacity(0.9), gradientEnd.opacity(0.9)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 30) {
                       
                        summaryView
                            .padding(.top, 10)
                        
                        VStack(spacing: 20) {
                            NavigationLink(destination: FiilInTheBlankView()) {
                                FeatureCard(
                                    title: "Günlük Dersler",
                                    subtitle: "Cümle tamamlama ve pratik",
                                    icon: "book.closed.fill",
                                    accentColor: .blue,
                                    darkNavy: darkNavy
                                )
                            }
                            
                            NavigationLink(destination: LevelSelectionView()) {
                                FeatureCard(
                                    title: "Kelimeleri Test Et",
                                    subtitle: "Seviyene göre pratik yap",
                                    icon: "checklist",
                                    accentColor: .green,
                                    darkNavy: darkNavy
                                )
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .padding(.horizontal, 20)
        }
        .onAppear { viewModel.fetchUser() }
        .navigationBarBackButtonHidden(true)
        
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Merhaba, \(viewModel.userName)")
                        .font(.system(size: 30, weight: .medium, design: .rounded))
                        .foregroundColor(darkNavy)
                        .bold()
                    
                }
            }
    
        }
        .padding(.bottom, 10)
    }
    
    private var summaryView: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Öğrenme Yolculuğun")
                    .font(.system(size: 15, weight: .bold, design: .rounded)) 
                    .foregroundColor(darkNavy)
                
                Text("Bugün \(vm.learnedWordsInDictionary.count) yeni kelimeye göz attın.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(darkNavy.opacity(0.7))
            }
            Spacer()
            
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(darkNavy)
        }
        .padding(.all, 25)
        .background(Color.white.opacity(0.25))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
        )
    }
}



struct FeatureCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let darkNavy: Color
    
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(darkNavy)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(darkNavy.opacity(0.6))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right.circle.fill")
                .font(.title2)
                .foregroundStyle(darkNavy.opacity(0.2))
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.85))
        )
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    NavigationStack {
        MainDashboardView()
            .environmentObject(AppCoordinatorViewModel())
            .environmentObject(DailyLessonViewModel())
    }
}
