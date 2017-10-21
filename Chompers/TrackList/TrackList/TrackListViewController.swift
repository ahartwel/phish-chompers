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
        self.viewInstance.bindTo(model: self.viewModel, withActions: self.viewModel)
        self.setUpSearch()
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
        self.viewModel.filterTracks(withSearchString: searchController.searchBar.text ?? "")
    }
}

extension TrackListController: TrackListViewModelDelegate {

}
