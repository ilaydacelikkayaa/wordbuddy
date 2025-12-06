import SwiftUI
import FirebaseCore

// 1. AppDelegate sınıfı tanımlanır.
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        return true
    }
}

@main
struct WordBuddyApp: App {
    // 2. AppDelegate'i ana SwiftUI uygulamasına bağlıyoruz.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            // Uygulamanızın başlangıç View'ı
        ContentView()
        }
    }
}
