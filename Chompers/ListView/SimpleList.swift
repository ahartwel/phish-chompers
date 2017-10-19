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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    convenience init() {
        self.init(navigationBarClass: PhishNavigationBar.self, toolbarClass: nil)
    }
    
    static func createWithController(controller: UIViewController) -> MainTabBarNavigationController {
        let navController = MainTabBarNavigationController()
        navController.setViewControllers([
            controller
            ], animated: false)
        return navController
    }
    
    static func createListNavigation(withList list: T) -> MainTabBarNavigationController {
        let controller = MainTabBarNavigationController()
        controller.setViewControllers([
            ListController.createList(with: list)
            ], animated: false)
        controller.title = list.title
        return controller
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.navigationBar.prefersLargeTitles = true
            self.navigationBar.largeTitleTextAttributes = [
                NSAttributedStringKey.foregroundColor: UIColor.white
            ]
        }
        
        
        self.navigationItem.backBarButtonItem?.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 16)
        ]
        
    }
}

class PhishNavigationBar: UINavigationBar {
    lazy var donutView: DonutView = DonutView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.didLoad()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.didLoad()
    }
    
    func didLoad() {
        self.backgroundColor = UIColor.psych5
        self.barTintColor = UIColor.psych5
        self.shadowImage = UIImage()
    }
}



class ListController<T: SimpleList>: UIViewController, ListViewModelDelegate, AudioPlayerInjector, UISearchResultsUpdating {
    
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    private convenience init(list: T) {
        self.init()
        self.viewModel = ListViewModel(list: list)
        self.title = list.title
        let search = UISearchController(searchResultsController: nil)
        search.hidesNavigationBarDuringPresentation = false
        search.dimsBackgroundDuringPresentation = false
        search.searchResultsUpdater = self
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = search
        }
        list.setUp(viewController: self)
    }
   
    
    override func loadView() {
        super.loadView()
        self.viewModel.delegate = self
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0)
        self.trackListView.bind(to: self.viewModel)
        self.bindToQueueUpdates()
    }
    
    func bindToQueueUpdates() {
        if T.self is QueueTrackList.Type {
            self.audioPlayer.changedQueue.observeNext(with: { event in
                self.viewModel.didAppear()
            }).dispose(in: self.bag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.extendedLayoutIncludesOpaqueBars = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.didAppear()
        self.trackListView.startAnimations()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController?.isActive = false
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.viewModel.updateModels(forSearch: searchController.searchBar.text ?? "")
    }
    
    func pushListings(forYear year: String) {
        let controller = ListController<ShowList>(list: ShowList(forYear: year))
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func pushListing(forShow show: Show) {
        let controller = ListController<TrackList>(list: TrackList(show: show))
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

class TrackListView<T: SimpleList>: UIView, UITableViewDelegate, UITableViewDataSource {
    lazy var donutView: DonutView = {
        var donutView = DonutView()
        return donutView
    }()
    lazy var tableView: UITableView = {
        var tableView = UITableView()
        T.registerCells(tableView: tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white.withAlphaComponent(0)
        return tableView
    }()
    var items: [T.ListItem] = []
    var actions: ListActions?
    var list: T!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.onInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.onInit()
    }
    
    func onInit() {
        self.backgroundColor = UIColor.white.withAlphaComponent(0)
        self.addViews()
        self.addConstraints()
        self.tableView.separatorStyle = .none
    }
    
    func setUpTopLevelConstraints() {
        guard let superview = self.superview else {
            return
        }
        self.snp.remakeConstraints({ make in
            make.edges.equalTo(superview)
        })
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
    
    func bind(to model: ListViewModel<T>) {
        self.list = model.list
        self.actions = model
        model.listings.observeNext(with: { items in
            self.items = items
            self.tableView.reloadData()
        }).dispose(in: self.bag)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.cellForRow(at: indexPath)?.isSelected = false
        self.actions?.selectedListing(atIndex: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.list.createCell(tableView: tableView, indexPath: indexPath, models: self.items)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.list.numberOfSections(models: self.items)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.numberOfRowsInSection(section: section, models: self.items)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.list.titleForHeader(inSection: section, items: self.items)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else {
            return
        }
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.psych6
        backgroundView.frame = headerView.bounds
        headerView.backgroundView = backgroundView
        headerView.textLabel?.textColor = .white
    }
}
