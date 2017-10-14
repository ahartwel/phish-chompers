//
//  YearsController.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/8/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit


class YearsList: SimpleList, ServiceInjector {
    typealias ListItem = Year
    var title: String {
        return "Years"
    }
    var years: [Year] = []
    var eras: Eras = [:]
    var eraNames: [EraName] = []
    
    func getModels() -> Promise<[ListItem]> {
        return self.service.getEras().then { eras -> Promise<[Year]> in
            self.eras = eras
            self.eraNames = []
            for (key, _) in eras {
                self.eraNames.append(key)
            }
            self.eraNames.sort()
            return self.service.getYears()
            }.then { years -> [Year] in
            self.years = years
            return years
        }
    }
    
    func createCell(tableView: UITableView, indexPath: IndexPath, models: [Year]) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.reuseIdentifier!, for: indexPath)
        let era = self.eraNames[indexPath.section]
        if let year = self.eras[era]?[indexPath.row] {
            cell.textLabel?.text = year
        }
        return cell
    }
    func preformDelegateAction(forIndex index: IndexPath, models: [ListItem], delegate: ListViewModelDelegate) {
        let era = self.eraNames[index.section]
        if let year = self.eras[era]?[index.row] {
            delegate.pushListings(forYear: year)
        }
    }
    
    func setUp(viewController: UIViewController) {
        
    }
 
    
    func numberOfRowsInSection(section: Int, models: [Year]) -> Int {
        let era = self.eraNames[section]
        return self.eras[era]?.count ?? 0
    }
    
    func numberOfSections(models: [Year]) -> Int {
        return self.eras.count
    }
    
    func titleForHeader(inSection section: Int, items: [Year]) -> String? {
        let era = self.eraNames[section]
        return era
    }
    
    init() {
        
    }
    
}

