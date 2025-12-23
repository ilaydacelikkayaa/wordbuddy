import SwiftUI
import PhotosUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var appCoordinator: AppCoordinatorViewModel
    @StateObject var viewModel = UserProfileViewModel()
    
    let darkNavy = Color(red: 25/255, green: 25/255, blue: 112/255)
    let gradientStart = Color(red: 255/255, green: 173/255, blue: 96/255)
    let gradientEnd   = Color(red: 60/255,  green: 190/255, blue: 190/255)
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil
    @State private var newUserName: String = ""
    @State private var showPasswordAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [gradientStart.opacity(0.8), gradientEnd.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        
                        VStack {
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                if let profileImage {
                                    profileImage
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                } else {
                                    ZStack {
                                        Circle().fill(Color.white.opacity(0.4))
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(darkNavy)
                                    }
                                    .frame(width: 120, height: 120)
                                }
                            }
                            .onChange(of: selectedItem) { _ in
                                loadSelectedImage()
                            }
                            
                            Text("Fotoğrafı Değiştir")
                                .font(.caption.bold())
                                .foregroundColor(darkNavy)
                        }
                        .padding(.top, 20)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Kullanıcı Bilgileri").font(.headline).foregroundColor(darkNavy)
                            
                            HStack {
                                Image(systemName: "person").foregroundColor(darkNavy)
                                TextField("Yeni Kullanıcı Adı", text: $newUserName)
                                    .autocorrectionDisabled()
                                
                                Button("Güncelle") {
                                    if !newUserName.isEmpty {
                                        viewModel.updateUserName(newName: newUserName)
                                    }
                                }
                                .font(.footnote.bold())
                                .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Güvenlik").font(.headline).foregroundColor(darkNavy)
                            
                            Button(action: { showPasswordAlert = true }) {
                                HStack {
                                    Image(systemName: "lock.rotation").foregroundColor(.orange)
                                    Text("Şifre Sıfırlama E-postası Gönder")
                                    Spacer()
                                    Image(systemName: "paperplane.fill")
                                }
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tercihler").font(.headline).foregroundColor(darkNavy)
                            
                            VStack(spacing: 0) {
                                Toggle(isOn: $viewModel.isSoundEffectsOn) {
                                    Label("Ses Efektleri", systemImage: "speaker.wave.2")
                                }
                                .padding()
                                
                                Divider()
                                
                                HStack {
                                    Label("Uygulama Dili", systemImage: "globe")
                                    Spacer()
                                    Text("Türkçe").foregroundColor(.secondary)
                                }
                                .padding()
                            }
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(12)
                        }
                        
                        Button(action: { appCoordinator.signOut() }) {
                            Text("Oturumu Kapat")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(12)
                        }
                        .padding(.top, 20)
                        
                        Text("WordBuddy v1.0").font(.caption2).foregroundColor(darkNavy.opacity(0.6))
                    }
                    .padding()
                }
            }
            .alert("Şifre Sıfırlama", isPresented: $showPasswordAlert) {
                            Button("Gönder", role: .none) {
                                viewModel.sendPasswordReset()
                            }
                            Button("Vazgeç", role: .cancel) { }
                        } message: {
                            // Firebase'den anlık e-postayı çekerek kullanıcıya bilgi verir
                            let userEmail = Auth.auth().currentUser?.email ?? "kayıtlı e-posta"
                            Text("\(userEmail) adresine bir şifre sıfırlama bağlantısı gönderilsin mi?")
                        }
            .navigationTitle("Profilim")
            .toolbarBackground(.hidden, for: .navigationBar) // Navigation bar'ı şeffaf yapar
            .onAppear {
                viewModel.fetchUser()
                newUserName = viewModel.userName
            }
        }
    }
    
    private func loadSelectedImage() {
        Task {
            if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    profileImage = Image(uiImage: uiImage)
                }
            }
        }
    }
}
#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AppCoordinatorViewModel())
    }
}
