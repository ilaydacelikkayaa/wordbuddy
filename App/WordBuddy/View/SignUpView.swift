import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = SignUpViewModel()
    var body: some View {
        ScrollView {
            VStack {
                Image("welcome aesthetic").resizable().scaledToFit().frame(width: 600, height: 200)
                
                Text("Create your profile")
                    .font(.title2).foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3)).bold().padding(.top, 1)
                
                VStack(alignment: .leading, spacing: 5) {
                    
                    Text("User Name")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    TextField("enter your user name", text: $viewModel.username)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .font(.caption)
                    Text("Password")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    SecureField("enter your password", text: $viewModel.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .font(.caption)
                        .textContentType(.newPassword)
                    
                    Text("Confirm Password")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    SecureField("enter your password again", text: $viewModel.confirmPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .font(.caption)
                        .textContentType(.newPassword)
                    
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    TextField("enter your gmail", text: $viewModel.email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .font(.caption)
                        .onChange(of: viewModel.email){
                            _,newValue in
                            viewModel.EmailChange(newValue: newValue)
                        }
                    
                    Text("Phone Number")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    TextField("enter your phone number", text: $viewModel.phoneNumber)
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
                            Text("Sign Up")
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
                
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .fullScreenCover(isPresented: $viewModel.isSignedUp) {
            Text("Kayıt Başarılı! Hoş Geldiniz.") // Yerine ileride ana sayfanız gelecek.
        }
    }
}
#Preview {
    SignUpView()
}
