//
//  SimpleList.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/8/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import UIKit
import ReactiveKit
import Bond
import SnapKit
import PromiseKit

class MainTabBarNavigationController<T: SimpleList>: UINavigationController {
    
    static func createListNavigation(withList list: T) -> MainTabBarNavigationController {
        let controller = MainTabBarNavigationController()
        controller.setViewControllers([
            ListController.createList(with: list)
            ], animated: false)
        controller.title = list.title
        return controller
    }
    
}




class ListController<T: SimpleList>: UIViewController, ListViewModelDelegate {
    
    lazy var trackListView: TrackListView<T> = {
        var view = TrackListView<T>()
        self.view.addSubview(view)
        view.setUpTopLevelConstraints()
        return view
    }()
    
    var viewModel: ListViewModel<T>!
   
    static func createList(with list: T) -> ListController {
        let controller = ListController(list: list)
        return controller
    }
    
    private convenience init(list: T) {
        self.init()
        self.viewModel = ListViewModel(list: list)
        self.title = list.title
        
    }
   
    
    override func loadView() {
        super.loadView()
        self.viewModel.delegate = self
        self.trackListView.bind(to: self.viewModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.extendedLayoutIncludesOpaqueBars = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func pushListings(forYear year: String) {
        let controller = ListController<ShowList>(list: ShowList(forYear: year))
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func pushListings(withYears years: [Year]) {
        let controller = ListController<YearsList>(list: YearsList(withYears: years))
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

class TrackListView<T: SimpleList>: UIView, UITableViewDelegate {
    
    lazy var tableView: UITableView = {
        var tableView = UITableView()
        T.registerCells(tableView: tableView)
        tableView.delegate = self
        return tableView
    }()
    var actions: ListActions?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.onInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.onInit()
    }
    
    func onInit() {
        self.addViews()
        self.addConstraints()
    }
    
    func setUpTopLevelConstraints() {
        guard let superview = self.superview else {
            return
        }
        self.snp.remakeConstraints({ make in
            make.edges.equalTo(superview)
        })
    }
    
    func addViews() {
        self.addSubview(self.tableView)
    }
    
    func addConstraints() {
        self.tableView.snp.remakeConstraints({ make in
            make.edges.equalTo(self)
        })
    }
    
    func bind(to model: ListViewModel<T>) {
        self.actions = model
        model.listings.bind(to: self.tableView, animated: true, createCell: { dataSource, indexPath, tableView -> UITableViewCell in
            let cell = T.createCell(tableView: tableView, indexPath: indexPath, models: dataSource.dataSource)
            return cell
        })
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.isSelected = false
        self.actions?.selectedListing(atIndex: indexPath)
    }
    
    
    
}
