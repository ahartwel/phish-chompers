//
//  ShowCell.swift
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

class ShowCell: UITableViewCell, DownloadManagerInjector, AudioPlayerInjector {
    static var reuseIdentifier: String? {
        return "ShowCell"
    }

    lazy var downloadButton: UIButton = {
        var button = UIButton()
        let downloadImage = IonIcons.image(withIcon: ion_ios_cloud_download_outline, size: 24, color: UIColor.psych1)
        button.setImage(downloadImage, for: .normal)
        button.contentMode = UIViewContentMode.center
        button.addTarget(self, action: #selector(self.tappedDownload), for: .touchUpInside)
        return button
    }()

    var didTapDownload: ((Show) -> Void)?
    var show: Show?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        self.didLoad()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.didLoad()
    }

    func setUp(withShow show: Show, onTapDownload: ((Show) -> Void)?) {
        self.show = show
        self.didTapDownload = onTapDownload
        self.downloadManager.downloadedShows.observeNext(with: { shows in
            if shows.contains(where: {
                return $0.id == show.id
            }) {
                self.downloadButton.alpha = 0
                self.accessoryView = nil
            } else {
                self.downloadButton.alpha = 1
                self.accessoryView = self.downloadButton
            }
        }).dispose(in: self.bag)
        self.downloadManager.downloadingShow.observeNext(with: { progress in
            if show.id != progress.show.id {
                return
            }
            self.downloadButton.alpha = 0
            self.accessoryView = nil
        }).dispose(in: self.bag)
        self.downloadManager.downloadingShow.debounce(interval: 0.3, on: DispatchQueue.main).observeNext(with: { progress in
            if show.id != progress.show.id {
                self.setDetailTextLabel(forShow: show)
                return
            }
            if progress.complete {
                self.setDetailTextLabel(forShow: show)
            } else {
                self.detailTextLabel?.text = "Downloading..."
            }
        }).dispose(in: self.bag)
        self.setDetailTextLabel(forShow: show)
        self.textLabel?.text = show.date
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

    @objc func tappedDownload() {
        guard let show = self.show else {
            return
        }
        self.didTapDownload?(show)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.bag.dispose()
//        self.didTapDownload = nil
//        self.downloadButton.alpha = 0
//        self.track = nil
    }

    override func updateConstraints() {
        let size = UIScreen.main.bounds.width * 0.2
        self.downloadButton.frame = CGRect(x: 12, y: 0, width: size, height: size)
        super.updateConstraints()
    }
}
