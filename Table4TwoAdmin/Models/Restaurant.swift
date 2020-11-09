//
//  Restaurant.swift
//  Table4TwoAdmin
//
//  Created by Nwachukwu Ejiofor on 22/09/2020.
//  Copyright © 2020 Nwachukwu Ejiofor. All rights reserved.
//

import Foundation

class Restaurant: Codable {
	var id: String = ""
	var createdAt = Date()
	var updatedAt = Date()
	var name: String = ""
	var rating: Float = 0.0
	var commission: Int = 0
	var phoneNumber: String = ""
	var email: String = ""
	var location: Location? = nil
	var description: String = ""
	var code: String = ""
	var visibility: Bool = true
	var isActive: Bool = true
	
//    var paymentMethods: String = ""
//    var banner: String = ""
//    var deals = [Deal]()
//    var addresses = [Address]()
//    var menus = [MenuCategory]()
//    var openCloseTime = [OpenCloseTime]()
//    var images = [Image]()
//    var categories = [Category]()
//    var reviews = [Review]()
//    var sideAttractions = [SideAttraction]()
}
