// AppCoordinatorViewModel.swift

import Foundation
import FirebaseAuth
import Combine

class AppCoordinatorViewModel:ObservableObject{
    @Published var isAuthenticated: Bool? = nil
    
    init(){
        checkAuthenticationState()
    }
    
    func checkAuthenticationState(){
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self=self else{ return }
            
            DispatchQueue.main.async { //iş sırası
                if user != nil{
                    self.isAuthenticated=true
                }
                else {
                    self.isAuthenticated=false
                }
            }
        }
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
            print(" ÇIKIŞ BAŞARILI: Kullanıcı oturumu kapatıldı. ---") // Log'u detaylandırın
        }
        catch let signOutError as NSError{
            // KRİTİK: Hatanın detayını konsola yazdırın
            print("ÇIKIŞ HATASI GÖZLENDİ: \(signOutError.localizedDescription) ---")
        }
    }
}
