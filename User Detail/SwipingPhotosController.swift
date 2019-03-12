//
//  SwipingPhotosController.swift
//  SwipeMatchFirestore
//
//  Created by Binh Huynh on 2/11/19.
//  Copyright © 2019 Binh Huynh. All rights reserved.
//


import UIKit

class SwipingPhotosController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var cardViewModel: CardViewModel! {
        didSet {
            print(cardViewModel.attributedString)
            controllers = cardViewModel.imageUrls.map({ (imageUrl) -> UIViewController in
                let photoController = PhotoController(imageUrl: imageUrl)
                return photoController
            })
            setViewControllers([controllers.first!], direction: .forward, animated: false)
            setupBarViews()
        }
    }
    
    var controllers = [UIViewController()] // blank array
    
    fileprivate let isCardViewMode: Bool
    
    init(isCardViewMode: Bool = false) {
        self.isCardViewMode = isCardViewMode
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate let barsStackView = UIStackView(arrangedSubviews: [])
    fileprivate let deselectedBarColor = UIColor(white: 0, alpha: 0.1)
    
    fileprivate func setupBarViews() {
        cardViewModel.imageUrls.forEach { (_) in
            let barView = UIView()
            barView.backgroundColor = deselectedBarColor
            barView.layer.cornerRadius = 2
            barsStackView.addArrangedSubview(barView)
        }
        barsStackView.arrangedSubviews.first?.backgroundColor = . white
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
        
        view.addSubview(barsStackView)
        var paddingTop: CGFloat = 8
        if !isCardViewMode {
            paddingTop += UIApplication.shared.statusBarFrame.height
        }
        barsStackView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets.init(top: paddingTop, left: 8, bottom: 0, right: 8), size: CGSize.init(width: 0, height: 4))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        view.backgroundColor = .white
        
        if isCardViewMode {
            disableSwipingAbility()
        }
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc fileprivate func handleTap(gesture: UITapGestureRecognizer) {
        print("Cycle thru photo")
        let currentViewController = viewControllers!.first!
        if let index = controllers.firstIndex(of: currentViewController) {
            
            barsStackView.arrangedSubviews.forEach { (view) in
                view.backgroundColor = deselectedBarColor
            }
            
            if gesture.location(in: self.view).x > view.frame.width / 2 {
                let nextIndex = min(index + 1, controllers.count - 1)
                let nextController = controllers[nextIndex]
                setViewControllers([nextController], direction: .forward, animated: false)
                barsStackView.arrangedSubviews[nextIndex].backgroundColor = .white
            } else {
                let previousIndex = max(index - 1, 0)
                let nextController = controllers[previousIndex]
                setViewControllers([nextController], direction: .forward, animated: false)              
                barsStackView.arrangedSubviews[previousIndex].backgroundColor = .white
            }
        }
    }
    
    fileprivate func disableSwipingAbility() {
        view.subviews.forEach { (v) in
            if let v = v as? UIScrollView {
                v.isScrollEnabled = false
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        print("Page transition completed")
        let currentPhotoController = viewControllers?.first
        if let index = controllers.firstIndex(where: { (viewController) -> Bool in
            viewController == currentPhotoController
        }) {
            barsStackView.arrangedSubviews.forEach { (view) in
                view.backgroundColor = deselectedBarColor
            }
            barsStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == controllers.count - 1 { return nil }
        return controllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == 0 { return nil }
        return controllers[index - 1]
    }
}

class PhotoController: UIViewController {
    
    var imageView = UIImageView(image: #imageLiteral(resourceName: "lady4c"))
    
    // provide initializer that take in an URL
    init(imageUrl: String) {
        if let url = URL(string: imageUrl) {
            imageView.sd_setImage(with: url)            
        }
        super.init(nibName: nil, bundle: nil)
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        view.addSubview(imageView)
        imageView.fillSuperview()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


