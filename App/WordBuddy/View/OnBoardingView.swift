import SwiftUI

struct OnBoardingView: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing:10){
                LogoView().frame(width: 50, height: 50)
                Text("WordBuddy")
                    .bold()
                    .font(.system(size: 28, design: .rounded))
                    .foregroundColor(Color(red: 0, green: 0, blue: 0.5))
            }
            .padding(.top, 20)
            
            Image("Image")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 280)
                .padding(.horizontal)
            
            VStack(spacing: 20) {
                Text("Yeni bir dil, yeni bir dünya.")
                    .font(.title2.bold())
                    .foregroundColor(Color(red: 0, green: 0, blue: 0.5))
                
                Text("Günde sadece 3 dakikanı ayırarak kelime dağarcığını eğlenceli testlerle geliştir.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 30)
            }
            .padding(.top, 10)
            
        
            HStack(spacing: 30) {
                VStack {
                    Image(systemName: "bolt.fill").foregroundColor(.orange)
                    Text("Hızlı Pratik").font(.caption2).bold()
                }
                
                VStack {
                    Image(systemName: "star.fill").foregroundColor(.yellow)
                    Text("5000+ Kelime").font(.caption2).bold()
                }
                VStack {
                    Image(systemName: "chart.bar.fill").foregroundColor(.green)
                    Text("Takip Et").font(.caption2).bold()
                }
            }
            .padding(.top, 10)
            .foregroundColor(Color(red: 0, green: 0, blue: 0.5).opacity(0.8))

            Spacer()
            VStack(spacing: 20) {
                NavigationLink {
                    SignUpView()
                } label: {
                    Text("Öğrenmeye Başla")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0, green: 0, blue: 0.5))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 40)
                
                HStack(spacing: 4) {
                    Text("Kayıtlı Hesabın Var mı?")
                        .font(.caption)
                    
                    NavigationLink {
                        SignInView()
                    } label: {
                        Text("Giriş Yap")
                            .font(.caption.bold())
                            .foregroundColor(.blue)
                            .underline()
                    }
                }
            }
            .padding(.bottom, 30)
        }
    }
}


#Preview {
    OnBoardingView()
}
