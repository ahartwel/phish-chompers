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


struct YearsList: SimpleList, ServiceInjector {    
    typealias ListItem = Year
    var title: String {
        return "Years"
    }
    
    func getModels() -> Promise<[ListItem]> {
        return self.getYears()
    }
    private var getYears: () -> Promise<[Year]>
    
    static func createCell(tableView: UITableView, indexPath: IndexPath, models: [Year]) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.reuseIdentifier!, for: indexPath)
        cell.textLabel?.text = models[indexPath.row]
        return cell
    }
    func preformDelegateAction(forIndex index: IndexPath, models: [ListItem], delegate: ListViewModelDelegate) {
        let year = models[index.row]
        delegate.pushListings(forYear: year)
    }
    
    func setUp(viewController: UIViewController) {
        
    }
    
    init() {
        self.getYears = {
            return Promise<[Year]>(value: [])
        }
        self.getYears = self.service.getYears
    }
    
    init(withYears years: [Year]) {
        self.getYears = {
            return Promise<[Year]>(value: years)
        }
    }
    
    static func numberOfRowsInSection(section: Int, models: [Year]) -> Int {
        return models.count
    }
    
    static func numberOfSections(models: [Year]) -> Int {
        return 1
    }
    
}

