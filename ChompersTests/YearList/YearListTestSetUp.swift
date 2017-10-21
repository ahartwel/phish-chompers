//
//  YearListTestSetUp.swift
//  ChompersTests
//
//  Created by Alex Hartwell on 10/19/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation
import PromiseKit

#if TESTBUILD
    extension ServiceInjector {

        var service: PhishInService {
                return MockYearService()
        }
    }
    extension YearViewModel {
        var service: PhishInService {
            return MockYearService()
        }
    }

    class MockYearService: PhishInService {
        override func getEras() -> Promise<Eras> {
            return Promise<Eras>(value: [
                "3.0": [
                    "2004",
                    "2005",
                    "2006"
                ],
                "1.0": [
                    "1995",
                    "1994"
                ],
                "2.0": [
                    "2000",
                    "1999"
                ]
                ])
        }
    }
#endif
