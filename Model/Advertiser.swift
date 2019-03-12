//
//  Advertiser.swift
//  SwipeMatchFirestore
//
//  Created by Binh Huynh on 1/24/19.
//  Copyright © 2019 Binh Huynh. All rights reserved.
//

import UIKit

struct Advertiser: ProducesCardViewModel {
    let title: String
    let brandName: String
    let posterPhotoName: String
    
    func toCardViewModel() -> CardViewModel {
        let attributedString = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 34, weight: .heavy)])
        
        attributedString.append(NSAttributedString(string: "\n\(brandName)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24, weight: .bold)]))
        
        return CardViewModel(uid: "", imageNames: [posterPhotoName], attributedString: attributedString, textAlignment: .center)
    }
}


