//
//  OnBoardingView.swift
//  WordBuddy
//
//  Created by İlayda Çelikkaya on 21.11.2025.
//

import SwiftUI

struct OnBoardingView: View {
    
    var body: some View {
        NavigationStack{
            VStack{
                HStack(spacing:10){
                    LogoView() .frame(width: 50, height: 50)
                    Text("WordBuddy").bold().font(.title2)
                        .foregroundColor(Color(red: 0, green: 0, blue: 0.5))
                    
                }
                .padding(.top,10)
                
                
                Image("Image").resizable().scaledToFit().frame(maxHeight: 300)
                    .padding(10)
                
                Text("Learn a language in 3 minute a day") .font(.title.bold())  .multilineTextAlignment(.center)    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .foregroundColor(Color(red: 0, green: 0, blue: 0.5))
            }.padding(.horizontal,3)
            
            
            
            NavigationLink{
                SignUpView()
                
            }label:{
                Text("Start Learning")
                    .font(.headline)
                    .frame(maxWidth:300)
                    .padding()
                    .background(Color(red: 0, green: 0, blue: 0.5))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }.padding(.top,60)
            
            HStack(spacing:4){
                Text("Already,have an account").font(.caption).padding(.top,10)
                
                NavigationLink{
                    SignInView()
                }label:{
                    Text("Sign In").font(.caption.bold())
                        .foregroundStyle(Color.blue).padding(.top,10).underline()
                }
                
            }
        }
    }
}

#Preview {
    OnBoardingView()
}
