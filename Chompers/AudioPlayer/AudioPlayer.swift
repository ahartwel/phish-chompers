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
import AVFoundation
import MediaPlayer

class QueueItem: NSObject {
    var url: URL
    var track: Track
    var show: Show
    init(track: Track, show: Show, downloadManager: DownloadManager) {
        self.track = track
        self.show = show
        if let string = downloadManager.getUrl(forTrack: track) {
            self.url = URL(fileURLWithPath: string)
            return
        }
        self.url = track.link!
    }
}

fileprivate var sharedAudioPlayer: AudioPlayer = AudioPlayer()

protocol AudioPlayerInjector {
    var audioPlayer: AudioPlayer { get }
}

extension AudioPlayerInjector {
    var audioPlayer: AudioPlayer {
        return sharedAudioPlayer
    }
}

class AudioPlayer: NSObject, DownloadManagerInjector {
    var isPlayerActive: Observable<Bool> = Observable<Bool>(false)
    var state: Observable<STKAudioPlayerState> = Observable(.paused)
    var currentTrack: Observable<Track?> = Observable<Track?>(nil)
    var currentShow: Observable<Show?> = Observable<Show?>(nil)
    var currentProgress: Observable<Double> = Observable<Double>(0)
    var currentDuration: Observable<Double> = Observable<Double>(0)
    var changedQueue: Subject<Void, NoError> = Subject<Void, NoError>()
    var didStartPlayingSource: Subject<QueueItem, NoError> = Subject<QueueItem, NoError>()
    var sendQueueChangeEventTimer: Timer?
    var timer: Timer?
    
    lazy var audioPlayer: STKAudioPlayer = STKAudioPlayer()
    
    
    override init() {
        super.init()
        self.audioPlayer.delegate = self
    }
    
    func onAppClose() {
        
    }
    
    func play(track: Track, fromShow show: Show) {
        do {
            if (AVAudioSession.sharedInstance().category != AVAudioSessionCategoryPlayback) {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                UIApplication.shared.beginReceivingRemoteControlEvents()
                try AVAudioSession.sharedInstance().setActive(true)
                self.setUpControlCenter()
            }
        } catch {
        }
        let items = self.getAudioSourceAndQueue(fromTrack: track, andShow: show)
        self.audioPlayer.setDataSource(items.audioSource, withQueueItemId: items.queueItem)
        self.didStartPlayingSource.toSignal().take(first: 1).observe(with: { event in
            self.addOtherTracksToQueue(track, show: show)
            self.sendChangedQueueEvent()
        }).dispose(in: self.bag)
        
    }
    
    func addOtherTracksToQueue(_ track: Track, show: Show) {
        var otherTracks = show.tracks ?? []
        if let index = otherTracks.index(where: { t in
            return track.id == t.id
        }) {
            
            for _ in 0...index {
                if otherTracks.count > 0 {
                    otherTracks.remove(at: 0)
                }
            }
            for otherTrack in otherTracks {
                self.add(trackToQueue: otherTrack, fromShow: show)
            }
        }
    }
    
    func setUpControlCenter() {
        let command = MPRemoteCommandCenter.shared()
        command.playCommand.addTarget(handler: { event in
            self.audioPlayer.resume()
            return MPRemoteCommandHandlerStatus.success
        })
        command.pauseCommand.addTarget(handler: { event in
            self.audioPlayer.pause()
            return MPRemoteCommandHandlerStatus.success
        })
        command.stopCommand.addTarget(handler: { event in
            self.audioPlayer.stop()
            return MPRemoteCommandHandlerStatus.success
        })
        command.nextTrackCommand.addTarget(handler: { event in
            return MPRemoteCommandHandlerStatus.success
        })
    }
    
    func add(trackToQueue track: Track, fromShow show: Show) {
        let items = self.getAudioSourceAndQueue(fromTrack: track, andShow: show)
        self.audioPlayer.queue(items.audioSource, withQueueItemId: items.queueItem)
    }
    
    func sendChangedQueueEvent() {
        self.sendQueueChangeEventTimer?.invalidate()
        self.sendQueueChangeEventTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { timer in
            self.changedQueue.next(())
        })
    }
    
    func getAudioSourceAndQueue(fromTrack track: Track, andShow show: Show) -> (audioSource: STKDataSource, queueItem: QueueItem) {
        let queue = QueueItem(track: track, show: show, downloadManager: self.downloadManager)
        let audioSource: STKDataSource = STKAudioPlayer.dataSource(from: queue.url)
        return (audioSource: audioSource, queueItem: queue)
    }
    
    func download(track: Track) {
    }
    
    func play() {
        self.audioPlayer.resume()
    }
    
    func next() {
        
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
        
        if state == STKAudioPlayerState.playing {
            self.currentDuration.value = audioPlayer.duration
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
                self.currentProgress.value = audioPlayer.progress
            })
        } else {
            self.timer?.invalidate()
        }
    }
    
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, logInfo line: String) {
        
    }
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didCancelQueuedItems queuedItems: [Any]) {
        
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
        guard let queueItem = queueItemId as? QueueItem else {
            self.currentTrack.value = nil
            self.currentShow.value = nil
            return
        }
        self.didStartPlayingSource.next(queueItem)
        self.currentTrack.value = queueItem.track
        self.currentShow.value = queueItem.show
        self.currentDuration.value = audioPlayer.duration
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: queueItem.track.title,
            MPMediaItemPropertyArtist: "Phish",
            MPMediaItemPropertyPlaybackDuration: queueItem.track.duration,
            MPMediaItemPropertyAlbumTitle: queueItem.show.title
        ]
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        
    }
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
        
        
    }
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, with stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        
    }
}

