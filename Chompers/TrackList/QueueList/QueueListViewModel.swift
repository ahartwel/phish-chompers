//
//  QueueListViewModel.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/21/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import PromiseKit

class QueueListViewModel: TrackListViewModel {
    override func loadTracks() {
        guard let queue = self.audioPlayer.audioPlayer.pendingQueue as? [QueueItem] else {
            return
        }
        var tracks = queue.map({ item in
            return item.track
        })
        if let currentItem = self.audioPlayer.currentTrack.value {
            tracks = [currentItem] + tracks.reversed()
        }
        tracks = self.audioPlayer.pastQueue + tracks
        self.originalTracks.value = tracks
    }
}
