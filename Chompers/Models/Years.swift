//
//  Years.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/8/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation

struct YearsResponse: Codable {
    var data: [Year]
}

typealias Year = String
