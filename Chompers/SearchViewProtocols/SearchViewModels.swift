//
//  SearchViewModels.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/22/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit

protocol SearchableControllerActions {
    func updatedSearchText(_ text: String)
}

protocol SearchableItem {
    var searchString: String { get }
}
protocol SearchControllerViewModel: class, SearchableControllerActions {
    associatedtype Item
    var bag: DisposeBag { get set }
    var searchText: Observable<String> { get }
    var itemsToFilter: Observable<[Item]> { get }
    var filteredItems: Signal<[Item], NoError> { get }
    func filterSearchItems(withSearchTerm search: String, items: [Item]) -> [Item]
}

extension SearchControllerViewModel {
    var filteredItems: Signal<[Item], NoError> {
        return combineLatest(self.searchText, self.itemsToFilter) { searchText, items in
            return (search: searchText, items: items)
        }.map({ [unowned self] searchAndItems in
            return self.filterSearchItems(withSearchTerm: searchAndItems.search, items: searchAndItems.items)
        })
    }
    
    func updatedSearchText(_ text: String) {
        self.searchText.value = text
    }
}

extension SearchControllerViewModel where Item: SearchableItem {
    
    func filterSearchItems(withSearchTerm search: String, items: [Item]) -> [Item] {
        let lowercased = search.lowercased()
        return items.filter({
            return lowercased == "" || $0.searchString.lowercased().contains(lowercased)
        })
    }
    
}
