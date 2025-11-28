import SwiftUI
import FirebaseAuth
import Combine

struct HomePage: View {
    
    // 1. ViewModel'i View'a bağla ve kullanıcı verilerini çekmesini sağla.
    @StateObject var viewModel = UserProfileViewModel()
    
    // 2. Çıkış yapma fonksiyonu
    func logout() {
        do {
            try Auth.auth().signOut()
            // Auth durumu değiştiği için AppCoordinator bizi SignInView'a yönlendirecek.
        } catch let signOutError as NSError {
            print("Çıkış Yapma Hatası: \(signOutError.localizedDescription)")
        }
    }
    
    var body: some View {
        // NavigationStack'i ContentView'da tanımladığımız için burada tekrar etmiyoruz.
        // Ancak bu View, NavigationStack'ten faydalanacak.
        VStack(spacing: 30) {
            
            // --- 3. Başlık ve Kişiselleştirilmiş Karşılama ---
            
            HStack {
                // Yüklenme Durumu Kontrolü
                if viewModel.isLoading {
                    Text("Hoş Geldiniz!")
                        .font(.largeTitle)
                        .bold()
                } else {
                    // Firestore'dan çekilen kullanıcı adını göster.
                    Text("Merhaba, \(viewModel.userName)!")
                        .font(.largeTitle)
                        .bold()
                }
                Spacer()
                
                // İleride Profil Resmi veya Ayarlar butonu buraya gelebilir
                Button(action: {}) {
                    Image(systemName: "person.circle.fill")
                        .font(.title)
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3))
                }
            }
            .padding(.horizontal)
            .padding(.top, 40)
            
            // Yüklenme animasyonu
            if viewModel.isLoading {
                ProgressView()
                    .padding(.top, 50)
            }
            
            // --- 4. Ana İçerik Butonları (Uygulamanın Özellikleri) ---
            
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
                    // İleride Quiz View'ı buraya gelecek
                    Text("Test Başlatılıyor...")
                } label: {
                    FeatureCard(title: "Bilgileri Test Et", icon: "questionmark.circle.fill", color: .purple)
                }
                
                // 4.3. Kelime Ekleme / Sözlük
                NavigationLink {
                    // İleride Kelime Ekleme/Sözlük View'ı buraya gelecek
                    Text("Sözlüğüm / Yeni Kelime Ekle")
                } label: {
                    FeatureCard(title: "Sözlüğüm", icon: "list.bullet.rectangle.fill", color: .green)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // --- 5. Çıkış Butonu ---
            Button("Çıkış Yap") {
                logout()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
        }
        // 🔥 KRİTİK: View ilk açıldığında veriyi çek
        .onAppear {
            viewModel.fetchUser()
        }
        // NavigationStack'te geri gitme butonunu gizler (isteğe bağlı, daha temiz bir görünüm sağlar)
        .navigationBarBackButtonHidden(true)
    }
}


// Destekleyici Görünüm: Butonları daha düzenli göstermek için
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
    // Preview'ın doğru çalışması için NavigationStack içinde başlatılır.
    NavigationStack {
        HomePage()
    }
}
