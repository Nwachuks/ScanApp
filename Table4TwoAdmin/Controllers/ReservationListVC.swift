//
//  ReservationListVC.swift
//  Table4TwoAdmin
//
//  Created by Nwachukwu Ejiofor on 16/09/2020.
//  Copyright © 2020 Nwachukwu Ejiofor. All rights reserved.
//

import UIKit

class ReservationListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
	@IBOutlet weak var searchTextField: UITextField!
	@IBOutlet weak var searchBtn: UIButton!
	@IBOutlet weak var scanBtn: UIButton!
	@IBOutlet weak var scanLabel: UILabel!
	@IBOutlet weak var reservationListTable: UITableView!
	@IBOutlet weak var noReservationsLabel: UILabel!
	
	var selectedReservation = Reservation()
	var reservationsArray = [Reservation]()
	var pendingReservationsArray = [Reservation]()
	var inProgressReservations = [Reservation]()
	let cellSpacing: CGFloat = 20
	var isSearch = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		setup()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		searchTextField.text = ""
		searchBtn.setImage(UIImage(named: "Search"), for: .normal)
		getReservationsList(condition: "InProgress")
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
    
	@IBAction func scanBtnTapped(_ sender: UIButton) {
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction func searchBtnTapped(_ sender: UIButton) {
		isSearch = !isSearch
		if (isSearch) {
			// Perform search
			if (searchTextField.text!.count > 0) {
				getReservationsList(condition: searchTextField.text!)
				searchTextField.resignFirstResponder()
				sender.setImage(UIImage(named: "Cancel"), for: .normal)
			}
		} else {
			// Cancel search
			searchTextField.text = ""
			reservationsArray = pendingReservationsArray
			reservationListTable.reloadData()
			if (pendingReservationsArray.count > 0) {
				self.noReservationsLabel.isHidden = true
				self.reservationListTable.isHidden = false
			}
			sender.setImage(UIImage(named: "Search"), for: .normal)
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return reservationsArray.count
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return cellSpacing
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        return headerView
    }
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "reservationListCell", for: indexPath) as! ReservationListTVC
		cell.backgroundColor = .white
		cell.applyBorder(color: UIColor.AppBlue!, width: 2, radius: 10)
		let backgroundView = UIView()
		backgroundView.backgroundColor = UIColor.white
		cell.selectedBackgroundView = backgroundView
		let reservation = reservationsArray[indexPath.section]
		cell.reservationCode.text = reservation.code
		cell.customerName.text = reservation.customer?.fullname
		cell.reservationTime.text = getReservationDate(date: reservation.reservationRedeemDate)
		if (reservation.numberOfSeats == 1) {
			cell.noOfSeats.text = "\(reservation.numberOfSeats) seat"
		} else {
			cell.noOfSeats.text = "\(reservation.numberOfSeats) seats"
		}
//		cell.noOfSeats.backgroundColor = UIColor.AppBlue!
		if (reservation.status == .Pending) {
            cell.reservationStatus.text = "PENDING"
            cell.reservationStatus.textColor = .orange
		} else if (reservation.status == .InProgress) {
			cell.reservationStatus.text = "IN PROGRESS"
			cell.reservationStatus.textColor = .purple
		} else if (reservation.status == .Completed) {
            cell.reservationStatus.text = "COMPLETED"
            cell.reservationStatus.textColor = .AppGreen
        } else if (reservation.status == .Confirmed) {
            cell.reservationStatus.text = "CONFIRMED"
			cell.reservationStatus.textColor = .AppYellow
        } else if (reservation.status == .Cancelled) {
            cell.reservationStatus.text = "CANCELLED"
            cell.reservationStatus.textColor = .red
        } else {
            cell.reservationStatus.text = "EXPIRED"
            cell.reservationStatus.textColor = .red
        }
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// Show reservation details page
		selectedReservation = reservationsArray[indexPath.section]
		performSegue(withIdentifier: "reservationListToReservationDetailSegue", sender: self)
	}
	
	// MARK: TextField Delegates
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		getReservationsList(condition: textField.text!)
		isSearch = true
		searchBtn.setImage(UIImage(named: "Cancel"), for: .normal)
		textField.resignFirstResponder()
		return true
	}
	
	func setup() {
		reservationListTable.delegate = self
		reservationListTable.dataSource = self
		reservationListTable.tableFooterView = UIView()
		searchTextField.delegate = self
		searchTextField.applyBorder(color: UIColor.AppBlue!, width: 2, radius: Int(searchTextField.frame.size.height/2))
		searchTextField.setLeftInset(width: 15)
//		let backgroundViewLabel = UILabel(frame: .zero)
//		backgroundViewLabel.textColor = .darkGray
//		backgroundViewLabel.numberOfLines = 0
//		backgroundViewLabel.text = "Oops! /n No results to show"
//		reservationListTable.backgroundView = backgroundViewLabel
	}
	
	func getReservationDate(date: Date) -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd-MM-yyyy"
        let dateString = formatter.string(from: date)

        formatter.dateFormat = "hh:mm aa"
        let timeString = formatter.string(from: date)
        
        return "\(dateString), \(timeString)"
    }
	
	// MARK: Endpoint
	func getReservationsList(condition: String) {
		self.showSpinner()
		self.reservationsArray.removeAll()
		if let restId = user?.parentRestaurant {
			let param = "?restId=\(restId)&condition=\(condition)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
			get(controllerName: UIViewController.GET_RESERVATIONS+param) { (success, data) in
				if (success) {
					var returnedReservations = [Reservation]()
					let reservationJSON = data?.array!
					for res in reservationJSON! {
						let reservation = Reservation()
						reservation.id = res["_id"].stringValue
						reservation.reservationRedeemDate = res["reservationRedeemDate"].stringValue.toDate()
						reservation.commission = res["commission"].doubleValue
						reservation.amountPaid = res["amountPaid"].doubleValue
						reservation.numberOfSeats = res["numberOfSeats"].intValue
						reservation.code = res["code"].stringValue
						reservation.qrCode = res["qrCode"].stringValue
						reservation.reservationCancelled = res["reservationCancelled"].boolValue
						
						reservation.restaurant = Restaurant()
                        reservation.restaurant!.id = res["restaurant"]["_id"].stringValue
                        reservation.restaurant!.name = res["restaurant"]["name"].stringValue
                        reservation.restaurant!.phoneNumber = res["restaurant"]["phonenumber"].stringValue
						
						reservation.customer = Customer()
                        reservation.customer?.id = res["customer"]["_id"].stringValue
                        reservation.customer?.fullname = res["customer"]["fullname"].stringValue
                        reservation.customer?.email = res["customer"]["email"].stringValue
                        reservation.customer?.phoneNumber = res["customer"]["phonenumber"].stringValue
						
						if !(res["status"].stringValue.isEmpty) {
                            if (res["status"].stringValue.lowercased() == "pending") {
                                reservation.status = .Pending
							} else if (res["status"].stringValue.lowercased() == "inprogress") {
								reservation.status = .InProgress
							} else if (res["status"].stringValue.lowercased() == "completed") {
                                reservation.status = .Completed
                            } else if (res["status"].stringValue.lowercased() == "confirmed") {
                                reservation.status = .Confirmed
                            } else if (res["status"].stringValue.lowercased() == "cancelled") {
                                reservation.status = .Cancelled
                            } else {
                                reservation.status = .Expired
                            }
                        }
						
						for item in res["reservationItems"].arrayValue {
                            let reservationItem = ReservationItem()
                            reservationItem.name = item["name"].stringValue
                            reservationItem.price = item["price"].floatValue
                            reservationItem.quantity = item["quantity"].intValue
                            reservation.reservationItems.append(reservationItem)
                        }
						
						returnedReservations.append(reservation)
					}
					DispatchQueue.main.async {
						if (condition == "InProgress") {
							self.pendingReservationsArray = returnedReservations
						}
						if (returnedReservations.count > 0) {
							self.reservationsArray = returnedReservations
							self.reservationListTable.reloadData()
							self.reservationListTable.isHidden = false
							self.noReservationsLabel.isHidden = true
						} else {
							self.noReservationsLabel.isHidden = false
							self.reservationListTable.isHidden = true
						}
						self.removeSpinner()
					}
				} else {
					print(data!)
				}
			}
		}
	}
	
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
		if (segue.identifier == "reservationListToReservationDetailSegue") {
			let nextVC = segue.destination as! ReservationDetailsVC
			nextVC.reservation = selectedReservation
		}
    }

}
