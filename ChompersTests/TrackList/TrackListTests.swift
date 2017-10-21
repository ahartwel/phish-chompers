//
//  TrackListTests.swift
//  ChompersTests
//
//  Created by Alex Hartwell on 10/21/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
import PromiseKit
@testable import ChompersDev
class TrackListTests: FBSnapshotTestCase {
    let show = Show(venue_name: "Test Venue", date: "12-20-19", tracks: [
        Track(title: "test track", position: 1, set_name: "set 1", id: 1),
        Track(title: "test track 2", position: 2, set_name: "set 1", id: 2),
        Track(title: "test track 3", position: 3, set_name: "set 2", id: 3),
        Track(title: "test track 4", position: 4, set_name: "set 2", id: 4),
        Track(title: "test track 5", position: 5, set_name: "set 2", id: 5),
        Track(title: "test track 6", position: 6, set_name: "encore", id: 6),
        Track(title: "test track 7", position: 7, set_name: "encore", id: 7)
        ], id: 1)
    override func setUp() {
        super.setUp()
        self.recordMode = false
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //TEST NEED TO BE RUN IN A PLUS SIZE SIMIULATOR, otherwise the view tests will fail
    func testViewLaysOutProperly() {
        let exp = self.expectation(description: "view lays out")
        let controller: TrackListController = TrackListController(show: self.show)
        controller.view.frame = CGRect(x: 0, y: 0, width: 350, height: 800)
        controller.viewWillAppear(false)
        controller.viewDidAppear(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.FBSnapshotVerifyView(controller.view, tolerance: 0.05)
            exp.fulfill()
        })
        self.waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testListSortsProperly() {
        let exp = self.expectation(description: "view lays out")
        let controller: TrackListController = TrackListController(show: self.show)
        controller.view.frame = CGRect(x: 0, y: 0, width: 350, height: 800)
        controller.viewWillAppear(false)
        controller.viewDidAppear(false)
        controller.viewModel.filterTracks(withSearchString: "3")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.FBSnapshotVerifyView(controller.view, tolerance: 0.05)
            exp.fulfill()
        })
        self.waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testPlayIsCalledOnSelectTrack() {
        let exp = self.expectation(description: "play is called")
        let controller: TrackListController = TrackListController(show: self.show)
        controller.view.frame = CGRect(x: 0, y: 0, width: 350, height: 800)
        controller.viewWillAppear(false)
        controller.viewDidAppear(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            controller.viewModel.selectedTrack(atIndex: IndexPath(row: 0, section: 0))
            DispatchQueue.main.async {
                //swiftlint:disable:next force_cast
                XCTAssertEqual((controller.viewModel.audioPlayer as! MockAudioPlayer).calledPlayWithTrack?.id, 1)
                //swiftlint:disable:next force_cast
                XCTAssertEqual((controller.viewModel.audioPlayer as! MockAudioPlayer).calledPlayWithShow?.id, 1)
                exp.fulfill()
            }
        })
        self.waitForExpectations(timeout: 0.3, handler: nil)
    }
    
    func testDownloadIsCalledOnShow() {
        let exp = self.expectation(description: "download is called")
        let controller: TrackListController = TrackListController(show: self.show)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            controller.viewModel.downloadShow()
            DispatchQueue.main.async {
                //swiftlint:disable:next force_cast
                XCTAssertEqual((controller.viewModel.downloadManager as! MockDownloadManager).calledDownloadShow?.id, 1)
                exp.fulfill()
            }
        })
        self.waitForExpectations(timeout: 0.3, handler: nil)
    }
    
}
