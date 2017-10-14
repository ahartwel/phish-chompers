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
import ionicons
enum PlayState: Int {
    case play
    case pause
    func getString() -> String {
        switch self {
        case .play:
            return ion_ios_pause
        case .pause:
            return ion_ios_play
        }
    }
}

protocol AudioPlayerViewModelDelegate: class {
    func showQueue()
}

class AudioPlayerViewModel: AudioPlayerInjector {
    var disposeBag = DisposeBag()
    lazy var playPauseButtonText: Observable<String> = {
        let observable = Observable<String>("")
        self.playState.observeNext { playState -> Void in
            observable.value = playState.getString()
            }.dispose(in: self.disposeBag)
        return observable
    }()
    
     var duration: Observable<Double> {
       return self.audioPlayer.currentDuration
    }
    var currentProgress: Observable<Double> {
        return self.audioPlayer.currentProgress
    }
    var currentTrack: Observable<Track?> {
        return self.audioPlayer.currentTrack
    }
    weak var delegate: AudioPlayerViewModelDelegate?
    
    
    
    var playState: Observable<PlayState> = Observable<PlayState>(.play)
    
    init() {
        self.setUpAudioPlayerBindings()
    }
    
    func setUpAudioPlayerBindings() {
        self.audioPlayer.state.observeNext(with: { state in
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
            self.audioPlayer.pause()
        } else {
            self.audioPlayer.play()
        }
    }
    
    func seekTo(time: Float) {
        self.audioPlayer.audioPlayer.seek(toTime: Double(time))
    }
    
    func showQueue() {
        self.delegate?.showQueue()
    }
    func pressedPrevious() {
        self.audioPlayer.previous()
    }
    
    func pressedNext() {
        self.audioPlayer.next()
    }
}

protocol AudioPlayerActions {
    func togglePlayPause()
    func seekTo(time: Float)
    func pressedNext()
    func pressedPrevious()
    func showQueue()
}

class AudioPlayerController: UIViewController, AudioPlayerViewModelDelegate {
    static var audioPlayerHeight: CGFloat = 100
    lazy var audioView: AudioPlayerView = {
        return AudioPlayerView()
    }()
    
    lazy var viewModel = AudioPlayerViewModel()
    
    override func loadView() {
        super.loadView()
        self.view = self.audioView
        self.viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.audioView.bind(to: self.viewModel)
    }
    
    func showQueue() {
        let queue = MainTabBarNavigationController.createListNavigation(withList: QueueTrackList())
        self.parent?.present(queue, animated: true, completion: nil)
    }
    
}


class AudioPlayerView: UIView {
    
    lazy var playPauseButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(AudioPlayerView.pressedPlayPause), for: .touchUpInside)
        return button
    }()
    
    lazy var previousButton: UIButton = {
        let button = UIButton()
        button.setImage(IonIcons.image(withIcon: ion_ios_arrow_left, size: 24, color: .psych1), for: .normal)
        button.addTarget(self, action: #selector(self.pressedPrevous), for: .touchUpInside)
        return button
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setImage(IonIcons.image(withIcon: ion_ios_arrow_right, size: 24, color: .psych1), for: .normal)
        button.addTarget(self, action: #selector(self.pressedNext), for: .touchUpInside)
        return button
    }()
    
    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(self.sliderValueChanged(slider:)), for: .valueChanged)
        slider.isContinuous = false
        slider.maximumTrackTintColor = UIColor.psych1
        slider.minimumTrackTintColor = UIColor.psych1
        return slider
    }()
    
    lazy var durationLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    lazy var upButton: UIImageView = {
        let image = UIImageView()
        image.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedExpand))
        image.addGestureRecognizer(tap)
        image.image = IonIcons.image(withIcon: ion_ios_arrow_up, size: 28, color: .psych1)
        image.contentMode = UIViewContentMode.center
        return image
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
        self.backgroundColor = UIColor.white
        self.addViews()
        self.addConstraints()
    }
    
    func addViews() {
        self.addSubview(self.playPauseButton)
        self.addSubview(self.previousButton)
        self.addSubview(self.nextButton)
        self.addSubview(self.slider)
        self.addSubview(self.durationLabel)
        self.addSubview(self.upButton)
    }
    
    func addConstraints() {
        self.previousButton.snp.remakeConstraints({ make in
            make.left.top.bottom.equalTo(self)
            make.width.equalTo(self).multipliedBy(0.1)
        })
        self.playPauseButton.snp.remakeConstraints({ make in
            make.top.bottom.equalTo(self)
            make.left.equalTo(self.previousButton.snp.right)
            make.width.equalTo(self).multipliedBy(0.1)
        })
        self.nextButton.snp.remakeConstraints({ make in
            make.top.bottom.equalTo(self)
            make.left.equalTo(self.playPauseButton.snp.right)
            make.width.equalTo(self).multipliedBy(0.1)
        })
        self.slider.snp.remakeConstraints({ make in
            make.top.bottom.equalTo(self)
            make.left.equalTo(self.nextButton.snp.right)
            make.right.equalTo(self).inset(UIScreen.main.bounds.width * 0.2)
        })
        self.durationLabel.snp.remakeConstraints({ make in
            make.bottom.equalTo(self)
            make.height.equalTo(self).multipliedBy(0.5)
            make.right.equalTo(self.slider.snp.right)
        })
        self.upButton.snp.remakeConstraints({ make in
            make.right.bottom.equalTo(self)
            make.left.equalTo(self.slider.snp.right)
            make.height.equalTo(self)
        })
    }
    
    @objc func tappedExpand() {
        self.actions?.showQueue()
    }
    
    @objc func pressedPlayPause() {
        self.actions?.togglePlayPause()
    }
    
    @objc func pressedPrevous() {
        self.actions?.pressedPrevious()
    }
    
    @objc func pressedNext() {
        self.actions?.pressedNext()
    }
    
    @objc func sliderValueChanged(slider: UISlider) {
        self.actions?.seekTo(time: slider.value)
    }
    
    func bind(to model: AudioPlayerViewModel) {
        self.actions = model
        model.playPauseButtonText.observeNext(with: { string in
            self.playPauseButton.setImage(IonIcons.image(withIcon: string, size: 36, color: .psych1), for: .normal)
        }).dispose(in: self.bag)
        
        let signal: Signal<(progress: Float, duration: Float), NoError> = combineLatest(model.currentProgress, model.duration) { progress, duration -> (progress: Float, duration: Float) in
            return (progress: Float(progress), duration: Float(duration))
        }
        combineLatest(model.currentTrack, signal) { track, timing in
            return (track: track, timing: timing)
        }.observeNext(with: { obj in
            self.slider.maximumValue = obj.timing.duration
            self.slider.value = obj.timing.progress
            var titleString = obj.track?.title ?? ""
            if titleString != "" {
                titleString += " - "
            }
            self.durationLabel.text = "\(titleString)\(obj.timing.progress.getTimeString())/\(obj.timing.duration.getTimeString())"
        }).dispose(in: self.bag)
       
        
        
    }
    
    
}

extension Float {
    func getTimeString() -> String {
        var string = ""
        let minutes = Int(self / 60)
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        string += "\((minutes < 10 ? "0" : ""))\(minutes):"
        string += "\((seconds < 10 ? "0" : ""))\(seconds)"
        return string
    }
}


