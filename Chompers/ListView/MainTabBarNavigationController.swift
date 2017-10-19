//
//  MainTabBarNavigationController.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/18/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarNavigationController<T: SimpleList>: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    private convenience init() {
        self.init(navigationBarClass: PhishNavigationBar.self, toolbarClass: nil)
    }
    
    static func createListNavigation(withList list: T) -> MainTabBarNavigationController {
        let controller = MainTabBarNavigationController()
        controller.setViewControllers([
            ListController.createList(with: list)
            ], animated: false)
        controller.title = list.title
        return controller
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.navigationBar.prefersLargeTitles = true
            self.navigationBar.largeTitleTextAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor.white
            ]
        }
        
        
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)
        ]
        
    }
}

class PhishNavigationBar: UINavigationBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.didLoad()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.didLoad()
    }
    
    func didLoad() {
        self.backgroundColor = UIColor.psych5
        self.barTintColor = UIColor.psych5
        self.shadowImage = UIImage()
    }
}
