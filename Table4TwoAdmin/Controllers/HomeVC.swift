//
//  HomeVC.swift
//  Table4TwoAdmin
//
//  Created by Nwachukwu Ejiofor on 16/09/2020.
//  Copyright © 2020 Nwachukwu Ejiofor. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {
	@IBOutlet weak var topView: UIView!
	@IBOutlet weak var instructionLabel: UILabel!
	@IBOutlet weak var proceedBtn: UIButton!
	@IBOutlet weak var reservationListBtn: UIButton!
	@IBOutlet weak var logoutBtn: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		proceedBtn.applyBorder(color: .clear, width: 0, radius: 5)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}
    
	@IBAction func proceedBtnTapped(_ sender: UIButton) {
		performSegue(withIdentifier: "homeToScannerViewSegue", sender: self)
	}
	
	@IBAction func reservationListBtnTapped(_ sender: UIButton) {
		performSegue(withIdentifier: "homeToReservationListSegue", sender: self)
	}
	
	@IBAction func logoutBtnTapped(_ sender: UIButton) {
		let alert = UIAlertController(title: "Logout", message: "Do you want to log out?", preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(title: "NO", style: .default, handler: nil)
		let okAction = UIAlertAction(title: "YES", style: .cancel) { (action) in
			self.navigationController?.popViewController(animated: true)
		}
		alert.addAction(cancelAction)
		alert.addAction(okAction)
		
		present(alert, animated: true, completion: nil)
	}

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
		
    }

}
