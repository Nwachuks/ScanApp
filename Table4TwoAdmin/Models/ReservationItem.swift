//
//  ReservationItem.swift
//  Table4TwoAdmin
//
//  Created by Nwachukwu Ejiofor on 22/09/2020.
//  Copyright © 2020 Nwachukwu Ejiofor. All rights reserved.
//

import Foundation

class ReservationItem: Codable {
    var id: String = ""
    var itemId = ""
    var name: String = ""
    var price: Float = 0.0
    var quantity: Int = 2
    
    func convertToDictionary() -> [String : Any] {
        let dictionary: [String : Any] = ["id" : self.id, "itemId" : self.itemId, "name" : self.name, "price" : self.price, "quantity" : self.quantity]
        return dictionary
    }
}
