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

struct ShowList: SimpleList, ServiceInjector {
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
    
    static func createCell(tableView: UITableView, indexPath: IndexPath, models: [ListItem]) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.reuseIdentifier!, for: indexPath)
        let show = models[indexPath.row]
        cell.textLabel?.text = show.title
        return cell
    }
    static func preformDelegateAction(forIndex index: IndexPath, models: [ListItem], delegate: ListViewModelDelegate) {
//        let show = models[index.row]
//        delegate.presentListings(forYear: year)
    }
}
