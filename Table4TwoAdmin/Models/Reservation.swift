//
//  Reservation.swift
//  Table4TwoAdmin
//
//  Created by Nwachukwu Ejiofor on 22/09/2020.
//  Copyright © 2020 Nwachukwu Ejiofor. All rights reserved.
//

import Foundation

class Reservation: Codable {
    var id: String = ""
	var status: ReservationStatus = .InProgress
	var reservationRedeemDate = Date()
	var reservationItems = [ReservationItem]()
	var reservationDate = Date()
	var commission: Double = 0.0
	var amountPaid = 0.0
	var numberOfSeats: Int = 0
	var code: String = ""
	var qrCode: String = ""
	var reservationCancelled: Bool = false
	var restaurant: Restaurant? = nil
	var customer: Customer? = nil
	
//    var reservationNote = ""
//    var cancelReason: String = ""
//    var isActive: Bool = true
//    var platform = Platform.IOS
//	var commissionPaid = 0.0
//    var createdAt = Date()
//    var updatedAt = Date()
//    var confirmationNote = ""
//    var paymentMode: PaymentMode = PaymentMode.None
}
