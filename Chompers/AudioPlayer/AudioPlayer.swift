//
//  AudioPlayer.swift
//  phishphishphish
//
//  Created by Alex Hartwell on 8/12/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import StreamingKit
import Bond
import ReactiveKit


class QueueItem: NSObject {
    var url: URL
    var track: Track
    init(track: Track) {
        self.track = track
        self.url = track.link!
    }
}

class AudioPlayer: NSObject {
    var isPlayerActive: Observable<Bool> = Observable<Bool>(false)
    var state: Observable<STKAudioPlayerState> = Observable(.paused)
    var currentTrack: Observable<Track?> = Observable<Track?>(nil)
    lazy var audioPlayer: STKAudioPlayer = STKAudioPlayer()
    static var shared: AudioPlayer = AudioPlayer()
    
    
    override init() {
        super.init()
        self.audioPlayer.delegate = self
    }
    
    func onAppClose() {
        
    }
    
    func play(track: Track, ignoreDownloaded: Bool = false) {
        guard let link = track.link else {
            return
        }
        let audioSource: STKDataSource = STKAudioPlayer.dataSource(from: link)
        let queue = self.audioPlayer.pendingQueue
        self.audioPlayer.setDataSource(audioSource, withQueueItemId: QueueItem(track: track))
        queue.forEach({
            guard let item = $0 as? QueueItem else {
                return
            }
            let audioSource: STKDataSource = STKAudioPlayer.dataSource(from: track.link!)
            self.audioPlayer.queue(audioSource, withQueueItemId: item)
        })
    }
    
    func add(trackToQueue track: Track) {
        guard let link = track.link else {
            return
        }
        let audioSource: STKDataSource = STKAudioPlayer.dataSource(from: link)
        self.audioPlayer.queue(audioSource, withQueueItemId: QueueItem(track: track))
    }
    
    func download(track: Track) {
    }
    
    func play() {
        self.audioPlayer.resume()
    }
    
    func pause() {
        self.audioPlayer.pause()
    }
    
    
}

extension STKAudioPlayerState {
    func isPlayerActive() -> Bool {
        return self == .playing || self == .paused || self == .buffering
    }
}

extension AudioPlayer: STKAudioPlayerDelegate {
    func audioPlayer(_ audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
        if state.isPlayerActive() {
            self.isPlayerActive.value = true
        }
        self.state.value = state
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, logInfo line: String) {
        
    }
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didCancelQueuedItems queuedItems: [Any]) {
        
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
        guard let queueItem = queueItemId as? QueueItem else {
            self.currentTrack.value = nil
            return
        }
        self.currentTrack.value = queueItem.track
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        if let currentQueueItem = audioPlayer.currentlyPlayingQueueItemId() as? QueueItem {
            self.play(track: currentQueueItem.track, ignoreDownloaded: true)
        }
    }
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
        
        
    }
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, with stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        
    }
}

