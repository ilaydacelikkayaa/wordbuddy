// HomePage.swift
import SwiftUI

struct HomePage: View {

    var body: some View {
        
        TabView {
            
            // 1. ANA SAYFA SEKIMESI (Eski içeriğinizin yeni adı)
            NavigationStack {
                MainDashboardView()
            }
            .tabItem {
                Label("Ana Sayfa", systemImage: "house.fill")
            }
            
            // 2. SÖZLÜK SEKİMESİ
            NavigationStack {
                DictionaryView()
            }
            .tabItem {
                Label("Sözlüğüm", systemImage: "list.bullet")
            }
            
            // 3. AYARLAR SEKİMESİ
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Ayarlar", systemImage: "gearshape.fill")
            }
        }

        
    }
}
#Preview {
    
    NavigationStack {
        HomePage()
            .environmentObject(AppCoordinatorViewModel())
            
    }
}
