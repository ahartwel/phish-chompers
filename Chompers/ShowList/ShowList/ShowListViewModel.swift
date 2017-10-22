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
protocol ShowListActions: class, SearchableControllerActions {
    func selectedShow(atIndex indexPath: IndexPath)
    func download(show: Show)
    func delete(showAtPath indexPath: IndexPath)
    func isShowDownloaded(AtIndex indexPath: IndexPath) -> Bool
}

protocol ShowListViewModelDelegate: class {
    func presentTrackList(forShow show: Show)
}

class ShowListViewModel: SearchControllerViewModel, ShowListBindables, ServiceInjector, DownloadManagerInjector {
    weak var delegate: ShowListViewModelDelegate?
    var shows: MutableObservableArray<Show> = MutableObservableArray<Show>([])
    
    var searchText: Property<String> = Observable<String>("")
    var itemsToFilter: Property<[Show]> = Observable<[Show]>([])
    
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

    init(delegate: ShowListViewModelDelegate?, onThisDay: Void) {
        self.delegate = delegate
        self.loadOnThisDayShows()
        self.setUpObservables()
    }

    func setUpObservables() {
        self.filteredItems.observeNext(with: { shows in
            self.shows.replace(with: shows, performDiff: true)
        })
    }

    func loadDownloadedShows() {
        _ = self.downloadManager.downloadedShows.observeNext(with: { shows in
            self.itemsToFilter.value = shows
        }).dispose(in: self.bag)
    }

    func loadOnThisDayShows() {
        _ = self.service.getShowsOnThisDay().then { shows in
            self.itemsToFilter.value = shows
        }
    }

    func loadShows() {
        guard let year = self.year else {
            return
        }
        _ = self.service.getShows(fromYear: year).then { shows in
            self.itemsToFilter.value = shows
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

    func delete(showAtPath indexPath: IndexPath) {
        let show = self.shows.array[indexPath.row]
        self.downloadManager.delete(show: show)
    }

    func isShowDownloaded(AtIndex indexPath: IndexPath) -> Bool {
        let show = self.shows.array[indexPath.row]
        return self.downloadManager.downloadedShows.value.contains(show)
    }
}
