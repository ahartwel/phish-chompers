//
//  MainTabBarNavigationController.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/21/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import UIKit
class MainTabBarNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    convenience init() {
        self.init(navigationBarClass: PhishNavigationBar.self, toolbarClass: nil)
    }

    static func createWithController(controller: UIViewController) -> MainTabBarNavigationController {
        let navController = MainTabBarNavigationController()
        navController.setViewControllers([
            controller
            ], animated: false)
        return navController
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
    lazy var donutView: DonutView = DonutView()

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
