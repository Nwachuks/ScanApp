//
//  ReservationListTVC.swift
//  Table4TwoAdmin
//
//  Created by Nwachukwu Ejiofor on 16/09/2020.
//  Copyright © 2020 Nwachukwu Ejiofor. All rights reserved.
//

import UIKit

class ReservationListTVC: UITableViewCell {
	@IBOutlet weak var reservationImageView: UIImageView!
	@IBOutlet weak var reservationCode: UILabel!
	@IBOutlet weak var customerName: UILabel!
	@IBOutlet weak var reservationStatus: UILabel!
	@IBOutlet weak var reservationTime: UILabel!
	@IBOutlet weak var noOfSeats: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
