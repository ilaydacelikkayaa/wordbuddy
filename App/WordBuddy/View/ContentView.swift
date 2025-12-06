import SwiftUI
struct ContentView: View {
    @StateObject var coordinator = AppCoordinatorViewModel()
    @StateObject var dailyLessonVM = DailyLessonViewModel()

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
                NavigationStack {
                    OnBoardingView()
                }
            }
        }   .environmentObject(coordinator)
            .environmentObject(dailyLessonVM)

    }
}

#Preview {
    ContentView()
    
}
