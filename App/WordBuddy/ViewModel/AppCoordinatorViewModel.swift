//
//  AppCoordinatorViewModel.swift
//  WordBuddy
//
//  Created by İlayda Çelikkaya on 26.11.2025.
//
//oturum durumunu yoneten dosya
import Foundation
import FirebaseAuth
import Combine

class AppCoordinatorViewModel:ObservableObject{
    @Published var isAuthenticated: Bool? = nil
    init(){
        checkAuthenticationState()
    }
    func checkAuthenticationState(){
        //oturum fonksiyonu
        Auth.auth().addStateDidChangeListener { [weak self] _, user in //fonksiyon
            guard let self=self
            else{
                return
            }
            if user != nil{
                self.isAuthenticated=true
            }
            else {
                self.isAuthenticated=false
            }
            
        }
    }
}
