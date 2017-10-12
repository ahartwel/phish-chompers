//
//  QueueList.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/11/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit
import ionicons

class QueueTrackList: SimpleList, ServiceInjector, AudioPlayerInjector, DownloadManagerInjector {
    weak var viewController: UIViewController?
    
    static func numberOfSections(models: [Track]) -> Int {
        return 1
    }
    
    static func numberOfRowsInSection(section: Int, models: [Track]) -> Int {
        return models.count
    }
    
    static func createCell(tableView: UITableView, indexPath: IndexPath, models: [Track]) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.reuseIdentifier!, for: indexPath)
        let track = models[indexPath.row]
        cell.textLabel?.text = track.title
        return cell
    }
    
    func preformDelegateAction(forIndex index: IndexPath, models: [Track], delegate: ListViewModelDelegate) {
        let track = models[index.row]
        let show = Show(id: -1, date: "", duration: 0, sbd: false, remastered: false, tour_id: -1, venue_id: -1, likes_count: 0, taper_notes: nil, venue_name: nil, location: nil, tags: nil, venue: nil, tracks: models, isDownloaded: false)
        self.audioPlayer.play(track: track, fromShow: show)
    }
    
    func setUp(viewController: UIViewController) {
        self.viewController = viewController
        let downButton = IonIcons.image(withIcon: ion_ios_arrow_down, size: 36, color: .black)
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: downButton, landscapeImagePhone: downButton, style: .plain, target: self, action: #selector(self.dismissViewController))
    }
    @objc func dismissViewController() {
        self.viewController?.dismiss(animated: true, completion: nil)
    }
    
    typealias ListItem = Track
    var title: String {
        return "Queue"
    }
    func getModels() -> Promise<[ListItem]> {
        let queue = self.audioPlayer.audioPlayer.pendingQueue as! [QueueItem]
        var tracks = queue.map({ item in
            return item.track
        })
        if let currentItem = self.audioPlayer.currentTrack.value {
            tracks = [currentItem] + tracks
        }
        return Promise(value: tracks)
    }
    
}
