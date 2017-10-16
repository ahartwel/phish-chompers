//
//  ViewController.swift
//  phishphishphish
//
//  Created by Alex Hartwell on 8/9/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit
import SnapKit
import ionicons

class MainViewModel: AudioPlayerInjector {
    var isPlaying: Observable<Bool> = Observable<Bool>(false)
    var bag: DisposeBag = DisposeBag()
    init() {
        self.audioPlayer.isPlayerActive.observeNext(with: { isActive in
            self.isPlaying.value = isActive
        }).dispose(in: self.bag)
    }
}

class MainViewController: UIViewController {
    
    var mainTabBarController = MainTabBarViewController()
    var audioPlayerController = AudioPlayerController()
    var mainTabBarControllerHeightConstraint: Constraint?
    var viewModel: MainViewModel = MainViewModel()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addAudioPlayerView()
        self.addMainAppController()
        self.setUpChildControllerConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.bool(forKey: "hasLaunched") == false {
            let alert = UIAlertController(title: "Sending Feedback", message: "Shake your phone to take a screenshot and send feedback.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it", style: UIAlertActionStyle.default, handler: { action in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "hasLaunched")
        }
    }
    
    func addAudioPlayerView() {
        self.addChildViewController(self.audioPlayerController)
        self.view.addSubview(self.audioPlayerController.view)
    }
    
    func addMainAppController() {
        self.addChildViewController(self.mainTabBarController)
        self.view.addSubview(self.mainTabBarController.view)
    }
    
    func setUpChildControllerConstraints() {
        
        self.audioPlayerController.view.snp.remakeConstraints({ make in
            make.left.bottom.right.equalTo(self.view)
            make.top.equalTo(self.mainTabBarController.view.snp.bottom)
        })
        
        self.mainTabBarController.view.snp.remakeConstraints({ make in
            make.top.left.right.equalTo(self.view)
            self.mainTabBarControllerHeightConstraint = make.height.equalTo(self.view.frame.height).constraint
        })
        self.mainTabBarController.didMove(toParentViewController: self)
        self.viewModel.isPlaying.observeNext(with: { isPlaying in
            if isPlaying {
                self.mainTabBarControllerHeightConstraint?.update(offset: self.view.frame.height - AudioPlayerController.audioPlayerHeight)
            } else {
                self.mainTabBarControllerHeightConstraint?.update(offset: self.view.frame.height)
            }
        }).dispose(in: self.bag)
    }
    
}

class MainTabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    var viewModel = MainViewModel()
    lazy var yearsList: UIViewController = MainTabBarNavigationController.createListNavigation(withList: YearsList())
    lazy var downloadList: UIViewController = MainTabBarNavigationController.createListNavigation(withList: DownloadedShowList())
    lazy var onThisDayList: UIViewController = MainTabBarNavigationController.createListNavigation(withList: TodayShowList())
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewControllers([
            self.yearsList,
            self.onThisDayList,
            self.downloadList,
            UIViewController()
            ], animated: false)
        self.delegate = self
        self.tabBar.barTintColor = UIColor.psych5
        self.tabBar.items?[0].selectedImage = IonIcons.image(withIcon: ion_calendar, size: 24, color: UIColor.white)
        self.tabBar.items?[0].image = IonIcons.image(withIcon: ion_calendar, size: 24, color: UIColor.white.withAlphaComponent(0.5))
        
        self.tabBar.items?[1].selectedImage = IonIcons.image(withIcon: ion_clock, size: 24, color: UIColor.white)
        self.tabBar.items?[1].image = IonIcons.image(withIcon: ion_clock, size: 24, color: UIColor.white.withAlphaComponent(0.5))
        
        
        self.tabBar.items?[2].selectedImage = IonIcons.image(withIcon: ion_ios_cloud_download, size: 24, color: UIColor.white)
        self.tabBar.items?[2].image = IonIcons.image(withIcon: ion_ios_cloud_download, size: 24, color: UIColor.white.withAlphaComponent(0.5))
        
        
        self.tabBar.items?[3].selectedImage = IonIcons.image(withIcon: ion_ios_help, size: 24, color: UIColor.white)
        self.tabBar.items?[3].image = IonIcons.image(withIcon: ion_ios_help, size: 24, color: UIColor.white.withAlphaComponent(0.5))
        self.tabBar.items?[3].title = "Feedback"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.index(of: item) else {
            return
        }
        if index == 2 {
            AppDelegate.pinpointKit.show(from: self)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return viewController is UINavigationController
    }
}





