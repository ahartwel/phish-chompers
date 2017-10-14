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
    var listings: Observable<[T.ListItem]> = Observable<[T.ListItem]>([])
    var delegate: ListViewModelDelegate?
    var list: T
    
    init(list: T) {
        self.list = list
        self.list.getModels().then { models -> Void in
            self.listings.value = models
            }.catch { error -> Void in
                
        }
    }
    
    func didAppear() {
        _ = self.list.getModels().then { models -> Void in
            self.listings.value = models
        }
    }
    
    func selectedListing(atIndex index: IndexPath) {
        guard let delegate = self.delegate else {
            return
        }
        self.list.preformDelegateAction(forIndex: index, models: self.listings.value, delegate: delegate)
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
