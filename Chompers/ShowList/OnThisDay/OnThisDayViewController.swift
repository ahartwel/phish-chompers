//
//  OnThisDayViewController.swift
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

class OnThisDayController: UIViewController, UISearchResultsUpdating {
    lazy var viewInstance = {
        return OnThisDayView()
    }()
    
    lazy var viewModel: OnThisDayViewModel = {
        return OnThisDayViewModel(delegate: self)
    }()
    
    override func loadView() {
        self.view = self.viewInstance
        self.title = "On This Day"
        self.viewInstance.bindTo(model: self.viewModel, withActions: self.viewModel)
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

extension OnThisDayController: OnThisDayViewModelDelegate {
    func present(show: Show) {
        let controller = TrackListController(show: show)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
