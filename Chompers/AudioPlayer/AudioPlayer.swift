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
    var didStartDispose: DisposeBag = DisposeBag()
    var didEndPlayingSource: Subject<QueueItem, NoError> = Subject<QueueItem, NoError>()
    var didEndDispose: DisposeBag = DisposeBag()
    var sendQueueChangeEventTimer: Timer?
    var timer: Timer?

    var pendingQueue: [QueueItem] {
        //swiftlint:disable:next force_cast
        return self.audioPlayer.pendingQueue as! [QueueItem]
    }
    
    var pastQueue: [Track] = []

    lazy var audioPlayer: STKAudioPlayer = STKAudioPlayer()

    override init() {
        super.init()
        self.audioPlayer.delegate = self
        self.handleInterruptions()
        self.setUpControlCenter()
    }

    func onAppClose() {

    }

    func play(track: Track, fromShow show: Show) {
        self.setUpAudioSession()
        self.pastQueue = []
        self.didEndDispose.dispose()
        self.didStartPlayingSource.observeNext(with: { [unowned self, track, show] _ in
            self.didStartDispose.dispose()
            self.addOtherTracksToQueue(track, show: show)
            self.sendChangedQueueEvent()
            self.listentToEndEvents()
        }).dispose(in: self.didStartDispose)
        let items = self.getAudioSourceAndQueue(fromTrack: track, andShow: show)
        self.audioPlayer.setDataSource(items.audioSource, withQueueItemId: items.queueItem)
    }

    func setUpAudioSession() {
        do {
            if AVAudioSession.sharedInstance().category != AVAudioSessionCategoryPlayback {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                UIApplication.shared.beginReceivingRemoteControlEvents()
            }
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
        }
    }

    func handleInterruptions() {
        //swiftlint:disable:next line_length
        NotificationCenter.default.reactive.notification(name: Notification.Name.AVAudioSessionInterruption).observeNext(with: { notification in
            guard let info = notification.userInfo,
                let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
                let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
                    return
            }
            if type == AVAudioSessionInterruptionType.began {
                self.pause()
            } else if type == AVAudioSessionInterruptionType.ended {
                guard let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt else {
                        return
                }
                let options = AVAudioSessionInterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    self.play()
                }
            }
        }).dispose(in: self.bag)
    }

    func listentToEndEvents() {
        self.didEndPlayingSource.observeNext(with: { queueItem in
            self.pastQueue.append(queueItem.track)
        }).dispose(in: self.didEndDispose)
    }

    func addOtherTracksToQueue(_ track: Track, show: Show) {
        var otherTracks = show.sortedTracks ?? []
        if let index = otherTracks.index(where: { otherTrack in
            return track.id == otherTrack.id
        }) {

            for _ in 0...index {
                //swiftlint:disable:next for_where
                if otherTracks.count > 0 {
                    if otherTracks[0].id != track.id {
                        self.pastQueue.append(otherTracks[0])
                    }
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
        command.togglePlayPauseCommand.addTarget(handler: { _ in
            if self.state.value == STKAudioPlayerState.playing {
                self.pause()
            } else {
                self.play()
            }
            return MPRemoteCommandHandlerStatus.success
        })
        command.playCommand.addTarget(handler: { _ in
            self.play()
            return MPRemoteCommandHandlerStatus.success
        })
        command.pauseCommand.addTarget(handler: { _ in
            self.pause()
            return MPRemoteCommandHandlerStatus.success
        })
        command.stopCommand.addTarget(handler: { _ in
            self.audioPlayer.stop()
            return MPRemoteCommandHandlerStatus.success
        })
        command.nextTrackCommand.addTarget(handler: { _ in
            self.next()
            return MPRemoteCommandHandlerStatus.success
        })
        command.previousTrackCommand.addTarget(handler: { _ in
            self.previous()
            return MPRemoteCommandHandlerStatus.success
        })
        command.seekForwardCommand.addTarget(handler: { event in
            guard let event = event as? MPSkipIntervalCommandEvent else {
                return MPRemoteCommandHandlerStatus.commandFailed
            }
            let newTime = self.currentDuration.value + event.interval
            self.audioPlayer.seek(toTime: newTime)
            return MPRemoteCommandHandlerStatus.success
        })

        command.seekBackwardCommand.addTarget(handler: { event in
            guard let event = event as? MPSkipIntervalCommandEvent else {
                return MPRemoteCommandHandlerStatus.commandFailed
            }
            let newTime = self.currentDuration.value - event.interval
            self.audioPlayer.seek(toTime: newTime)
            return MPRemoteCommandHandlerStatus.success
        })

        command.changePlaybackPositionCommand.addTarget(handler: { event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else {
                return MPRemoteCommandHandlerStatus.commandFailed
            }
            self.audioPlayer.seek(toTime: event.positionTime)
            return MPRemoteCommandHandlerStatus.success
        })
    }

    func add(trackToQueue track: Track, fromShow show: Show) {
        let items = self.getAudioSourceAndQueue(fromTrack: track, andShow: show)
        self.audioPlayer.queue(items.audioSource, withQueueItemId: items.queueItem)
    }

    func sendChangedQueueEvent() {
        self.sendQueueChangeEventTimer?.invalidate()
        self.sendQueueChangeEventTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { _ in
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
        self.setUpAudioSession()
        self.audioPlayer.resume()
    }

    func next() {
        if self.audioPlayer.pendingQueue.count == 0 {
            return
        }
        guard let queueItem = self.audioPlayer.pendingQueue.last as? QueueItem else {
            return
        }
        self.play(track: queueItem.track, fromShow: queueItem.show)
    }
    func previous() {
        guard let last = self.pastQueue.last, let currentShow = self.currentShow.value else {
            return
        }
        self.play(track: last, fromShow: currentShow)
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
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
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
            MPMediaItemPropertyPlaybackDuration: queueItem.track.duration / 1000,
            MPMediaItemPropertyAlbumTitle: queueItem.show.title + " " + queueItem.show.date
        ]
    }

    func audioPlayer(_ audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
    }
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
    }
    //swiftlint:disable:next line_length
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, with stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        guard let queueItem = queueItemId as? QueueItem else {
            return
        }
        self.currentProgress.value = 0
        self.didEndPlayingSource.next(queueItem)
    }
}
