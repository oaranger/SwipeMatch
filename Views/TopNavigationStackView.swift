//
//  TopNavigationStackView.swift
//  SwipeMatchFirestore
//
//  Created by Binh Huynh on 1/23/19.
//  Copyright © 2019 Binh Huynh. All rights reserved.
//

import UIKit

class TopNavigationStackView: UIStackView {
    
    let settingButton = UIButton(type: .system)
    let messageButton = UIButton(type: .system)
    let fireImageView = UIImageView(image: #imageLiteral(resourceName: "app_icon").withRenderingMode(.alwaysOriginal))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        fireImageView.contentMode = .scaleAspectFit
        
        distribution = .equalCentering
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        settingButton.setImage(#imageLiteral(resourceName: "top_left_profile").withRenderingMode(.alwaysOriginal), for: .normal)
        messageButton.setImage(#imageLiteral(resourceName: "top_right_messages").withRenderingMode(.alwaysOriginal), for: .normal)
        
        [settingButton, UIView(), fireImageView, UIView(), messageButton].forEach { (view) in
            addArrangedSubview(view)
        }
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
