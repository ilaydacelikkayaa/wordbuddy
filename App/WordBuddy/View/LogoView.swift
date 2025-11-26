//
//  LogoView.swift
//  WordBuddy
//
//  Created by İlayda Çelikkaya on 19.11.2025.
//

import SwiftUI

struct LogoView: View {
    var body: some View {
        Image("uyglogo.png").resizable().scaledToFit()
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray,lineWidth: 0.1))
            .shadow(radius: 10)
            
        }
}

#Preview {
    LogoView()
}

