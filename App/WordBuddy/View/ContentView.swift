import SwiftUI
struct ContentView: View {
    @StateObject var coordinator = AppCoordinatorViewModel()
    @StateObject var dailyLessonVM = DailyLessonViewModel()
    @AppStorage("hasSeenIntro") var hasSeenIntro: Bool = false
    
    var body: some View {
        Group {
            if coordinator.isAuthenticated == nil {
                ProgressView("Kontrol Ediliyor...")
            }
            
            else if coordinator.isAuthenticated == true {
                NavigationStack {
                  HomePage()
                     
                }
            }
            
            else {
                if !hasSeenIntro{
                    AppIntroView()
                }
                else{
                    NavigationStack {
                            OnBoardingView()
                                        }
                }
               
            }
        }   .environmentObject(coordinator)
            .environmentObject(dailyLessonVM)

    }
}

#Preview {
    ContentView()
    
}
