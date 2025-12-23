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
    @Published var isSoundEffectsOn: Bool = true
    @Published var selectedLanguage: String = "Türkçe" // Uygulama Dili
    @Published var selectedAppearance: String = "Karanlık"
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
    func updateUserName(newName: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // 1. Firebase'i güncelle
        db.collection("users").document(uid).updateData([
            "userName": newName
        ]) { error in
            if let error = error {
                print("Güncelleme hatası: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.userName = newName
                }
            }
        }
    }


    func sendPasswordReset() {
        guard let rawEmail = Auth.auth().currentUser?.email else { return }
        
        let cleanEmail = rawEmail.lowercased()
                                 .trimmingCharacters(in: .whitespacesAndNewlines)
                                 .precomposedStringWithCanonicalMapping // Unicode hatasını çözer
        
        print("DEBUG: Temizlenmiş mail adresi: \(cleanEmail)")
        
        Auth.auth().sendPasswordReset(withEmail: cleanEmail) { error in
            if let error = error {
                print("HATA: \(error.localizedDescription)")
            } else {
                print("BAŞARILI: Mail gönderildi.")
            }
        }
    }
    
}
