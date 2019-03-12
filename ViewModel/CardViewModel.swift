//
//  CardViewModel.swift
//  SwipeMatchFirestore
//
//  Created by Binh Huynh on 1/24/19.
//  Copyright © 2019 Binh Huynh. All rights reserved.
//

import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

class CardViewModel {
    let imageUrls: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    let uid: String
    init(uid: String, imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.uid = uid
        self.imageUrls = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
    
    var imageIndexObserver: ((Int, String?) -> ())?
    
    fileprivate var imageIndex = 0 {
        didSet {
            let imageUrl = imageUrls[imageIndex]
            imageIndexObserver?(imageIndex,imageUrl)
        }
    }
    func advanceToNextPhoto() {
        imageIndex = min(imageIndex + 1, imageUrls.count - 1)
    }
    func goToPreviousPhoto() {
        imageIndex = max(0, imageIndex - 1)
    }
}

