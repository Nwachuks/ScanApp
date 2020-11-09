//
//  User.swift
//  Table4TwoAdmin
//
//  Created by Nwachukwu Ejiofor on 22/09/2020.
//  Copyright © 2020 Nwachukwu Ejiofor. All rights reserved.
//

import Foundation

class User: Codable {
	var id: String = ""
	var createdAt = Date()
	var updatedAt = Date()
	var username: String = ""
	var email: String = ""
	var parentRestaurant: String = ""
}
