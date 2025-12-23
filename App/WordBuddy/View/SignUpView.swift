import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = SignUpViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode// 
    var body: some View {
        ScrollView {
            VStack {
                Image("welcome aesthetic").resizable().scaledToFit().frame(width: 600, height: 200)
                
                Text("Profilini Oluştur")
                    .font(.title2).foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3)).bold().padding(.top, 1)
                
                VStack(alignment: .leading, spacing: 5) {
                    
                    Text("Kullanıcı adı")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    TextField("kullanıcı adınızı giriniz", text: $viewModel.username)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .font(.caption)
                    Text("Şifre")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    SecureField("şifrenizi giriniz", text: $viewModel.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .font(.caption)
                        .textContentType(.newPassword)
                    
                    Text("Şifre doğrulama")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    SecureField("şifrenizi tekrar giriniz", text: $viewModel.confirmPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .font(.caption)
                        .textContentType(.newPassword)
                    
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    TextField("e-mailinizi giriniz", text: $viewModel.email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .font(.caption)
                        .onChange(of: viewModel.email){
                            _,newValue in
                            viewModel.EmailChange(newValue: newValue)
                        }
                    
                    Text("Telefon numarası")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    TextField("telefon numaranızı giriniz", text: $viewModel.phoneNumber)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .font(.caption)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .onChange(of: viewModel.phoneNumber){
                            _ , newValue in
                            viewModel.PhoneNumberChange(newValue: newValue)
                        }
                    
                    
                    Button(action: {
                        viewModel.signUp()
                    }) {
                        
                        if viewModel.isLoading{
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        }
                        else{
                            Text("Giriş Yap")
                        }
                        
                    }
                    
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.1, green: 0.1, blue: 0.3))
                    .cornerRadius(10)
                    .padding(.top, 25)
                }
                
                
                
                .padding(.horizontal, 120)
                .padding(.top, 20)
                .onChange(of: viewModel.isSignedUp) { isSuccess in
                    if isSuccess {
                        self.dismiss() // View'ı kapat (NavigationLink ile gelindiyse geri git)
                    }
                }
                
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        
    }
}
#Preview {
    SignUpView()
}
