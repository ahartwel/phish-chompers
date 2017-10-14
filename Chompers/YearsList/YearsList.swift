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
//    typealias ListItem = Year
    var title: String {
        return "Years"
    }
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
            return years
        }
    }
    
    func createCell(tableView: UITableView, indexPath: IndexPath, models: [Year]) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.reuseIdentifier!, for: indexPath)
        let workingYears = getWorkingYears(fromSection: indexPath.section, models: models)
        let year = workingYears[indexPath.row]
        cell.textLabel?.text = year
        return cell
    }
    func preformDelegateAction(forIndex index: IndexPath, models: [Year], delegate: ListViewModelDelegate) {
        let workingYears = getWorkingYears(fromSection: index.section, models: models)
        let year = workingYears[index.row]
        delegate.pushListings(forYear: year)
    }
    
    func setUp(viewController: UIViewController) {
        
    }
 
    func numberOfRowsInSection(section: Int, models: [Year]) -> Int {
        let workingYears = getWorkingYears(fromSection: section, models: models)
        return workingYears.count
    }
    
    func numberOfSections(models: [Year]) -> Int {
        return self.eras.count
    }
    
    func titleForHeader(inSection section: Int, items: [Year]) -> String? {
        let era = self.eraNames[section]
        return era
    }
    
    func getWorkingYears(fromSection section: Int, models: [Year]) -> [Year] {
        let era = self.eraNames[section]
        var workingYears: [Year] = []
        for year in self.eras[era] ?? [] {
            if models.contains(year) {
                workingYears.append(year)
            }
        }
        return workingYears
    }
    
    init() {
        
    }
    
    func getSearchText(forModel model: String) -> String {
        return model
    }
    
}

