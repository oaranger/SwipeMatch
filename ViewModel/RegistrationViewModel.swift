//
//  RegistrationViewModel.swift
//  SwipeMatchFirestore
//
//  Created by Binh Huynh on 1/26/19.
//  Copyright © 2019 Binh Huynh. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class RegistrationViewModel {
    
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    var bindableIsRegistering = Bindable<Bool>()
    
    var fullName: String? { didSet { checkFormValidity() } }
    var email: String? { didSet { checkFormValidity() } }
    var password: String? { didSet { checkFormValidity() } }
    
    fileprivate func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false
        bindableIsFormValid.value = isFormValid
    }
    
    func performRegistration(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        bindableIsRegistering.value = true
        Auth.auth().createUser(withEmail: email, password: password) { (dataResult, error) in
            if let error = error {
                completion(error)
                return
            }
            print("Successfully create user", dataResult?.user.uid)
            self.saveImageToFirebase(completion: { (error) in
                completion(error)
            })
        }
    }
    
    fileprivate func saveImageToFirebase(completion: @escaping (Error?) -> ()) {
        let fileName = UUID().uuidString
        let ref = Storage.storage().reference().child("/images/\(fileName)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        ref.putData(imageData, metadata: nil, completion: { (_, error) in
            if let error = error {
                completion(error)
                return
            }
            print("Finished uploading image")
            ref.downloadURL(completion: { (url, error) in
                if let error = error {
                    completion(error)
                    return
                }
                self.bindableIsRegistering.value = false
                print("Download URL of our image is ", url?.absoluteString ?? "")
                // store the downloadURL into Firestore next lesson
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
            })
        })
    }
    
    fileprivate func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) -> ()) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData = ["fullName": fullName ?? "", "uid": uid, "imageUrl": imageUrl]
        Firestore.firestore().collection("users").document(uid).setData(docData) { (error) in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
}
