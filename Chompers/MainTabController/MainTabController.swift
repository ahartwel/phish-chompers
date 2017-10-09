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

class MainViewModel {
    var isPlaying: Observable<Bool> = Observable<Bool>(false)
    var bag: DisposeBag = DisposeBag()
    init() {
        AudioPlayer.shared.isPlayerActive.observeNext(with: { isActive in
            self.isPlaying.value = isActive
        }).dispose(in: self.bag)
    }
}

class MainViewController: UIViewController {
    
    var mainTabBarController = MainTabBarViewController()
    var audioPlayerController = AudioPlayerController()
    var mainTabBarControllerHeightConstraint: Constraint?
    var viewModel: MainViewModel = MainViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addAudioPlayerView()
        self.addMainAppController()
        self.setUpChildControllerConstraints()
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

class MainTabBarViewController: UITabBarController {
    var viewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setViewControllers([
            MainTabBarNavigationController.createListNavigation(withList: YearsList()),
            MainTabBarNavigationController.createListNavigation(withList: EraList())
            ], animated: false)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}





