//
//  SimpleListCell.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/8/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import UIKit
import ionicons
import ReactiveKit
import Bond


class ListItemCell: UITableViewCell, DownloadManagerInjector, AudioPlayerInjector {
    static var reuseIdentifier: String? {
        return "ListItemCell"
    }
    
    lazy var downloadButton: UIButton = {
       var button = UIButton()
        let downloadImage = IonIcons.image(withIcon: ion_ios_cloud_download_outline, size: 24, color: UIColor.psych1)
        button.setImage(downloadImage, for: .normal)
        button.contentMode = UIViewContentMode.center
        button.addTarget(self, action: #selector(self.tappedDownload), for: .touchUpInside)
        return button
    }()
    
    lazy var currentlyPlayingButton: UIImageView = {
       var image = UIImageView()
        image.image = IonIcons.image(withIcon: ion_ios_recording, size: 24, color: UIColor.psych1)
        image.contentMode = UIViewContentMode.center
        return image
    }()
    
    var didTapDownload: (() -> Void)? {
        didSet {
            if didTapDownload != nil {
                self.downloadButton.alpha = 1
                self.accessoryView = self.downloadButton
                self.setNeedsUpdateConstraints()
            }
        }
    }
    var playerDisposeBag: DisposeBag = DisposeBag()
    var downloaderDisposeBag: DisposeBag = DisposeBag()
    var track: Track? {
        didSet {
            guard let track = self.track else {
                self.downloaderDisposeBag.dispose()
                self.playerDisposeBag.dispose()
                return
            }
            self.listenToDownloadEvents(forTrack: track)
            self.listenToAudioEvents(forTrack: track)
        }
    }
    
    var show: Show? {
        didSet {
            guard let show = self.show else {
                self.downloaderDisposeBag.dispose()
                return
            }
            self.listenToDownloadEvents(forShow: show)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        self.didLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.didLoad()
    }
    
    func listenToAudioEvents(forTrack track: Track) {
        self.audioPlayer.currentTrack.observeNext(with: { t in
            if t?.id == track.id {
                self.accessoryView = self.currentlyPlayingButton
            } else {
                self.accessoryView = nil
            }
        }).dispose(in: self.playerDisposeBag)
    }
    
    func listenToDownloadEvents(forTrack track: Track) {
        self.downloadManager.downloadProgress.observeNext(with: { t, progress in
            if t.id == track.id {
                self.detailTextLabel?.text = "\(Int(progress * 100).description)%"
                if progress == 1 {
                    self.detailTextLabel?.text = nil
                }
            }
        }).dispose(in: self.downloaderDisposeBag)
    }
    
    func listenToDownloadEvents(forShow show: Show) {
        self.downloadManager.downloadingShow.observeNext(with: { (progress) in
            if progress.show.id == show.id {
                if progress.complete {
                    self.detailTextLabel?.text = nil
                    self.accessoryView = nil
                } else {
                    self.detailTextLabel?.text = "Downloading..."
                }
            }
        }).dispose(in: self.downloaderDisposeBag)
    }
    
    func didLoad() {
        self.contentView.backgroundColor = UIColor.white
        self.textLabel?.textColor = UIColor.psych1
        self.detailTextLabel?.textColor = UIColor.psych1
        self.contentView.snp.remakeConstraints({ make in
            make.edges.equalTo(self)
        })
    }
    
    @objc func tappedDownload() {
        self.didTapDownload?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.didTapDownload = nil
        self.downloadButton.alpha = 0
        self.track = nil
    }
    
    override func updateConstraints() {
        let size = UIScreen.main.bounds.width * 0.2
        self.downloadButton.frame = CGRect(x: 12, y: 0, width: size, height: size)
        self.currentlyPlayingButton.frame = CGRect(x: 0, y: 0, width: size, height: size)
        super.updateConstraints()
    }
}
