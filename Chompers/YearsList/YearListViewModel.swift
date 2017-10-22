//
//  YearListViewModel.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/18/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import PromiseKit

protocol YearsListBindables {
    var eras: MutableObservable2DArray<EraName, Year> { get }
    var title: Observable<String> { get }
}

protocol YearListActions: class, SearchableControllerActions {
    func selected(yearAtIndex index: IndexPath)
}

protocol YearListViewModelDelegate: class {
    func presentDetails(forYear year: Year)
}

class YearViewModel: SearchControllerViewModel, YearsListBindables, ServiceInjector {
    
    typealias Items = (EraName, [Year])
    var searchText: Property<String> = Observable<String>("")
    var itemsToFilter: Property<[Items]> = Observable<[Items]>([])
    
    var eras: MutableObservable2DArray<EraName, Year> = MutableObservable2DArray<EraName, Year>([])
    var title: Observable<String> = Observable<String>("Years")
    unowned var delegate: YearListViewModelDelegate

    var bag: DisposeBag = DisposeBag()

    init(delegate: YearListViewModelDelegate) {
        self.delegate = delegate
        self.setUpCombines()
        self.loadData()
    }

    func setUpCombines() {
        self.filteredItems.observeNext(with: { eras in
            self.eras.batchUpdate({ array in
                array.removeAllItemsAndSections()
                let eraSections = eras.sorted(by: { one, two in
                    return one.0 < two.0
                })
                for era in eraSections {
                    array.appendSection(Observable2DArraySection(metadata: era.0, items: era.1))
                }
            })
        }).dispose(in: self.bag)
    }

    func loadData() {
        _ = self.service.getEras().then(execute: { eras -> Void in
            self.itemsToFilter.value = eras.map({ key, value in
                return (key, value)
            })
        })
    }
    
    func filterSearchItems(withSearchTerm search: String, items: [(EraName, [Year])]) -> [(EraName, [Year])] {
        let lowercasedSearch = search.lowercased()
        let mapped = items.map({
            return ($0.0, $0.1.filter({ year in
                return lowercasedSearch == "" || year.lowercased().contains(lowercasedSearch)
            }))
        })
        let emptiesRemoved = mapped.flatMap({
            return $0.1.count > 0 ? $0 : nil
        })
        return emptiesRemoved
    }
}

extension YearViewModel: YearListActions {
    func selected(yearAtIndex index: IndexPath) {
        self.delegate.presentDetails(forYear: self.eras.sections[index.section].items[index.row])
    }
    func searchTextChanged(_ text: String) {
        self.searchText.value = text
    }
}
