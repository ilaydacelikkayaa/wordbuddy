//
//  SignInViewModel.swift
//  WordBuddy
//
//  Created by İlayda Çelikkaya on 23.11.2025.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
class SignInViewModel:ObservableObject{
    
    @Published var email:String=""
    @Published var password:String=""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isSignedIn: Bool = false
    
    func signIn(){
        self.isLoading=true
        self.errorMessage=nil
        if email.isEmpty || password.isEmpty{
            self.errorMessage="Please fill in all fields"
            self.isLoading=false
            return
        }
        Auth.auth().signIn(withEmail: email, password: password){
            [weak self] authResult,error in
            guard let self=self else{
                return
            }
            self.isLoading=false
            if let error=error{
                print("Giriş hatası: \(error.localizedDescription)")
                self .errorMessage=error.localizedDescription
            }
            else{
                let uid=authResult?.user.uid ?? "Bilinmiyor"
                print("Giriş Başarılı UID: \(uid)")
                self.isSignedIn=true
            }
            
        }
        
    }
    
    func EmailChange(newValue:String){
            guard !newValue.isEmpty else{
                return
            }
            let first=String(newValue.prefix(1)).lowercased()
            let rest=String(newValue.dropFirst())
            email=first+rest
        }
 
    
    
}
