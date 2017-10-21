//
//  ShowListViewController.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/21/17.
//Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import PromiseKit
import UIKit

class ShowListController: UIViewController, UISearchResultsUpdating {
    lazy var viewInstance = {
        return ShowListView()
    }()
    
    var viewModel: ShowListViewModel!
    
    convenience init(withYear year: Year) {
        self.init()
        self.title = "Shows in \(year)"
        self.viewModel = ShowListViewModel(delegate: self, year: year)
    }
    
    convenience init(downloaded: ()) {
        self.init()
        self.title = "Downloaded Shows"
        self.viewModel = ShowListViewModel(delegate: self, downloaded: downloaded)
    }
    
    override func loadView() {
        self.view = self.viewInstance
        self.viewInstance.bindTo(model: self.viewModel, withActions: self.viewModel)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.setUpSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewInstance.startAnimations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController?.isActive = false
        }
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
        self.viewModel.searchTextChanged(searchController.searchBar.text ?? "")
    }
}

extension ShowListController: ShowListViewModelDelegate {
    func presentTrackList(forShow show: Show) {
        let controller = TrackListController(show: show)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
