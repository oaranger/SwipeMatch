//
//  ViewController.swift
//  SwipeMatchFirestore
//
//  Created by Binh Huynh on 1/23/19.
//  Copyright © 2019 Binh Huynh. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Firebase
import JGProgressHUD

class HomeController: UIViewController {
    
    let topStackView = TopNavigationStackView()
    let cardDeckView = UIView()
    let bottomControls = HomeBottomControlStackView()
    var cardViewModels = [CardViewModel]()
    
    fileprivate func setupLayout() {
        view.backgroundColor = .white
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardDeckView, bottomControls])
        view.addSubview(overallStackView)
        overallStackView.axis = .vertical
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        overallStackView.bringSubviewToFront(cardDeckView)
    }
    
    fileprivate func setupFirestoreUserCards() {
        cardViewModels.forEach { (cardVM) in
            let cardView = CardView(frame: .zero)
            cardView.cardViewModel = cardVM
            cardDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topStackView.settingButton.addTarget(self, action: #selector(handleSetting), for: .touchUpInside)
        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        bottomControls.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomControls.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        setupLayout()
        fetchCurrentUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view did appear")
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            print("No current User found")
            let registrationController = RegistrationController()
            registrationController.delegate = self
            let navController = UINavigationController(rootViewController: registrationController)
            present(navController, animated: true)
        }
    }
    
    var user: User?
    fileprivate let hud = JGProgressHUD(style: .dark)
    
    fileprivate func fetchCurrentUser() {
        hud.textLabel.text = "Loading..."
        hud.show(in: view)
        cardDeckView.subviews.forEach({$0.removeFromSuperview()})
        Firestore.firestore().fetchCurrentUser { (user, error) in
            if let error = error {
                self.hud.dismiss()
                print("Failed to fetch current user", error)
                return
            }
            self.user = user
            self.fetchSwipes()
//            self.fetchUsersFromFirestore()
        }
    }
    
    @objc fileprivate func handleRefresh() {
        cardDeckView.subviews.forEach({ $0.removeFromSuperview()})
        fetchUsersFromFirestore()
    }
    
    var swipes = [String: Int]()
    
    fileprivate func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print("Failed to fetch swipes info for currently logged in user:", error)
                return
            }
            print("Swipes: ", snapshot?.data() ?? "")
//            guard let data = snapshot?.data() as? [String: Int] else { return }
            self.swipes = snapshot?.data() as? [String : Int] ?? ["" : 0]
//            self.swipes = data
            self.fetchUsersFromFirestore()
        }
    }
    
    var lastFetchedUser: User?
    
    fileprivate func fetchUsersFromFirestore() {
        let minAge = user?.minSeekingAge ?? SettingController.defaultMinSeekingAge
        let maxAge = user?.maxSeekingAge ?? SettingController.defaultMaxSeekingAge
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThan: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        topCardView = nil
        query.getDocuments { (snapshot, error) in
            self.hud.dismiss()
            if let error = error {
                print("Failed fetching users", error)
                return
            }
            
            var previousCardView: CardView?
            
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
//                let hasNotSwipedBefore = self.swipes[user.uid!] == nil
                let hasNotSwipedBefore = true
                if isNotCurrentUser && hasNotSwipedBefore {
                    let cardView = self.setupCardFromUser(user: user)
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
            })
        }
    }
    
    var topCardView: CardView?
    
    @objc func handleLike() {
        saveSwipeToFirestore(didLike: 1)
        performSwipeAnimation(translation: 700, angle: 15)
    }
    
    @objc func handleDislike() {
        saveSwipeToFirestore(didLike: 0)
        performSwipeAnimation(translation: -700, angle: -15)
    }
    
    fileprivate func saveSwipeToFirestore(didLike: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let cardUID = topCardView?.cardViewModel.uid else { return }
        
        let documentData = [cardUID: didLike]
        
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, error) in
            if let error = error {
                print("Failed to fetch document", error)
                return
            }
            // create new "swipes" or append to currently existed "swipes"
            if snapshot?.exists == true {
                Firestore.firestore().collection("swipes").document(uid).updateData(documentData) { (error) in
                    if let error = error {
                        print("Failed to save swipe data", error)
                    }
                    print("Successfully updated swipe...")
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            } else {
                Firestore.firestore().collection("swipes").document(uid).setData(documentData) { (error) in
                    if let error = error {
                        print("Failed to save swipe data", error)
                    }
                    print("Successfully saved swipe...")
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            }
        }
    }
    
    fileprivate func checkIfMatchExists(cardUID: String) {
        // how to detect our match between tow users?
        Firestore.firestore().collection("swipes").document(cardUID).getDocument { (snapshot, error) in
            if let error = error {
                print("Failed to fetch document for card user:", error)
                return
            }
            guard let data = snapshot?.data() else { return }
            print(data)
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            let hasMatched = data[uid] as? Int == 1
            if hasMatched {
                print("hasMatched")
                self.presentMatchView(cardUID: cardUID)
            }
        }
    }
    
    fileprivate func presentMatchView(cardUID: String) {
        let matchView = MatchView()
        matchView.cardUID = cardUID
        matchView.currentUser = self.user
        view.addSubview(matchView)
        matchView.fillSuperview()
    }
    
    fileprivate func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.5
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        translationAnimation.fillMode = .forwards
        translationAnimation.isRemovedOnCompletion = false
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = 1
        
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        
        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        
        CATransaction.commit()
    }
    
    fileprivate func setupCardFromUser(user: User) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardDeckView.addSubview(cardView)
        cardDeckView.sendSubviewToBack(cardView)
        cardView.fillSuperview()
        return cardView
    }
    
    @objc func handleSetting() {
        let settingController = SettingController()
        let navController = UINavigationController(rootViewController: settingController)
        settingController.delegate = self
        present(navController, animated: true)
    }
}

extension HomeController: SettingsControllerDelegate {
    func didSaveSettings() {
        fetchCurrentUser()
    }
}

extension HomeController: LoginControllerDelegate {
    func didFinishLoggingIn() {
        print("passing logging successfully from HomeController")
        fetchCurrentUser()
    }
}

extension HomeController: CardViewDelegate {
    func didRemoveCard(cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
    }
    
    func didTapMoreInfo(cardViewModel: CardViewModel) {
        print(cardViewModel.attributedString)
        let userDetailsController = UserDetailsController()
        userDetailsController.cardViewModel = cardViewModel
        present(userDetailsController, animated: true)
    }
    
    
}
