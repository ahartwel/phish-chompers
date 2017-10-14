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


class ListItemCell: UITableViewCell, DownloadManagerInjector {
    static var reuseIdentifier: String? {
        return "ListItemCell"
    }
    
    lazy var downloadButton: UIButton = {
       var button = UIButton()
        let downloadImage = IonIcons.image(withIcon: ion_ios_cloud_download, size: 24, color: UIColor.psych1)
        button.setImage(downloadImage, for: .normal)
        button.contentMode = UIViewContentMode.center
        button.addTarget(self, action: #selector(self.tappedDownload), for: .touchUpInside)
        return button
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
    var downloaderDisposeBag: DisposeBag = DisposeBag()
    var track: Track? {
        didSet {
            guard let track = self.track else {
                self.downloaderDisposeBag.dispose()
                return
            }
            self.listenToDownloadEvens(forTrack: track)
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
    
    func listenToDownloadEvens(forTrack track: Track) {
        self.downloadManager.downloadProgress.observeNext(with: { t, progress in
            if t.id == track.id {
                self.detailTextLabel?.text = "\(Int(progress * 100).description)%"
                if progress == 1 {
                    self.detailTextLabel?.text = nil
                }
            }
        }).dispose(in: self.downloaderDisposeBag)
    }
    
    func didLoad() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.backgroundColor = UIColor.white
        self.textLabel?.textColor = UIColor.psych1
        self.detailTextLabel?.textColor = UIColor.psych1
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
        self.downloadButton.frame = CGRect(x: 0, y: 0, width: size, height: size)
        super.updateConstraints()
    }
}
