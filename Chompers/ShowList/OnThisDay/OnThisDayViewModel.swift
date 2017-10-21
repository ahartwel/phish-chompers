//
//  OnThisDayViewModel.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/21/17.
//Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import PromiseKit

protocol OnThisDayBindables {
    var shows: MutableObservableArray<Show> { get }
}
protocol OnThisDayActions: class {
    func searchTextChanged(_ text: String)
    func selectedShow(atIndex indexPath: IndexPath)
    func download(show: Show)
}

protocol OnThisDayViewModelDelegate: class {
    func present(show: Show)
}

class OnThisDayViewModel: OnThisDayBindables, DownloadManagerInjector, ServiceInjector {
    weak var delegate: OnThisDayViewModelDelegate?
    
    var shows: MutableObservableArray<Show> = MutableObservableArray<Show>([])
    var orignalShows: Observable<[Show]> = Observable<[Show]>([])
    var searchString: Observable<String> = Observable<String>("")
    
    var bag: DisposeBag = DisposeBag()
    
    init(delegate: OnThisDayViewModelDelegate?) {
        self.delegate = delegate
        self.loadShows()
    }
    
    func setUpObservables() {
        let signal = combineLatest(self.orignalShows, self.searchString) { shows, search in
            return (shows: shows, search: search)
        }
        signal.observeNext(with: { showsAndSearch in
            if showsAndSearch.search == "" {
                self.shows.replace(with: showsAndSearch.shows, performDiff: true)
                return
            }
            let lowercased = showsAndSearch.search.lowercased()
            self.shows.replace(with: showsAndSearch.shows.filter({ show -> Bool in
                let venue = ((show.venue?.name ?? show.venue_name)) ?? ""
                return show.title.lowercased().contains(lowercased) || venue.lowercased().contains(lowercased) || show.date.contains(lowercased)
            }), performDiff: true)
            
        }).dispose(in: self.bag)
    }
    
    func loadShows() {
        _ = self.service.getShowsOnThisDay().then { shows in
            self.shows.replace(with: shows, performDiff: true)
        }
    }
}

extension OnThisDayViewModel: OnThisDayActions {
    func selectedShow(atIndex indexPath: IndexPath) {
        let show = self.shows.array[indexPath.row]
        self.delegate?.present(show: show)
    }
    
    func download(show: Show) {
        self.downloadManager.download(show: show)
    }
    
    func searchTextChanged(_ text: String) {
        self.searchString.value = text
    }
}
