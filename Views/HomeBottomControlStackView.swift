//
//  HomeBottomControlStackView.swift
//  SwipeMatchFirestore
//
//  Created by Binh Huynh on 1/23/19.
//  Copyright © 2019 Binh Huynh. All rights reserved.
//

import UIKit

class HomeBottomControlStackView: UIStackView {
    
    static func createButton(image: UIImage) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }
    
    let refreshButton = createButton(image: #imageLiteral(resourceName: "refresh_circle"))
    let dislikeButton = createButton(image: #imageLiteral(resourceName: "dismiss_circle"))
    let superLikeButton = createButton(image: #imageLiteral(resourceName: "super_like_circle"))
    let likeButton = createButton(image: #imageLiteral(resourceName: "like_circle"))
    let specialButton = createButton(image: #imageLiteral(resourceName: "boost_circle"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        distribution = .fillEqually
        heightAnchor.constraint(equalToConstant: 120).isActive = true
        
        [refreshButton, dislikeButton, superLikeButton, likeButton, specialButton].forEach { (button) in
            addArrangedSubview(button)
        }
        
//        let subviews = [#imageLiteral(resourceName: "refresh_circle"), #imageLiteral(resourceName: "dismiss_circle"), #imageLiteral(resourceName: "super_like_circle"), #imageLiteral(resourceName: "like_circle"), #imageLiteral(resourceName: "boost_circle") ].map { (image) -> UIView in
//            let button = UIButton(type: .system)
//            button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
//            button.imageView?.contentMode = .scaleAspectFill
//            return button
//        }
//
//        subviews.forEach { (view) in
//            addArrangedSubview(view)
//        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}
