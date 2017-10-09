//
//  Era.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/8/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation

struct EraResponse: Codable {
    var data: Eras
}
typealias EraName = String
typealias Eras = [EraName: [Year]]
