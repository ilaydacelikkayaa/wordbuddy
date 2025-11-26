import SwiftUI

struct SignInView: View {
    @StateObject var viewModel = SignInViewModel()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                HStack(spacing:12) {
                    LogoView()
                        .frame(width: 60, height: 60)
                    
                    Text("Hello!")
                        .font(.largeTitle.bold())
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3))
                }.padding(.top, 80)
                
                VStack(alignment: .leading, spacing:8){
                    Text("Log in and continue your\nlearning")
                        .font(.title2.weight(.bold))
                        .foregroundColor(Color(.darkGray))
                        .padding(.bottom, 8)
                    
                    
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top,8)
                    
                    TextField("enter your e-mail", text: $viewModel.email)
                        .padding()
                        .textContentType(.none)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .font(.caption)
                        .onChange(of: viewModel.email) {_, newValue in
                            viewModel.EmailChange(newValue: newValue)
                        }
                    
                    Text("Password")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    SecureField("password", text: $viewModel.password)
                        .padding()
                        .font(.caption)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    if let error=viewModel.errorMessage{
                        Text(error).foregroundStyle(Color.red)
                            .font(.caption).padding(.top,5)
                    }
                    
                    Button(action:{
                        viewModel.signIn()
                    }){
                        if viewModel.isLoading{
                            ProgressView() // Yüklenirken ibreyi göster
                                .frame(maxWidth:300)
                                .padding()
                                .background(Color(red: 0, green: 0, blue: 0.5))
                        }
                        else{
                            Text("Continue")
                                .font(.headline)
                                .frame(maxWidth:300)
                                .padding()
                                .background(Color(red: 0, green: 0, blue: 0.5))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 26)
                    .disabled(viewModel.isLoading)
                    
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(.systemGray4))
                        
                        Text("or")
                            .font(.caption)
                            .foregroundColor(Color(.systemGray))
                            .padding(.horizontal, 10)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(.systemGray4))
                    }
                    .padding(.vertical, 16)
                    
                    Button(action:{
                        print("google a giriş yapılıyor")
                    }){
                        HStack {
                            Text("G").bold().foregroundStyle(Color.black)
                            Text("Log in with Google")
                                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3))
                                .underline(true)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    Text("By joining, I declare that I have read and accent the Terms and Privacy Policy")
                        .font(.footnote)
                        .fontWeight(.light)
                        .foregroundStyle(Color.gray)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10) // Metin altına boşluk
                    
                    HStack{
                        Text("Don't have an account yet?")
                            .font(.callout)
                        NavigationLink{
                            SignUpView()
                        } label: {
                            Text("Sign up")
                                .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.3))
                                .underline()
                                .bold()
                                .font(.callout)
                        }
                    }
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40) // 80 yerine daha az bir değer veya hiç boşluk bırakmamak daha esnek olur.
                    
                }
                .padding(.horizontal, 12)
                .padding(.top, 55)
                
            }
        }
        .fullScreenCover(isPresented: $viewModel.isSignedIn) {
            HomePage()
        }
    }
}

#Preview {
    NavigationStack {
        SignInView()
    }
}
