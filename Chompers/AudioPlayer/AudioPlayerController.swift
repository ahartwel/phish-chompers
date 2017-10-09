//
//  AudioPlayerController.swift
//  phishphishphish
//
//  Created by Alex Hartwell on 8/13/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import Bond
import ReactiveKit
import StreamingKit

enum PlayState: Int {
    case play
    case pause
    func getString() -> String {
        switch self {
        case .play:
            return "Pause"
        case .pause:
            return "Play"
        }
    }
}

class AudioPlayerViewModel {
    var disposeBag = DisposeBag()
    lazy var playPauseButtonText: Observable<String> = {
        let observable = Observable<String>("")
        self.playState.observeNext { playState -> Void in
            observable.value = playState.getString()
            }.dispose(in: self.disposeBag)
        return observable
    }()
    
    var playState: Observable<PlayState> = Observable<PlayState>(.play)
    
    init() {
        self.setUpAudioPlayerBindings()
    }
    
    func setUpAudioPlayerBindings() {
        AudioPlayer.shared.state.observeNext(with: { state in
            switch state {
            case STKAudioPlayerState.playing:
                self.playState.value = .play
            case STKAudioPlayerState.paused:
                self.playState.value = .pause
            default:
                break
            }
        }).dispose(in: self.disposeBag)
    }
    
}

extension AudioPlayerViewModel: AudioPlayerActions {
    func togglePlayPause() {
        if self.playState.value == .play {
            AudioPlayer.shared.pause()
        } else {
            AudioPlayer.shared.play()
        }
    }
}

protocol AudioPlayerActions {
    func togglePlayPause()
}

class AudioPlayerController: UIViewController {
    static var audioPlayerHeight: CGFloat = 100
    lazy var audioView: AudioPlayerView = {
        return AudioPlayerView()
    }()
    
    lazy var viewModel = AudioPlayerViewModel()
    
    override func loadView() {
        super.loadView()
        self.view = self.audioView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.audioView.bind(to: self.viewModel)
    }
    
    
    
}


class AudioPlayerView: UIView {
    
    lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(AudioPlayerView.pressedPlayPause), for: .touchUpInside)
        return button
    }()
    
    var actions: AudioPlayerActions?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.didLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.didLoad()
    }
    
    func didLoad() {
        self.addViews()
        self.addConstraints()
    }
    
    func addViews() {
        self.addSubview(self.playPauseButton)
    }
    
    func addConstraints() {
        self.playPauseButton.snp.remakeConstraints({ make in
            make.left.top.bottom.equalTo(self)
            make.width.equalTo(UIScreen.main.bounds.width * 0.25)
        })
    }
    
    @objc func pressedPlayPause() {
        self.actions?.togglePlayPause()
    }
    
    func bind(to model: AudioPlayerViewModel) {
        self.actions = model
        model.playPauseButtonText.observeNext(with: { string in
            self.playPauseButton.setTitle(string, for: .normal)
        }).dispose(in: self.bag)
        
    }
    
    
}



