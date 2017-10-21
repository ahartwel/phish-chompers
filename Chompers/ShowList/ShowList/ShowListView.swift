//
//  ShowListView.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/21/17.
//Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit

class ShowListView: UIView, UITableViewDelegate, UITableViewDataSource {
    weak var actions: ShowListActions?
    
    lazy var donutView: DonutView = {
        var donutView = DonutView()
        return donutView
    }()
    lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ShowCell.self, forCellReuseIdentifier: ShowCell.reuseIdentifier ?? "")
        tableView.backgroundColor = UIColor.white.withAlphaComponent(0)
        
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        didLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didLoad()
    }
    
    func didLoad() {
        self.addViews()
        self.addConstraints()
    }
    
    func addViews() {
        self.addSubview(self.donutView)
        self.addSubview(self.tableView)
        self.tableView.separatorStyle = .none
    }
    
    func startAnimations() {
        self.donutView.startAnimations()
    }
    
    func addConstraints() {
        self.tableView.snp.remakeConstraints({ make in
            make.edges.equalTo(self)
        })
        self.donutView.snp.remakeConstraints({ make in
            make.edges.equalTo(self)
        })
    }
    
    func bindTo(model: ShowListBindables, withActions: ShowListActions) {
        self.actions = withActions
        model.shows.bind(to: self.tableView, using: TableBond(actions: self.actions)).dispose(in: self.bag)
    }
    
    struct TableBond: PhishTableViewBond {
        weak var actions: ShowListActions?
        init(actions: ShowListActions?) {
            self.actions = actions
        }
        func cellForRow(at indexPath: IndexPath, tableView: UITableView, dataSource: ObservableArray<Show>) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: ShowCell.reuseIdentifier ?? "", for: indexPath)
            let show = dataSource.array[indexPath.row]
            (cell as? ShowCell)?.setUp(withShow: show, onTapDownload: self.actions?.download)
            return cell
        }
        func titleForHeader(in section: Int, dataSource: ObservableArray<Show>) -> String? {
            return nil
        }
        func titleForFooter(in section: Int, dataSource: ObservableArray<Show>) -> String? {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if self.actions?.isShowDownloaded(AtIndex: indexPath) == true {
            return [
                UITableViewRowAction(style: .destructive, title: "Delete", handler: self.deleteShow)
            ]
        } else {
            return []
        }
    }
    
    //not used bind takes care of this
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    //not used bind takes care of this
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.actions?.isShowDownloaded(AtIndex: indexPath) == true
    }
    
    func deleteShow(action: UITableViewRowAction, atIndexPath indexPath: IndexPath) {
        self.actions?.delete(showAtPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.actions?.selectedShow(atIndex: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
