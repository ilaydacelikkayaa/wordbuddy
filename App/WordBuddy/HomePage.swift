// HomePage.swift
import SwiftUI

struct HomePage: View {

    var body: some View {
        
        TabView {
            
            NavigationStack {
                MainDashboardView()
            }
            .tabItem {
                Label("Ana Sayfa", systemImage: "house.fill")
            }
            
            NavigationStack {
                DictionaryView()
            }
            .tabItem {
                Label("Sözlüğüm", systemImage: "list.bullet")
            }
            
            NavigationStack {
        ProfileView()
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
