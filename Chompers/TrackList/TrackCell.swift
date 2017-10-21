//
//  TrackCell.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/21/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import UIKit
import Bond
import ReactiveKit
import ionicons

class TrackCell: UITableViewCell, DownloadManagerInjector, AudioPlayerInjector {
    static var reuseIdentifier: String? {
        return "TrackCell"
    }
    
    lazy var currentlyPlayingButton: UIImageView = {
        var image = UIImageView()
        image.image = IonIcons.image(withIcon: ion_ios_recording, size: 24, color: UIColor.psych1)
        image.contentMode = UIViewContentMode.center
        return image
    }()
    
    var track: Track?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        self.didLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.didLoad()
    }
    
    func setUp(withTrack track: Track) {
        self.track = track
        
        
        self.downloadManager.downloadProgress.observeNext(with: { trackAndProgress in
            if trackAndProgress.track.id != track.id {
                return
            }
            if trackAndProgress.progress < 1 {
                self.detailTextLabel?.text = "\(Int(trackAndProgress.progress * 100))%"
            } else {
                self.detailTextLabel?.text = track.durationString
            }
        }).dispose(in: self.bag)
       
        self.audioPlayer.currentTrack.observeNext(with: { t in
            guard let t = t, track.id == t.id else {
                self.accessoryView = nil
                self.currentlyPlayingButton.alpha = 0
                return
            }
            self.accessoryView = self.currentlyPlayingButton
            self.currentlyPlayingButton.alpha = 1
            
        }).dispose(in: self.bag)
        
        self.textLabel?.text = track.title
        self.detailTextLabel?.text = track.durationString
        
    }
    
    func setDetailTextLabel(forShow show: Show) {
        let venueName = show.venue_name ?? (show.venue?.name ?? "")
        let sdb = "[SBD]"
        let remaster = "[RM]"
        self.detailTextLabel?.text = "\(show.sbd ? sdb : "")\(show.remastered ? remaster : "")\(venueName)"
    }
    
    func didLoad() {
        self.contentView.backgroundColor = UIColor.white
        self.textLabel?.textColor = UIColor.psych1
        self.detailTextLabel?.textColor = UIColor.psych1
        self.contentView.snp.remakeConstraints({ make in
            make.edges.equalTo(self)
        })
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bag.dispose()
    }
    
    override func updateConstraints() {
        let size = UIScreen.main.bounds.width * 0.2
        self.currentlyPlayingButton.frame = CGRect(x: 12, y: 0, width: size, height: size)
        super.updateConstraints()
    }
}
