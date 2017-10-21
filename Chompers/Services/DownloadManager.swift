//
//  DownloadManager.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/11/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import TWRDownloadManager
import ReactiveKit
import Bond

fileprivate var sharedDownloadManager: DownloadManager = DownloadManager()

protocol DownloadManagerInjector {
    var downloadManager: DownloadManager { get }
}
extension DownloadManagerInjector {
    var downloadManager: DownloadManager {
        return sharedDownloadManager
    }
}

class DownloadManager: DataCacheInjector, ServiceInjector {
    typealias ShowName = String
    lazy var downloadedTracks: [ShowName: [Track]] = {
        return self.dataCache.loadCachedResponse(forUrl: "cached tracks") ?? [:]
    }()

    lazy var downloadedShows: Observable<[Show]> = {
        let shows: [Show] = self.dataCache.loadCachedResponse(forUrl: "cached shows") ?? []
        return Observable<[Show]>(shows)
    }()
    var downloadProgress: PublishSubject<(track: Track, progress: CGFloat), NoError> = PublishSubject<(track: Track, progress: CGFloat), NoError>()
    var downloadingShow: PublishSubject<(show: Show, complete: Bool), NoError> = PublishSubject<(show: Show, complete: Bool), NoError>()
    lazy var sortedDownloadedShows: Signal<[Show], NoError> = {
        return self.downloadedShows.map({ [unowned self] shows in
            let tracks = self.downloadedTracks
            return shows.map({ show in
                var newShow = show
                newShow.tracks = tracks[show.title] ?? []
                newShow.isDownloaded = true
                return newShow
            })
        })
    }()

    func delete(show: Show) {
        if (show.sortedTracks ?? []).count == 0 {
            _ = self.service.getShow(byId: show.id).then(execute: { show in
                self.delete(show: show)
            })
            return
        }
        for track in show.sortedTracks ?? [] {
            TWRDownloadManager.shared().cancelDownload(forUrl: track.mp3)
            TWRDownloadManager.shared().deleteFile(forUrl: track.mp3)
            if let index = (self.downloadedTracks[show.title] ?? []).index(of: track) {
                self.downloadedTracks[show.title]?.remove(at: index)
            }

        }
        if let index = self.downloadedShows.value.index(of: show) {
            self.downloadedShows.value.remove(at: index)
        }
        self.saveCache()
    }

    func download(show: Show) {
        if (show.sortedTracks ?? []).count == 0 {
            _ = self.service.getShow(byId: show.id).then(execute: { show in
                self.download(show: show)
            })
            return
        }
        for track in show.sortedTracks ?? [] {
            self.downloadingShow.next((show: show, complete: false))
            self.download(track: track, inShow: show, onComplete: {
                self.downloadingShow.next((show: show, complete: true))
            })
        }
    }

    func download(track: Track, inShow show: Show, onComplete: @escaping () -> Void) {
        TWRDownloadManager.shared().downloadFile(forURL: track.mp3, progressBlock: { progress in
            self.downloadProgress.next((track: track, progress: progress))
            self.downloadingShow.next((show: show, complete: false))
        }, completionBlock: { done in
            if !done {
                return
            }
            onComplete()
            self.downloadProgress.next((track: track, progress: 1))
            self.downloadedTracks[show.title, default: []].append(track)
            if !self.downloadedShows.value.contains(where: { s in
                return show.id == s.id
            }) {
                self.downloadedShows.value.append(show)
            }
            self.saveCache()
        }, enableBackgroundMode: true)
    }

    func saveCache() {
        self.dataCache.cacheResponse(self.downloadedTracks, url: "cached tracks")
        self.dataCache.cacheResponse(self.downloadedShows.value, url: "cached shows")
    }

    func getUrl(forTrack track: Track) -> String? {
        if TWRDownloadManager.shared().fileExists(forUrl: track.mp3) {
            return TWRDownloadManager.shared().localPath(forFile: track.mp3)
        }
        return nil
    }

    func isShowDownloaded(_ show: Show) -> Bool {
        return self.downloadedShows.value.contains(where: { s in
            show.id == s.id
        })
    }

    func getDownloadedShows() -> [Show] {
        let shows = self.downloadedShows
        let tracks = self.downloadedTracks
        return shows.value.map({ show in
            var newShow = show
            newShow.tracks = tracks[show.title] ?? []
            newShow.isDownloaded = true
            return newShow
        })
    }

    func stopDownloads() {
        TWRDownloadManager.shared().cancelAllDownloads()
    }

}
