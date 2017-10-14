//
//  SimpleListViewModel.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/8/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import ReactiveKit
import Bond
import PromiseKit

class ListViewModel<T: SimpleList>: ListActions {
    private var originalListsings: Observable<[T.ListItem]> = Observable<[T.ListItem]>([])
    private var currentSearch: Observable<String?> = Observable<String?>(nil)
    var listings: Observable<[T.ListItem]> = Observable<[T.ListItem]>([])
    var delegate: ListViewModelDelegate?
    var list: T
    var disposeBag: DisposeBag = DisposeBag()
    init(list: T) {
        self.list = list
        self.listenToModelUpdates()
        self.loadModels()
    }
    
    func didAppear() {
        self.loadModels()
    }
    
    func loadModels() {
        self.list.getModels().then { models -> Void in
            self.originalListsings.value = models
            }.catch { error -> Void in
                
        }
    }
    
    func listenToModelUpdates() {
        combineLatest(self.currentSearch, self.originalListsings).observeNext(with: { search, listings in
            guard let search = search else {
                self.listings.value = listings
                return
            }
            self.filterListsings(forSearch: search, listings: listings)
        }).dispose(in: self.disposeBag)
    }
    
    func filterListsings(forSearch search: String, listings: [T.ListItem]) {
        if search == "" {
            self.listings.value = listings
            return
        }
        var filteredList: [T.ListItem] = []
        for listing in self.originalListsings.value {
            if self.list.getSearchText(forModel: listing).lowercased().contains(search.lowercased()) {
                filteredList.append(listing)
            }
        }
        self.listings.value = filteredList
    }
    
    func selectedListing(atIndex index: IndexPath) {
        guard let delegate = self.delegate else {
            return
        }
        self.list.preformDelegateAction(forIndex: index, models: self.listings.value, delegate: delegate)
    }
    
    func updateModels(forSearch search: String) {
        self.currentSearch.value = search
    }
    
}


protocol ListViewModelDelegate {
    func pushListings(forYear year: String)
    func pushListing(forShow show: Show)
    //    func presentListings(withEra era: Era, downloaded: Bool)
    //    func presentListings(forYear year: String, andEra era: Era?, downloaded: Bool)
    //    func presentShowDetail(forShow show: Show, downloaded: Bool)
}

protocol ListActions {
    func selectedListing(atIndex index: IndexPath)
    func didAppear()
}
