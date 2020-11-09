//
//  ReservationDetailsVC.swift
//  Table4TwoAdmin
//
//  Created by Nwachukwu Ejiofor on 21/09/2020.
//  Copyright © 2020 Nwachukwu Ejiofor. All rights reserved.
//

import UIKit
import DropDown

class ReservationDetailsVC: KeyboardHandlingVC, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var reservationDetailsView: UIView!
	@IBOutlet weak var reservationCodeLabel: UILabel!
	@IBOutlet weak var noOfSeatsLabel: UILabel!
	@IBOutlet weak var reservationTimeView: UIView!
	@IBOutlet weak var reservationTimeLabel: UILabel!
	@IBOutlet weak var reservationStatusLabel: UILabel!
	@IBOutlet weak var customerDetailsView: UIView!
	@IBOutlet weak var customerNameLabel: UILabel!
	@IBOutlet weak var customerPhoneNumberLabel: UILabel!
	@IBOutlet weak var customerEmailLabel: UILabel!
	@IBOutlet weak var reservationItemsView: UIView!
	@IBOutlet weak var reservationItemsViewHeight: NSLayoutConstraint!
	@IBOutlet weak var reservationItemsTable: UITableView!
	@IBOutlet weak var reservationItemsTableHeight: NSLayoutConstraint!
	@IBOutlet weak var totalLabel: UILabel!
	@IBOutlet weak var updateReservationView: UIView!
	@IBOutlet weak var updateReservationViewHeight: NSLayoutConstraint!
	@IBOutlet weak var changeStatusLabel: UILabel!
	@IBOutlet weak var statusView: UIView!
	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var amountPaidLabel: UILabel!
	@IBOutlet weak var amountPaidLabelHeight: NSLayoutConstraint!
	@IBOutlet weak var amountView: UIView!
	@IBOutlet weak var amountViewHeight: NSLayoutConstraint!
	@IBOutlet weak var amountTextField: UITextField!
	@IBOutlet weak var paymentLabel: UILabel!
	@IBOutlet weak var paymentLabelHeight: NSLayoutConstraint!
	@IBOutlet weak var paymentModeView: UIView!
	@IBOutlet weak var paymentModeViewHeight: NSLayoutConstraint!
	@IBOutlet weak var paymentModeLabel: UILabel!
	@IBOutlet weak var updateStatusBtn: UIButton!
	
	var reservation = Reservation()
	var reservationItems = [String]()
	var total: Float = 0.0
	
	let statusDropdown = DropDown()
	let paymentDropdown = DropDown()
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		setup()
		// Remove Scanner VC from stack if from Scanner VC
		self.navigationController?.removeViewController(ScannerVC.self)
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
    
	@IBAction func updateStatusBtnTapped(_ sender: UIButton) {
		let alert = UIAlertController(title: "Update Reservation", message: "Do you want to update reservation?", preferredStyle: .alert)
		
		let cancelAction = UIAlertAction(title: "NO", style: .default, handler: nil)
		let okAction = UIAlertAction(title: "YES", style: .cancel) { (action) in
			self.showSpinner()
			if (self.paymentModeLabel.isHidden || self.paymentModeLabel.text != "Select") {
				if (self.statusLabel.text == "Confirm") {
					self.reservation.status = .Confirmed
				} else if (self.statusLabel.text == "In Progress") {
					self.reservation.status = .InProgress
				} else if (self.statusLabel.text == "Complete") {
					self.reservation.status = .Completed
					if (self.amountTextField.text!.isEmpty) {
						self.showToast(controller: self, message: "Enter amount paid", seconds: 2.0)
						self.removeSpinner()
						return
					}
				} else if (self.statusLabel.text == "Cancel") {
					self.reservation.status = .Cancelled
					self.reservation.reservationCancelled = true
				} else {
					self.showToast(controller: self, message: "Set the status", seconds: 2.0)
					self.removeSpinner()
					return
				}
			} else {
				self.showToast(controller: self, message: "Set the payment mode", seconds: 2.0)
				self.removeSpinner()
				return
			}
			
			let param = ["_id": self.reservation.id as AnyObject, "status": self.reservation.status.rawValue as AnyObject, "qrCode": self.reservation.qrCode as AnyObject]
			self.post(controllerName: UIViewController.UPDATE_RESERVATION, parameters: param) { (success, data) in
				if (success) {
					print(data!)
					DispatchQueue.main.async {
						self.setReservationStatus()
						if (self.reservation.status == .Cancelled || self.reservation.status == .Completed || self.reservation.status == .Expired) {
							self.hideUpdateReservation()
						}
						self.removeSpinner()
					}
				}
			}
		}
		alert.addAction(cancelAction)
		alert.addAction(okAction)
		
		present(alert, animated: true, completion: nil)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		reservation.reservationItems.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "reservationItemCell", for: indexPath) as! ReservationItemTVC
		let item = reservation.reservationItems[indexPath.row]
		cell.nameLabel.text = item.name
		cell.priceLabel.text = "₦" + String(format: "%.2f", item.price * Float(item.quantity))
		if item.quantity == 1 {
			cell.qtyLabel.text = "\(item.quantity) serving"
		} else {
			cell.qtyLabel.text = "\(item.quantity) servings"
		}
		
		return cell
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
	}
	
	func setup() {
		reservationItemsTable.delegate = self
		reservationItemsTable.dataSource = self
		amountTextField.delegate = self
		
		// Set reservation status dropdown
		statusDropdown.anchorView = statusView
		statusDropdown.direction = .any
		showUpdateReservation()
		showAmountLabels()
		if (reservation.status == .Pending) {
			statusDropdown.dataSource = ["Confirm", "Cancel"]
			// Hide amount field
			hideAmountLabels()
		} else if (reservation.status == .Confirmed) {
			statusDropdown.dataSource = ["In Progress", "Cancel"]
			// Hide amount field
			hideAmountLabels()
		} else if (reservation.status == .InProgress) {
			statusDropdown.dataSource = ["Complete"]
		} else {
			// Completed or Cancelled
			hideUpdateReservation()
		}
		statusDropdown.selectRow(at: 0)
		let statusTap = UITapGestureRecognizer(target: self, action: #selector(showStatusDropdown))
		statusView.addGestureRecognizer(statusTap)
		statusDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
			self.statusLabel.text = item
			if (item == "Cancel") {
				self.statusLabel.textColor = .red
			} else {
				self.statusLabel.textColor = UIColor.AppBlue!
			}
		}
		
		// Set payment mode dropdown
		paymentDropdown.anchorView = paymentModeView
		paymentDropdown.direction = .any
		paymentDropdown.dataSource = ["Cash", "Cheque", "POS", "Transfer"]
		paymentDropdown.selectRow(at: 0)
		let paymentTap = UITapGestureRecognizer(target: self, action: #selector(showPaymentDropdown))
		paymentModeView.addGestureRecognizer(paymentTap)
		paymentDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
			self.paymentModeLabel.text = item
		}
		
		// Setup UI
		reservationDetailsView.applyBorder(color: UIColor.AppBlue!, width: 1, radius: 0)
		customerDetailsView.applyBorder(color: UIColor.AppBlue!, width: 1, radius: 0)
		reservationItemsView.applyBorder(color: UIColor.AppBlue!, width: 1, radius: 0)
		statusView.applyBorder(color: UIColor.AppBlue!, width: 1, radius: 0)
		amountView.applyBorder(color: UIColor.AppBlue!, width: 1, radius: 0)
		paymentModeView.applyBorder(color: UIColor.AppBlue!, width: 1, radius: 0)
		updateStatusBtn.applyBorder(color: .clear, width: 0, radius: 5)
		
		setReservationStatus()
		
		// Curve leftsided corner radius
		reservationTimeView.clipsToBounds = true
		reservationTimeView.layer.cornerRadius = CGFloat(reservationTimeView.frame.size.height/2)
		reservationTimeView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
		updateReservationView.backgroundColor = UIColor.LightBlue!
		
		reservationCodeLabel.text = reservation.code
		noOfSeatsLabel.text = String(reservation.numberOfSeats)
		reservationTimeLabel.text = getReservationDate(date: reservation.reservationRedeemDate)
		
		customerNameLabel.text = reservation.customer?.fullname
		customerPhoneNumberLabel.text = reservation.customer?.phoneNumber
		customerEmailLabel.text = reservation.customer?.email
		
		if (reservation.reservationItems.count > 0) {
			reservationItemsTableHeight.constant = CGFloat(reservation.reservationItems.count * 35)
			reservationItemsViewHeight.constant = reservationItemsTableHeight.constant + 90
		} else {
			reservationItemsView.isHidden = true
			reservationItemsViewHeight.constant = 70
		}
		reservationItemsTable.reloadData()
		
		for value in reservation.reservationItems {
			total += value.price * Float(value.quantity)
		}
		totalLabel.text = "₦" + String(format: "%.2f", total)
	}
	
	@objc func showStatusDropdown() {
		statusDropdown.show()
	}
	
	@objc func showPaymentDropdown() {
		paymentDropdown.show()
	}
	
	func getReservationDate(date: Date) -> String {
		let formatter = DateFormatter()
		
		formatter.dateFormat = "dd-MM-yyyy"
		let dateString = formatter.string(from: date)
		
		formatter.dateFormat = "hh:mm aa"
		let timeString = formatter.string(from: date)
		
		return "\(dateString), \(timeString)"
	}
	
	func setReservationStatus() {
		switch reservation.status {
		case .InProgress:
			reservationStatusLabel.text = "IN PROGRESS"
			reservationStatusLabel.textColor = .purple
			break
		case .Completed:
			reservationStatusLabel.text = "COMPLETED"
            reservationStatusLabel.textColor = .AppGreen
			break
		case .Confirmed:
			reservationStatusLabel.text = "CONFIRMED"
			reservationStatusLabel.textColor = .AppYellow
			break
		case .Cancelled:
			reservationStatusLabel.text = "CANCELLED"
            reservationStatusLabel.textColor = .red
			break
		case .Expired:
			reservationStatusLabel.text = "EXPIRED"
            reservationStatusLabel.textColor = .red
		default:
			// Pending
			reservationStatusLabel.text = "PENDING"
            reservationStatusLabel.textColor = .orange
		}
	}
	
	func hideUpdateReservation() {
		updateReservationView.isHidden = true
		updateStatusBtn.isHidden = true
		updateStatusBtn.isUserInteractionEnabled = false
	}
	
	func showUpdateReservation() {
		updateReservationView.isHidden = false
		updateStatusBtn.isHidden = false
		updateStatusBtn.isUserInteractionEnabled = true
	}
	
	func hideAmountLabels() {
		amountPaidLabel.isHidden = true
		amountPaidLabelHeight.constant = 0
		amountView.isHidden = true
		amountViewHeight.constant = 0
		paymentModeLabel.isHidden = true
		paymentLabelHeight.constant = 0
		paymentModeView.isHidden = true
		paymentModeViewHeight.constant = 0
		updateReservationViewHeight.constant = 70
	}
	
	func showAmountLabels() {
		amountPaidLabel.isHidden = false
		amountPaidLabelHeight.constant = 20
		amountView.isHidden = false
		amountViewHeight.constant = 30
		paymentModeLabel.isHidden = false
		paymentLabelHeight.constant = 20
		paymentModeView.isHidden = false
		paymentModeViewHeight.constant = 25
		updateReservationViewHeight.constant = 140
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
