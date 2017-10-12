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

class DownloadManager: DataCacheInjector {
    typealias ShowName = String
    lazy var downloadedTracks: [ShowName: [Track]] = {
        return self.dataCache.loadCachedResponse(forUrl: "cached tracks") ?? [:]
    }()
    lazy var downloadedShows: [Show] = {
       return self.dataCache.loadCachedResponse(forUrl: "cached shows") ?? []
    }()
    
    func download(show: Show) {
        for track in show.tracks ?? [] {
            self.download(track: track, inShow: show)
        }
    }
    
    func download(track: Track, inShow show: Show) {
        TWRDownloadManager.shared().downloadFile(forURL: track.mp3, progressBlock: { progress in
            print(progress)
        }, completionBlock: { done in
            if !done {
                return
            }
            self.downloadedTracks[show.title, default: []].append(track)
            if !self.downloadedShows.contains(where: { s in
                return show.id == s.id
            }) {
                self.downloadedShows.append(show)
            }
            self.dataCache.cacheResponse(self.downloadedTracks, url: "cached tracks")
            self.dataCache.cacheResponse(self.downloadedShows, url: "cached shows")
        }, enableBackgroundMode: true)
    }
    
    func getUrl(forTrack track: Track) -> String? {
        if TWRDownloadManager.shared().fileExists(forUrl: track.mp3) {
            return TWRDownloadManager.shared().localPath(forFile: track.mp3)
        }
        return nil
    }
    
    func getDownloadedShows() -> [Show] {
        let shows = self.downloadedShows
        let tracks = self.downloadedTracks
        return shows.map({ show in
            var newShow = show
            newShow.tracks = tracks[show.title] ?? []
            newShow.isDownloaded = true
            return newShow
        })
    }
    
    
    
}