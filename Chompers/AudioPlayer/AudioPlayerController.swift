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
}

protocol AudioPlayerActions {
    func togglePlayPause()
    func seekTo(time: Float)
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
    
    lazy var slider: UISlider = {
        let slider = UISlider()
        slider.addTarget(self, action: #selector(self.sliderValueChanged(slider:)), for: .valueChanged)
        slider.isContinuous = false
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
        image.image = IonIcons.image(withIcon: ion_arrow_up_a, size: 24, color: .black)
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
        self.addSubview(self.slider)
        self.addSubview(self.durationLabel)
        self.addSubview(self.upButton)
    }
    
    func addConstraints() {
        self.playPauseButton.snp.remakeConstraints({ make in
            make.left.top.bottom.equalTo(self)
            make.width.equalTo(UIScreen.main.bounds.width * 0.1)
        })
        self.slider.snp.remakeConstraints({ make in
            make.top.bottom.equalTo(self)
            make.left.equalTo(self.playPauseButton.snp.right)
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
    
    @objc func sliderValueChanged(slider: UISlider) {
        self.actions?.seekTo(time: slider.value)
    }
    
    func bind(to model: AudioPlayerViewModel) {
        self.actions = model
        model.playPauseButtonText.observeNext(with: { string in
            self.playPauseButton.setImage(IonIcons.image(withIcon: string, size: 36, color: .black), for: .normal)
        }).dispose(in: self.bag)
        
        let signal: Signal<(progress: Float, duration: Float), NoError> = combineLatest(model.currentProgress, model.duration) { progress, duration -> (progress: Float, duration: Float) in
            return (progress: Float(progress), duration: Float(duration))
        }
        signal.observeNext { (timing) in
            self.slider.maximumValue = timing.duration
            self.slider.value = timing.progress
            self.durationLabel.text = "\(timing.progress.getTimeString())/\(timing.duration.getTimeString())"
            
        }.dispose(in: self.bag)
        
        
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


