// SettingsView.swift

import SwiftUI
import FirebaseAuth
import Combine

struct SettingsView: View {
    @EnvironmentObject var appCoordinator: AppCoordinatorViewModel
    @StateObject var viewModel = UserProfileViewModel()
    var body: some View {
        
        VStack(spacing: 0) { // Butonu List'in hemen altına koymak için VStack kullandık
            
            List {
                Section(header: Text("Hesap")) {
                    
                    NavigationLink(destination: ChangeProfileView()) {
                        HStack{
                            Image(systemName: "person").foregroundColor(.blue)
                            Text("Profil Bilgileri").padding(.leading)
                        }
                   
                    }
                    
                    NavigationLink(destination: ChangeProfileView()) {
                        HStack{
                            Image(systemName: "lock.fill")
                                .foregroundColor(.blue)
                            Text("Şifre Değiştirme").padding(.leading)
                            
                        }
                       
                    }
                    .foregroundColor(.primary) // Navigasyon rengini düzeltir
                    
                    // 1.3. Abonelik Yönetimi
                    NavigationLink(destination: SubscriptionView() ) {
                        HStack{
                            Image(systemName: "star.fill")
                                .foregroundColor(.blue)
                            Text("Abonelik Yönetimi ").padding(.leading)
                        }
                       
                    }
                    .foregroundColor(.primary)
                }
                
                // --- 2. UYGULAMA AYARLARI Bölümü ---
                Section(header: Text("Uygulama Ayarları")) {
                    
                    NavigationLink(destination: NotificationView()) {
                        HStack{
                            Image(systemName: "bell").foregroundColor(.blue)
                            Text("Bildirim Ayarları").padding(.leading)

                        }
                    }
                    .foregroundColor(.primary)

                    // 2.1. Ses Efektleri (Toggle)
                    Toggle(isOn: $viewModel.isSoundEffectsOn) {
                        Label("Ses Efektleri", systemImage: "speaker.wave.2")
                    }
                    
                    HStack {
                        Label("Uygulama Dili", systemImage: "globe")
                        Spacer()
                        Text(viewModel.selectedLanguage)
                            .foregroundColor(.gray)
                    }
                    
                    // 2.3. Görünüm (Tema)
                    HStack {
                        Label("Görünüm", systemImage: "circle.lefthalf.filled")
                        Spacer()
                        Text(viewModel.selectedAppearance)
                            .foregroundColor(.gray)
                    }
                }
                
                // --- 3. DESTEK VE BİLGİ Bölümü ---
                Section(header: Text("Destek ve Bilgi")) {
                    NavigationLink("Yardım Merkezi") { Text("Yardım Merkezi") }
                        .foregroundColor(.primary)
                    
                
                    
                    NavigationLink("Gizlilik Politikası") { Text("Gizlilik Politikası") }
                        .foregroundColor(.primary)
                }
              

                
            }
            .navigationTitle("Ayarlar")
            // --- 4. ÇIKIŞ YAP Butonu ---
        
            Button() {
                appCoordinator.signOut() // Çıkış işlemini çağır
            } label: {
                Text("Çıkış Yap")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .padding(.top,8)
            .padding(.bottom, 12)


            
        }
    }
}

#Preview {
    // Preview'ın çalışması için environment object'i sağlamayı unutmayın
    NavigationStack {
        SettingsView()
            .environmentObject(AppCoordinatorViewModel())
    }
}
