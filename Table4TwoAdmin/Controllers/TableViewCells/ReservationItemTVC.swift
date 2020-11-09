//
//  ReservationItemTVC.swift
//  Table4TwoAdmin
//
//  Created by Nwachukwu Ejiofor on 21/09/2020.
//  Copyright © 2020 Nwachukwu Ejiofor. All rights reserved.
//

import UIKit

class ReservationItemTVC: UITableViewCell {
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var qtyLabel: UILabel!
	@IBOutlet weak var priceLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
