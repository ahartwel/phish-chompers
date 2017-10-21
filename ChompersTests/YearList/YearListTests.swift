//
//  YearListTest.swift
//  ChompersTests
//
//  Created by Alex Hartwell on 10/19/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
import PromiseKit
@testable import ChompersDev

class YearListTest: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()
        self.recordMode = false
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testViewLaysOutProperly() {
        let exp = self.expectation(description: "view lays out")
        let controller: YearListController = YearListController()
        controller.viewModel.loadData()
        controller.view.frame = CGRect(x: 0, y: 0, width: 350, height: 800)
        controller.viewWillAppear(false)
        controller.viewDidAppear(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.FBSnapshotVerifyView(controller.view)
            exp.fulfill()
        })
        self.waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testListSortsProperly() {
        let exp = self.expectation(description: "view lays out")
        let controller: YearListController = YearListController()
        controller.viewModel.loadData()
        controller.view.frame = CGRect(x: 0, y: 0, width: 350, height: 800)
        controller.viewWillAppear(false)
        controller.viewDidAppear(false)
        controller.viewModel.searchTextChanged("1999")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.FBSnapshotVerifyView(controller.view)
            exp.fulfill()
        })
        self.waitForExpectations(timeout: 0.3, handler: nil)
    }

}
