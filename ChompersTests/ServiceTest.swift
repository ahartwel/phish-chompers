//
//  ServiceTest.swift
//  ChompersTests
//
//  Created by Alex Hartwell on 10/8/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import XCTest
@testable import ChompersDev

class ServiceTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testYearsAreParsed() {
        let exp = self.expectation(description: "gets years from test json")
        let service = PhishInService.createTestService()
        _ = service.getYears().then(execute: { years -> Void in
            XCTAssertEqual(years.count, 26)
            exp.fulfill()
        }).catch(execute: { error in
            print(error.localizedDescription)
        })
        self.waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testShowsByYearsAreParsed() {
        let exp = self.expectation(description: "gets shows from year from test json")
        let service = PhishInService.createTestService()
        _ = service.getShows(fromYear: "1999").then(execute: { shows -> Void in
            XCTAssertEqual(shows.count, 1)
            exp.fulfill()
        }).catch(execute: { error in
            print(error.localizedDescription)
        })
        self.waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetEras() {
        let exp = self.expectation(description: "gets eras from test json")
        let service = PhishInService.createTestService()
        _ = service.getEras().then(execute: { eras -> Void in
            XCTAssertEqual(eras.count, 3)
            exp.fulfill()
        }).catch(execute: { error in
            print(error.localizedDescription)
        })
        self.waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testGetShowById() {
        let exp = self.expectation(description: "gets show from test json")
        let service = PhishInService.createTestService()
        _ = service.getShow(byId: 124).then(execute: { show -> Void in
            XCTAssertNotNil(show.venue)
            XCTAssertEqual(show.tracks?.count, 17)
            exp.fulfill()
        }).catch(execute: { error in
            print(error.localizedDescription)
        })
        self.waitForExpectations(timeout: 0.3, handler: nil)
    }
}
