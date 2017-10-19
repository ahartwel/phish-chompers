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

protocol YearListActions: class {
    func selected(yearAtIndex index: IndexPath)
    func searchTextChanged(_ text: String)
}

protocol YearListViewModelDelegate: class {
    func presentDetails(forYear year: Year)
}

class YearViewModel: YearsListBindables, ServiceInjector {
    var searchText: Observable<String> = Observable<String>("")
    var eraReturn: Observable<Eras> = Observable<Eras>([:])
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
        let eraSorterSignal: Signal<Eras, NoError> = combineLatest(self.searchText, self.eraReturn) { text, oldEras in
            let lowercasedString = text.lowercased()
            let eras: [EraName] = oldEras.keys.map({ return $0 }).sorted()
            var newEras: Eras = [:]
            for era in eras {
                newEras[era] = oldEras[era]?.filter({ year in
                    return text == "" || year.lowercased().contains(lowercasedString)
                })
            }
            return newEras
        }
        eraSorterSignal.observeNext(with: { eras in
            self.eras.batchUpdate({ array in
                array.removeAllItemsAndSections()
                //we have to sort the eranames so 1.0 is first
                let eraNames: [EraName] = eras.keys.map({ return $0 }).sorted()
                for eraName in eraNames {
                    if let eras = eras[eraName], eras.count > 0 {
                        array.appendSection(Observable2DArraySection(metadata: eraName, items: eras))
                    }
                }
            })
        }).dispose(in: self.bag)
    }
    
    func loadData() {
        _ = self.service.getEras().then(execute: { eras -> Void in
            self.eraReturn.value = eras
        })
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
