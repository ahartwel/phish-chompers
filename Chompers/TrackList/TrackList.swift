//
//  TrackList.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/11/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit
import ionicons
class TrackList: SimpleList, ServiceInjector, AudioPlayerInjector, DownloadManagerInjector {
    typealias ListItem = Track
    var show: Show
    weak var viewController: UIViewController?
    
    var title: String {
        return self.show.title
    }
    
    init(show: Show) {
        self.show = show
    }
    
    func getModels() -> Promise<[ListItem]> {
        if let tracks = self.show.tracks {
            return Promise(value: tracks)
        }
        return self.service.getShow(byId: self.show.id).then { show -> [Track] in
            self.show = show
            let tracks = show.tracks ?? []
            return tracks.sorted(by: { track1, track2 -> Bool in
                return track1.set < track2.set
            })
        }
    }
    
    func setUp(viewController: UIViewController) {
        self.viewController = viewController
        let optionsImage = IonIcons.image(withIcon: ion_ios_more, size: 36, color: .black)
        let rightBarButtonItem = UIBarButtonItem(image: optionsImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.clickedOptions))
        viewController.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func clickedOptions() {
        let alert = UIAlertController(title: "Show Options", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        if self.show.isDownloaded == false || self.show.isDownloaded == nil {
            alert.addAction(UIAlertAction(title: "Download Show", style: UIAlertActionStyle.default, handler: { action in
                self.downloadManager.download(show: self.show)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.viewController?.present(alert, animated: true, completion: nil)
    }
    
    static func createCell(tableView: UITableView, indexPath: IndexPath, models: [ListItem]) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.reuseIdentifier!, for: indexPath)
        let setNames = self.getArrayOfSetNames(models: models)
        let trackDict = self.getDictionaryOfTracks(models: models)
        let currentSet = setNames[indexPath.section]
        if let track: Track = trackDict[currentSet]?[indexPath.row] {
            cell.textLabel?.text = track.title
        }
        return cell
    }
    func preformDelegateAction(forIndex index: IndexPath, models: [ListItem], delegate: ListViewModelDelegate) {
        let setNames = TrackList.getArrayOfSetNames(models: models)
        let trackDict = TrackList.getDictionaryOfTracks(models: models)
        let currentSet = setNames[index.section]
        guard let track: Track = trackDict[currentSet]?[index.row] else {
            return
        }
        self.audioPlayer.play(track: track, fromShow: self.show)
        self.addOtherTracksToQueue(track)
    }
    
    func addOtherTracksToQueue(_ track: Track) {
        var otherTracks = self.show.tracks ?? []
        if let index = otherTracks.index(where: { t in
            return track.id == t.id
        }) {
            otherTracks.remove(at: index)
            for track in otherTracks {
                self.audioPlayer.add(trackToQueue: track, fromShow: self.show)
            }
        }
    }
    
    static func numberOfSections(models: [ListItem]) -> Int {
        return self.getArrayOfSetNames(models: models).count
    }
    
    static func numberOfRowsInSection(section: Int, models: [ListItem]) -> Int {
        let trackDict: [String: [Track]] = self.getDictionaryOfTracks(models: models)
        let name = self.getArrayOfSetNames(models: models)[section]
        return trackDict[name]?.count ?? 0
    }
    
    typealias SetName = String
    static func getDictionaryOfTracks(models: [ListItem]) -> [SetName: [Track]] {
        var trackDict: [SetName: [Track]] = [:]
        models.forEach({ track in
            trackDict[track.set_name, default: []].append(track)
        })
        return trackDict
    }
    
    static func getArrayOfSetNames(models: [ListItem]) -> [SetName] {
        var sets: [SetName] = []
        models.forEach({ track in
            if (!sets.contains(track.set_name)) {
                sets.append(track.set_name)
            }
        })
        return sets
    }
    
    static func titleForHeader(inSection section: Int, items: [ListItem]) -> String? {
        return self.getArrayOfSetNames(models: items)[section]
    }
}
