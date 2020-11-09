//
//  Address.swift
//  Table4TwoAdmin
//
//  Created by Nwachukwu Ejiofor on 22/09/2020.
//  Copyright © 2020 Nwachukwu Ejiofor. All rights reserved.
//

import Foundation

class Address:Codable {
    var code: String = ""
    var description: String = ""
    var visibility: String = ""
    var location: Location? = nil
}
