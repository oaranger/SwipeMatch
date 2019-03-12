//
//  CardView.swift
//  SwipeMatchFirestore
//
//  Created by Binh Huynh on 1/23/19.
//  Copyright © 2019 Binh Huynh. All rights reserved.
//

import UIKit
import SDWebImage

protocol CardViewDelegate {
    func didTapMoreInfo(cardViewModel: CardViewModel)
    func didRemoveCard(cardView: CardView)
}

class CardView: UIView {
    
    var nextCardView: CardView?
    var delegate: CardViewDelegate?
    fileprivate let informationLabel = UILabel()
    fileprivate let threshold: CGFloat = 80
    fileprivate let gradientLayer = CAGradientLayer()
    fileprivate let deselectedBarColor = UIColor(white: 0, alpha: 0.1)
    fileprivate let barsStackView = UIStackView()
    
    var cardViewModel: CardViewModel! {
        didSet {
            let imageName = cardViewModel.imageUrls.first ?? ""
            swipingPhotosController.cardViewModel = cardViewModel
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment
            
            (0..<cardViewModel.imageUrls.count).forEach { (_) in
                let barView = UIView()
                barsStackView.addArrangedSubview(barView)
            }
            barsStackView.arrangedSubviews.first?.backgroundColor = .white
            setupImageObserver()
        }
    }
    
    fileprivate let swipingPhotosController = SwipingPhotosController(isCardViewMode: true)
    
    fileprivate func setupImageObserver() {
        cardViewModel.imageIndexObserver = { [weak self] (index, imageUrl) in
            print("Changing photo from viewmodel")
            self?.barsStackView.arrangedSubviews.forEach({ (view) in
                view.backgroundColor = self?.deselectedBarColor
            })
            self?.barsStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }
    
    let moreInfoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "info_icon").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleMoreInfo), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func handleMoreInfo() {
        delegate?.didTapMoreInfo(cardViewModel: self.cardViewModel)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        addGestureRecognizer(panGesture)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc fileprivate func handleTap(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: nil)
        let shouldAdvanceNextPhoto = tapLocation.x > frame.width / 2 ? true : false
        
        if shouldAdvanceNextPhoto {
            cardViewModel.advanceToNextPhoto()
        } else {
            cardViewModel.goToPreviousPhoto()
        }
    }

    override func layoutSubviews() {
        // in here you know what your cardView will be
        gradientLayer.frame = self.frame
    }
    
    fileprivate func setupGradientLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.1]
        layer.addSublayer(gradientLayer)
    }
    
    fileprivate func setupLayout() {
        layer.cornerRadius = 10
        clipsToBounds = true
        
        let swipingPhotosView = swipingPhotosController.view!
        addSubview(swipingPhotosView)
        swipingPhotosView.fillSuperview()
        
        // setup gradient layer
        setupGradientLayer()
        
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16))
        informationLabel.textColor = .white
        informationLabel.numberOfLines = 0
        
        addSubview(moreInfoButton)
        moreInfoButton.anchor(top: nil, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 44, height: 44))
    }
    
    fileprivate func setupBarsStackView() {
        addSubview(barsStackView)
        barsStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
        barsStackView.distribution = .fillEqually
        barsStackView.spacing = 4        
    }
    
    fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
        let shouldDimissCard = abs(gesture.translation(in: nil).x) > threshold
        let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
        
        if shouldDimissCard {
            // hack solution
            guard let homeController = self.delegate as? HomeController else { return }
            if translationDirection == 1 {
                homeController.handleLike()
            } else {
                homeController.handleDislike()
            }
        } else {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                self.transform = .identity
            })
        }
        
//        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
//            if shouldDimissCard {
//                self.frame = CGRect(x: translationDirection * 600, y: 0, width: self.frame.width, height: self.frame.height)
//            } else {
//                self.transform = .identity
//            }
//        }) { (_) in
//            self.transform = .identity
//            if shouldDimissCard {
//                self.removeFromSuperview()
//                //reset topCardView inside of HomeController somwhow
//                self.delegate?.didRemoveCard(cardView: self)
//            }
//        }
    }
    
    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        let degrees: CGFloat = translation.x / 20
        let angle = degrees * .pi / 180
        let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
    }
    
    @objc fileprivate func handleGesture(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            superview?.subviews.forEach({ (view) in
                view.layer.removeAllAnimations()
            })
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture)
        default: ()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
