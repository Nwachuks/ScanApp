//
//  Enums.swift
//  Table4TwoAdmin
//
//  Created by Nwachukwu Ejiofor on 22/09/2020.
//  Copyright © 2020 Nwachukwu Ejiofor. All rights reserved.
//

import Foundation

enum ReservationStatus: String, Codable {
    case Pending = "Pending", Confirmed = "Confirmed", InProgress = "InProgress", Completed = "Completed", Cancelled = "Cancelled", Expired = "Expired"
}

enum  PaymentMode: String, Codable {
   case None, Transfer, Cheque, Cash, POS
}
