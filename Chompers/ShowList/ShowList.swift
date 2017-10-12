//
//  ShowList.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/8/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit

class DownloadedShowList: ShowList, DownloadManagerInjector {
    override var title: String {
        return "Downloaded Shows"
    }
    
    override func getModels() -> Promise<[ListItem]> {
        let downloadedShows = self.downloadManager.getDownloadedShows()
        return Promise(value: downloadedShows)
    }
    
    init() {
        super.init(forYear: "")
    }
}

class ShowList: SimpleList, ServiceInjector {
    var year: Year
    init(forYear year: Year) {
        self.year = year
    }
    typealias ListItem = Show
    var title: String {
        return "Shows in \(self.year)"
    }
    
    func getModels() -> Promise<[ListItem]> {
        return self.service.getShows(fromYear: self.year).then { shows -> [Show] in
            return shows.sorted(by: { show, show2 in
                return show.date < show2.date
            })
        }
    }
    
    func setUp(viewController: UIViewController) {

    }
    
    
    static func createCell(tableView: UITableView, indexPath: IndexPath, models: [ListItem]) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.reuseIdentifier!, for: indexPath)
        let show = models[indexPath.row]
        cell.textLabel?.text = show.title
        return cell
    }
    func preformDelegateAction(forIndex index: IndexPath, models: [ListItem], delegate: ListViewModelDelegate) {
        let show = models[index.row]
        delegate.pushListing(forShow: show)
    }
    
    static func numberOfSections(models: [Show]) -> Int {
        return 1
    }
    
    static func numberOfRowsInSection(section: Int, models: [Show]) -> Int {
        return models.count
    }
}
