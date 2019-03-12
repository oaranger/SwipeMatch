//
//  ViewController.swift
//  SwipeMatchFirestore
//
//  Created by Binh Huynh on 1/23/19.
//  Copyright © 2019 Binh Huynh. All rights reserved.
//

import UIKit

class HomeController: UIViewController {
    
    let topStackView = TopNavigationStackView()
    let cardDeckView = UIView()
    let bottomStackView = HomeBottomControlStackView()
    
    let users = [
        User(name: "Kelly", age: 23, profession: "Music DJ", imageName: "lady5c"),
        User(name: "Jane", age: 18, profession: "Chef", imageName: "lady4c")
    ]
    
    fileprivate func setupLayout() {
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardDeckView, bottomStackView])
        view.addSubview(overallStackView)
        overallStackView.axis = .vertical
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        overallStackView.bringSubviewToFront(cardDeckView)
    }
    
    fileprivate func setupDummyCard() {
        users.forEach { (user) in
            let cardView = CardView(frame: .zero)
            cardView.imageView.image = UIImage(named: user.imageName)
            
            let attributedText = NSMutableAttributedString(string: user.name, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])
            
            attributedText.append(NSAttributedString(string: " \(user.age)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))
            
            attributedText.append(NSAttributedString(string: "\n \(user.profession)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
            
            cardView.informationLabel.attributedText = attributedText
            cardDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupDummyCard()
    }
}

