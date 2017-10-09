//
//  EraList.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/8/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit

struct EraList: SimpleList, ServiceInjector {
    static var eras: Eras?
    typealias ListItem = EraName
    var title: String {
        return "Eras"
    }
    
    func getModels() -> Promise<[ListItem]> {
        return self.service.getEras().then { eras -> [EraName] in
            EraList.eras = eras
            return eras.map({ (key, value) in
                return key
            }).sorted()
        }
    }
    
    static func createCell(tableView: UITableView, indexPath: IndexPath, models: [ListItem]) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.reuseIdentifier!, for: indexPath)
        let era = models[indexPath.row]
        cell.textLabel?.text = era
        return cell
    }
    static func preformDelegateAction(forIndex index: IndexPath, models: [ListItem], delegate: ListViewModelDelegate) {
        let eraName = models[index.row]
        guard let years = self.eras?[eraName] else {
            return
        }
        delegate.pushListings(withYears: years)
    }
}
