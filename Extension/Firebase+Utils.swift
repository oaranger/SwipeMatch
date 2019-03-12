//
//  Firebase+Utils.swift
//  SwipeMatchFirestore
//
//  Created by Binh Huynh on 2/3/19.
//  Copyright © 2019 Binh Huynh. All rights reserved.
//

import FirebaseAuth
import FirebaseFirestore

extension Firestore {
    func fetchCurrentUser(completion: @escaping (User?, Error?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                completion(nil, err)
                return
            }
            
            // fetched our user here
            guard let dictionary = snapshot?.data() else { return }
            let user = User(dictionary: dictionary)
            completion(user, nil)
        }
    }
}
