//
//  TrackListView.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/21/17.
//Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit

class TrackListView: UIView, UITableViewDelegate {
    weak var actions: TrackListActions?
    
    lazy var donutView: DonutView = {
        var donutView = DonutView()
        return donutView
    }()
    lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.delegate = self
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.reuseIdentifier ?? "")
        tableView.backgroundColor = UIColor.white.withAlphaComponent(0)
        
        return tableView
    }()
    
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
 
    func bindTo(model: TrackListBindables, withActions: TrackListActions) {
        self.actions = withActions
        model.tracks.bind(to: self.tableView, using: TableBond()).dispose(in: self.bag)
        
    }
    
    struct TableBond: PhishTableViewBond {
        func cellForRow(at indexPath: IndexPath, tableView: UITableView, dataSource: Observable2DArray<String, Track>) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.reuseIdentifier ?? "", for: indexPath)
            let track = dataSource.sections[indexPath.section].items[indexPath.row]
            (cell as? TrackCell)?.setUp(withTrack: track)
            return cell
        }
        func titleForHeader(in section: Int, dataSource: Observable2DArray<String, Track>) -> String? {
            return dataSource.sections[section].metadata
        }
        func titleForFooter(in section: Int, dataSource: Observable2DArray<String, Track>) -> String? {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.actions?.selectedTrack(atIndex: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else {
            return
        }
        headerView.style()
    }
    
}
