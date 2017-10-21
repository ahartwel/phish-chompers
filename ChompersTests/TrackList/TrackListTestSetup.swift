//
//  TrackListTestSetup.swift
//  ChompersDev
//
//  Created by Alex Hartwell on 10/21/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import PromiseKit
#if TESTBUILD
    extension TrackListViewModel {
        var service: PhishInService {
            return MockTrackListService()
        }
        var audioPlayer: AudioPlayer {
            return sharedMockAudio
        }
        var downloadManager: DownloadManager {
            return sharedMockDownloadManager
        }
    }
    
    class AudioPlayerStub: AudioPlayer {
        
    }
     var sharedMockAudio = MockAudioPlayer()
    var sharedMockDownloadManager = MockDownloadManager()
    class MockAudioPlayer: AudioPlayer {
        var calledPlayWithTrack: Track?
        var calledPlayWithShow: Show?
        override func play(track: Track, fromShow show: Show) {
            self.calledPlayWithTrack = track
            self.calledPlayWithShow = show
        }
    }
    
    class MockDownloadManager: DownloadManager {
        var calledDownloadShow: Show?
        override func download(show: Show) {
            self.calledDownloadShow = show
        }
    }
    
    class MockTrackListService: PhishInService {
        static var show: Show {
            let show = Show(venue_name: "Test Venue", date: "12-20-19", tracks: [
                Track(title: "test track", position: 1, set_name: "set 1", id: 1),
                Track(title: "test track 2", position: 2, set_name: "set 1", id: 2),
                Track(title: "test track 3", position: 3, set_name: "set 2", id: 3),
                Track(title: "test track 4", position: 4, set_name: "set 2", id: 4),
                Track(title: "test track 5", position: 5, set_name: "set 2", id: 5),
                Track(title: "test track 6", position: 6, set_name: "encore", id: 6),
                Track(title: "test track 7", position: 7, set_name: "encore", id: 7),
                ], id: 1)
            return show
        }
        override func getShow(byId id: Int) -> Promise<Show> {
            return Promise<Show>(value: MockTrackListService.show)
        }
//        override func getShow(byId id: Int) -> Promise<Show> {
//            let show = Sho
//            
//            return Promise<Show>(show)
//        }
    }
#endif
