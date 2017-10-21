//
//  PhishTableViewBond.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/18/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import Bond

protocol PhishTableViewBond: TableViewBond {
}
extension PhishTableViewBond {
    //swiftlint:disable:next cyclomatic_complexity
    public func apply(event: DataSourceEvent<DataSource, BatchKindDiff>, to tableView: UITableView) {
        switch event.kind {
        case .reload:
            tableView.reloadData()
        case .insertItems(let indexPaths):
            tableView.insertRows(at: indexPaths, with: .top)
        case .deleteItems(let indexPaths):
            tableView.deleteRows(at: indexPaths, with: .top)
        case .reloadItems(let indexPaths):
            tableView.reloadRows(at: indexPaths, with: .top)
        case .moveItem(let indexPath, let newIndexPath):
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .insertSections(let indexSet):
            tableView.insertSections(indexSet, with: .top)
        case .deleteSections(let indexSet):
            tableView.deleteSections(indexSet, with: .top)
        case .reloadSections(let indexSet):
            tableView.reloadSections(indexSet, with: .top)
        case .moveSection(let index, let newIndex):
            tableView.moveSection(index, toSection: newIndex)
        case .beginUpdates:
            tableView.beginUpdates()
        case .endUpdates:
            tableView.endUpdates()
        }
    }
}
