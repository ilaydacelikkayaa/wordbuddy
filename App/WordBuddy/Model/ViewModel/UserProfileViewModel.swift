//
//  UserProfileViewModel.swift
//  WordBuddy
//
//  Created by İlayda Çelikkaya on 28.11.2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class UserProfileViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var isLoading: Bool = false
    private let db = Firestore.firestore()
    func fetchUser() {
        //oturum açmış kullanıcının id sini almaya çalışıyorum
        guard let uid=Auth.auth().currentUser?.uid else {
            print("Kullanıcı UID'si bulunamadı")
            return
        }
        print("Aktif kullanıcının UID'si:")
        
        db.collection("users").document(uid).getDocument{
            snapshot,error in
            if let error = error {
                print("Doküman alınırken hata oluştu: \(error.localizedDescription)")
                return
            }
            guard let data = snapshot?.data() else {
                print("Doküman verisi bulunamadı.")
                return}
            
            if let name=data["userName"] as? String{
                self.userName=name
                print("Kullanıcı adı:\(name)")
            }
            else{
                print("userName alanı bulunamadı.")
            }
        }
    }
}
