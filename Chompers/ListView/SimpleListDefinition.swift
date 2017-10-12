//
//  SimpleListDefinition.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/8/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import PromiseKit
import UIKit

protocol SimpleList {
    associatedtype ListItem
    var title: String { get }
    func getModels() -> Promise<[ListItem]>
    static func numberOfSections(models: [ListItem]) -> Int
    static func numberOfRowsInSection(section: Int, models: [ListItem]) -> Int
    static func registerCells(tableView: UITableView)
    static func createCell(tableView: UITableView, indexPath: IndexPath, models: [ListItem]) -> UITableViewCell
    static func titleForHeader(inSection section: Int, items: [ListItem]) -> String?
    func preformDelegateAction(forIndex index: IndexPath, models: [ListItem], delegate: ListViewModelDelegate)
    func setUp(viewController: UIViewController)
}

extension SimpleList {
    static func registerCells(tableView: UITableView) {
        tableView.register(ListItemCell.self, forCellReuseIdentifier: ListItemCell.reuseIdentifier ?? "")
    }
    static func titleForHeader(inSection section: Int, items: [ListItem]) -> String? {
        return nil
    }
}
