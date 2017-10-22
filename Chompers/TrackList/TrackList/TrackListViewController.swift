//
//  TrackListViewController.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/21/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import PromiseKit
import UIKit
import ionicons

class TrackListController: UIViewController, UISearchResultsUpdating {
    lazy var viewInstance = {
        return TrackListView()
    }()
    
    lazy var viewModel: TrackListViewModel = self.createViewModel()
    
    func createViewModel() -> TrackListViewModel {
        return TrackListViewModel(delegate: self, show: self.show)
    }
    
    var show: Show!
    
    convenience init(show: Show) {
        self.init()
        self.show = show
        self.title = show.date
    }
    
    override func loadView() {
        self.view = self.viewInstance
        self.edgesForExtendedLayout = []
        self.viewInstance.bindTo(model: self.viewModel, withActions: self.viewModel)
        self.setUpSearch()
        self.setUpBarButtonItem()
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.viewInstance.startAnimations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController?.isActive = false
        }
    }
    
    func setUpBarButtonItem() {
        let downloadButtonImage = IonIcons.image(withIcon: ion_ios_settings, size: 30, color: .white)
        let barButtonItem = UIBarButtonItem(image: downloadButtonImage!, style: .plain, target: self, action: #selector(self.showMenu))
        self.navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc func showMenu() {
        let alert = UIAlertController(title: "Show Options", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: {
            return self.viewModel.isShowDownloaded() ? "Redownload Show" : "Download Show"
        }(), style: UIAlertActionStyle.default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
            self.viewModel.downloadShow()
        }))
        if self.viewModel.isShowDownloaded() {
            alert.addAction(UIAlertAction(title: "Delete Show", style: .destructive, handler: { _ in
                alert.dismiss(animated: true, completion: nil)
                self.viewModel.deleteShow()
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setUpSearch() {
        if #available(iOS 11.0, *) {
            let search = UISearchController(searchResultsController: nil)
            search.hidesNavigationBarDuringPresentation = false
            search.dimsBackgroundDuringPresentation = false
            search.searchResultsUpdater = self
            self.navigationItem.searchController = search
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.viewModel.updatedSearchText(searchController.searchBar.text ?? "")
    }
}

extension TrackListController: TrackListViewModelDelegate {

}
