//
//  YearListController.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/18/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import UIKit
import Bond
import ReactiveKit
import PromiseKit

class YearListController: UIViewController, UISearchResultsUpdating {
    lazy var viewModel: YearViewModel = YearViewModel(delegate: self)
    var yearView: YearListView = YearListView()
    
    override func loadView() {
        self.view = self.yearView
        self.edgesForExtendedLayout = []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpBindings()
        self.setUpSearch()
        self.yearView.bind(to: self.viewModel, withActions: self.viewModel)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.yearView.startAnimations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController?.isActive = false
        }
    }
    
    func setUpBindings() {
        self.viewModel.title.observeNext(with: { title in
            self.title = title
        }).dispose(in: self.bag)
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

extension YearListController: YearListViewModelDelegate {
    func presentDetails(forYear year: Year) {
        let controller = ShowListController(withYear: year)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
