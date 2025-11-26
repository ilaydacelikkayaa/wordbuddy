//
//  SignUpViewModel.swift
//  WordBuddy
//
//  Created by İlayda Çelikkaya on 23.11.2025.
//
import FirebaseAuth
import FirebaseFirestore
import Foundation
import Combine //ui ve veri akışını kontrol eder
class SignUpViewModel:ObservableObject{ //viewlar bunu izleyebilsin diye
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var email: String = ""
    @Published var phoneNumber: String = ""
    @Published var errorMessage: String?
    @Published var isSignedUp: Bool = false
    @Published var confirmPassword: String = ""
    @Published var isLoading:Bool=false
    
    func EmailChange(newValue:String){
        guard !newValue.isEmpty else{
            return
        }
        let first=String(newValue.prefix(1)).lowercased()
        let rest=String(newValue.dropFirst())
        email=first+rest
    }
    
    func PhoneNumberChange(newValue:String){
        let filtered = newValue.filter { $0.isNumber }
        phoneNumber = filtered
    }
    
    func signUp(){
        if password != confirmPassword{
            self.errorMessage="Şifreler eşleşmiyor."
            return
        }
        self.isLoading=true
        self.errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password){
            //weak self Eğer ViewModel zaten silinmişse, onu zorla hayatta tutma
            [weak self] authResult,error in
            guard let self=self else{
                return
            }
            self.isLoading=false //buton tekrar aktif
            if let error = error {
                print("Kayıt başarılı olamadı \(error.localizedDescription)")
                
                self.errorMessage = error.localizedDescription
                return
            }
            
            else{ //kayıt başarılı kısmı
                //firestoreda saklamak icin dictionary
                let uid=authResult?.user.uid ?? "Bilinmiyor"
                //Any değerler her tip olabilir
                let userData:[String:Any]=[
                    "uuid": uid,
                    "email":self.email,
                    "userName":self.username,
                    "phoneName":self.phoneNumber,
                    "createdAt":Date().timeIntervalSince1970
                    
                ]
                Firestore.firestore().collection("users").document(uid).setData(userData){
                    firestoreError in
                    self.isLoading=false //yükleme durumunu kapat
                    
                    if let firestoreError=firestoreError{
                        print("Firestore Kayıt Hatası: \(firestoreError.localizedDescription)")
                        self.errorMessage = "Profil kaydedilemedi: \(firestoreError.localizedDescription)"
                    }
                    else{
                        print("Kullanıcı başarıyla kaydedildi")
                    }
                    self.isSignedUp = true
                }
                
            }
            
        }
        
    }
    
}

