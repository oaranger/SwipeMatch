//
//  Bindable.swift
//  SwipeMatchFirestore
//
//  Created by Binh Huynh on 1/27/19.
//  Copyright © 2019 Binh Huynh. All rights reserved.
//

import UIKit

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    var observer: ((T?) -> ())?
    
    func bind(observer: @escaping (T?) -> ()) {
        self.observer = observer
    }
}
