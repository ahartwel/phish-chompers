//
//  YearListView.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/18/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import UIKit
import Bond
import ReactiveKit

class YearListView: UIView, UITableViewDelegate {
    lazy var donutView: DonutView = {
        var donutView = DonutView()
        return donutView
    }()
    lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor.white.withAlphaComponent(0)
        
        return tableView
    }()
    weak var actions: YearListActions?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.onInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.onInit()
    }
    
    func onInit() {
        self.clipsToBounds = true
        self.backgroundColor = UIColor.white.withAlphaComponent(0)
        self.addViews()
        self.addConstraints()
        self.tableView.separatorStyle = .none
    }
    
    func startAnimations() {
        self.donutView.startAnimations()
    }
    
    func addViews() {
        self.addSubview(self.donutView)
        self.addSubview(self.tableView)
    }
    
    func addConstraints() {
        self.tableView.snp.remakeConstraints({ make in
            make.edges.equalTo(self)
        })
        self.donutView.snp.remakeConstraints({ make in
            make.edges.equalTo(self)
        })
    }
    
    func bind(to model: YearsListBindables, withActions actions: YearListActions) {
        self.actions = actions
        model.eras.bind(to: self.tableView, using: TableBond()).dispose(in: self.bag)
        
    }
    struct TableBond: PhishTableViewBond {
        func cellForRow(at indexPath: IndexPath, tableView: UITableView, dataSource: Observable2DArray<EraName, Year>) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let year = dataSource.sections[indexPath.section].items[indexPath.row]
            cell.textLabel?.text = year
            return cell
        }
        func titleForHeader(in section: Int, dataSource: Observable2DArray<EraName, Year>) -> String? {
            return dataSource.sections[section].metadata
        }
        func titleForFooter(in section: Int, dataSource: Observable2DArray<EraName, Year>) -> String? {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.actions?.selected(yearAtIndex: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else {
            return
        }
        headerView.style()
    }
    
}

extension UITableViewHeaderFooterView {
    func style() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.psych6
        backgroundView.frame = self.bounds
        self.backgroundView = backgroundView
        self.textLabel?.textColor = .white
    }
}
