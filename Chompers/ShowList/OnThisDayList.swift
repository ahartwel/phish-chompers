//
//  OnThisDayList.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/16/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit


class TodayShowList: SimpleList, ServiceInjector, DownloadManagerInjector {
    var viewController: UIViewController?
   
    typealias ListItem = Show
    var title: String {
        return "On This Day"
    }
    
    func getModels() -> Promise<[ListItem]> {
        return self.service.getShowsOnThisDay().then { shows -> [Show] in
            return shows.sorted(by: { show, show2 in
                return show.date < show2.date
            })
        }
    }
    
    func setUp(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    
    func createCell(tableView: UITableView, indexPath: IndexPath, models: [ListItem]) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.reuseIdentifier!, for: indexPath)
        let show = models[indexPath.row]
        let venueName = show.venue_name ?? (show.venue?.name ?? "")
        let sdb = "[SBD]"
        let remaster = "[RM]"
        cell.textLabel?.text = show.date
        cell.detailTextLabel?.text = "\(show.sbd ? sdb : "")\(show.remastered ? remaster : "")\(venueName)"
        if !self.downloadManager.isShowDownloaded(show) {
            (cell as? ListItemCell)?.didTapDownload = { [unowned self] in
                self.showDownloadPopup(forShow: show)
            }
        }
        (cell as? ListItemCell)?.show = show
        return cell
    }
    
    func showDownloadPopup(forShow show: Show) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        if show.isDownloaded == false || show.isDownloaded == nil {
            alert.addAction(UIAlertAction(title: "Download Show", style: UIAlertActionStyle.default, handler: { action in
                self.download(show: show)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.viewController?.present(alert, animated: true, completion: nil)
    }
    
    func download(show: Show) {
        _ = self.service.getShow(byId: show.id).then { show in
            self.downloadManager.download(show: show)
        }
    }
    
    
    func preformDelegateAction(forIndex index: IndexPath, models: [ListItem], delegate: ListViewModelDelegate) {
        let show = models[index.row]
        delegate.pushListing(forShow: show)
    }
    
    func numberOfSections(models: [Show]) -> Int {
        return 1
    }
    
    func numberOfRowsInSection(section: Int, models: [Show]) -> Int {
        return models.count
    }
    
    func getSearchText(forModel model: Show) -> String {
        return model.date + (model.venue_name ?? "") + (model.venue?.name ?? "")
    }
}