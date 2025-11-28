import SwiftUI

struct ContentView: View {
    @StateObject var coordinator = AppCoordinatorViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                // 1. Durum: Oturum durumu henüz bilinmiyor (Yükleniyor)
                if coordinator.isAuthenticated == nil {
                    ProgressView("Kontrol Ediliyor...")
                }
                // 2. Durum: Oturum Açık
                else if coordinator.isAuthenticated == true {
                    HomePage() // Oturum açıldıktan sonraki ana ekran
                }
                // 3. Durum: Oturum Kapalı
                else {
                    OnBoardingView() // Giriş/Kayıt ekranı
                }
            }
        }
        .environmentObject(coordinator) // Coordinator'ı alt View'lara kolay erişim için ekleyelim
    }
}

#Preview {
    ContentView()
}
