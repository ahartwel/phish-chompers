//
//  ShowListViewModel.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/21/17.
//Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import PromiseKit

protocol ShowListBindables {
    var shows: MutableObservableArray<Show> { get }
}
protocol ShowListActions: class {
    func selectedShow(atIndex indexPath: IndexPath)
    func download(show: Show)
    func searchTextChanged(_ text: String)
}

protocol ShowListViewModelDelegate: class {
    func presentTrackList(forShow show: Show)
}

class ShowListViewModel: ShowListBindables, ServiceInjector, DownloadManagerInjector {
    weak var delegate: ShowListViewModelDelegate?
    var originalShows: Observable<[Show]> = Observable<[Show]>([])
    var shows: MutableObservableArray<Show> = MutableObservableArray<Show>([])
    var searchText: Observable<String> = Observable<String>("")
    var year: Year?
    var bag: DisposeBag = DisposeBag()
    init(delegate: ShowListViewModelDelegate?, year: Year) {
        self.delegate = delegate
        self.year = year
        self.loadShows()
        self.setUpObservables()
    }
    init(delegate: ShowListViewModelDelegate?, downloaded: Void) {
        self.delegate = delegate
        self.loadDownloadedShows()
        self.setUpObservables()
    }
    
    func setUpObservables() {
        let signal = combineLatest(self.originalShows, self.searchText) { shows, search in
            return (shows: shows, search: search)
        }
        signal.observeNext(with: { showsAndSearch in
            if showsAndSearch.search == "" {
                self.shows.replace(with: showsAndSearch.shows, performDiff: true)
                return
            }
            let lowercased = showsAndSearch.search.lowercased()
            self.shows.replace(with: showsAndSearch.shows.filter({ show in
                let venueName = (show.venue?.name ?? show.venue_name) ?? ""
                return show.date.contains(lowercased) || venueName.lowercased().contains(lowercased)
            }), performDiff: true)
        }).dispose(in: self.bag)
    }
    
    func loadDownloadedShows() {
        _ = self.downloadManager.downloadedShows.observeNext(with: { shows in
            self.originalShows.value = shows
        }).dispose(in: self.bag)
    }
    
    func loadShows() {
        guard let year = self.year else {
            return
        }
        _ = self.service.getShows(fromYear: year).then { shows in
            self.originalShows.value = shows
        }
    }
}

extension ShowListViewModel: ShowListActions {
    func selectedShow(atIndex indexPath: IndexPath) {
        let show = self.shows.array[indexPath.row]
        self.delegate?.presentTrackList(forShow: show)
    }
    
    func download(show: Show) {
        self.downloadManager.download(show: show)
    }
    
    func searchTextChanged(_ text: String) {
        self.searchText.value = text
    }
}
