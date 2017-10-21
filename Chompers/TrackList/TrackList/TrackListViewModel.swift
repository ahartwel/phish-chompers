//
//  TrackListViewModel.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/21/17.
//Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import PromiseKit

protocol TrackListBindables {
    var tracks: MutableObservable2DArray<String, Track> { get }
    var show: Observable<Show> { get }
}
protocol TrackListActions: class {
    func selectedTrack(atIndex indexPath: IndexPath)
    func filterTracks(withSearchString search: String)
    func downloadShow()
}

protocol TrackListViewModelDelegate: class {

}

class TrackListViewModel: TrackListBindables, AudioPlayerInjector, ServiceInjector, DownloadManagerInjector {
    weak var delegate: TrackListViewModelDelegate?
    var show: Observable<Show>
    var tracks: MutableObservable2DArray<String, Track> = MutableObservable2DArray<String, Track>([])
    var originalTracks: Observable<[Track]> = Observable<[Track]>([])
    var searchString: Observable<String> = Observable<String>("")
    var bag: DisposeBag = DisposeBag()
    init(delegate: TrackListViewModelDelegate?, show: Show) {
        self.delegate = delegate
        self.show = Observable<Show>(show)
        self.setUpObservables()
        self.loadTracks()
    }

    func loadTracks() {
        _ = self.service.getShow(byId: self.show.value.id).then { show -> Void in
            self.show.value = show
            self.originalTracks.value = show.sortedTracks ?? []
        }
    }

    func setUpObservables() {
        let signal = combineLatest(self.originalTracks, self.searchString) { tracks, search in
            return (tracks: tracks, search: search)
        }
        signal.observeNext(with: { tracksAndSearch in
            self.tracks.batchUpdate { array in
                array.removeAllItemsAndSections()
                let lowercased = tracksAndSearch.search.lowercased()
                var sections: [String: [Track]] = [:]
                var sectionNames: [String] = []
                for track in tracksAndSearch.tracks {
                    if lowercased == "" || track.title.lowercased().contains(lowercased) {
                        if sections[track.set_name] == nil {
                            sectionNames.append(track.set_name)
                        }
                        sections[track.set_name, default: []].append(track)
                    }
                }

                for name in sectionNames {
                    let section = Observable2DArraySection(metadata: name, items: sections[name] ?? [])
                    array.appendSection(section)
                }
            }
        }).dispose(in: self.bag)
    }

}

extension TrackListViewModel: TrackListActions {
    func selectedTrack(atIndex indexPath: IndexPath) {
        let track = self.tracks.sections[indexPath.section].items[indexPath.row]
        self.audioPlayer.play(track: track, fromShow: self.show.value)
    }

    func filterTracks(withSearchString search: String) {
        self.searchString.value = search
    }
    func downloadShow() {
        self.downloadManager.download(show: self.show.value)
    }
    func isShowDownloaded() -> Bool {
        return self.downloadManager.downloadedShows.value.contains(self.show.value)
    }
}
