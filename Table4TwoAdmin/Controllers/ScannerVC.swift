//
//  ScannerVC.swift
//  Table4TwoAdmin
//
//  Created by Nwachukwu Ejiofor on 21/09/2020.
//  Copyright © 2020 Nwachukwu Ejiofor. All rights reserved.
//

import AVFoundation
import UIKit

class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
	var captureSession: AVCaptureSession!
	var videoPreviewLayer: AVCaptureVideoPreviewLayer!
	var qrCodeView: UIView!
	var reservation = Reservation()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		view.backgroundColor = .black
		captureSession = AVCaptureSession()
		
		guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
		let videoInput: AVCaptureDeviceInput
		
		do {
			videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
		} catch {
			return
		}
		
		if captureSession.canAddInput(videoInput) {
			captureSession.addInput(videoInput)
		} else {
			failed(titleString: "Scanning not supported", messageString: "Your device does not support scanning a code from an item. Please use a device with a camera")
			captureSession = nil
			return
		}
		
		let captureMetadataOutput = AVCaptureMetadataOutput()
		if captureSession.canAddOutput(captureMetadataOutput) {
			captureSession.addOutput(captureMetadataOutput)
			
			captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
			captureMetadataOutput.metadataObjectTypes = [.qr]
		} else {
			failed(titleString: "Scanning not supported", messageString: "Your device does not support scanning a code from an item. Please use a device with a camera")
			captureSession = nil
			return
		}
		
		videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		videoPreviewLayer.frame = view.layer.bounds
		videoPreviewLayer.videoGravity = .resizeAspectFill
		view.layer.addSublayer(videoPreviewLayer)
		
		captureSession.startRunning()
		
		qrCodeView = UIView()
		if let qrCodeView = qrCodeView {
			qrCodeView.layer.borderColor = UIColor.green.cgColor
			qrCodeView.layer.borderWidth = 2
			view.addSubview(qrCodeView)
		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if !(captureSession.isRunning) {
			captureSession.startRunning()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if (captureSession.isRunning) {
			captureSession.stopRunning()
		}
	}
	
	func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		captureSession.stopRunning()
		
		if metadataObjects.count == 0 {
			qrCodeView.frame = CGRect.zero
			failed(titleString: "No QR code detected", messageString: "If QR code available, hold steady for 2 - 3 seconds")
			return
		}
		
		if let metadataObject = metadataObjects.first {
			guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
			let qrCodeObject = videoPreviewLayer.transformedMetadataObject(for: metadataObject)
			qrCodeView.frame = qrCodeObject!.bounds
			guard let stringValue = readableObject.stringValue else { return }
			AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
			found(code: stringValue)
		}
		
		dismiss(animated: true)
	}

	func failed(titleString: String, messageString: String) {
		let alert = UIAlertController(title: titleString, message: messageString, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(alert, animated: true, completion: nil)
	}
	
	func found(code: String) {
		print("This is the scanned code: \(code)")
		getReservation(code: code) { (err) in
			if err.isEmpty {
				self.performSegue(withIdentifier: "scanToReservationDetailSegue", sender: self)
				// Remove Scanner VC from stack
//				self.navigationController?.viewControllers.remove(at: 1)
			} else {
				self.navigationController?.popViewController(animated: true)
			}
		}
	}
	
	func getReservation(code: String, completion: @escaping (String) -> ()) {
		if let restId = user?.parentRestaurant {
			let params = ["restId": restId as AnyObject, "code": code as AnyObject, "statusChange": "InProgress" as AnyObject]
			post(controllerName: UIViewController.SCAN_RESERVATION, parameters: params) { (success, data) in
				if (success) {
					let res = data!
					print(res)
					if (res.type == .string) {
						self.showToast(controller: self, message: "Cannot scan unconfirmed reservations", seconds: 2.0)
						DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
							completion("error")
						}
					} else {
						self.reservation.id = res["_id"].stringValue
						self.reservation.reservationRedeemDate = res["reservationRedeemDate"].stringValue.toDate()
						self.reservation.commission = res["commission"].doubleValue
						self.reservation.amountPaid = res["amountPaid"].doubleValue
						self.reservation.numberOfSeats = res["numberOfSeats"].intValue
						self.reservation.code = res["code"].stringValue
						self.reservation.qrCode = res["qrCode"].stringValue
						self.reservation.reservationCancelled = res["reservationCancelled"].boolValue
						
						self.reservation.restaurant = Restaurant()
						self.reservation.restaurant!.id = res["restaurant"]["_id"].stringValue
						self.reservation.restaurant!.name = res["restaurant"]["name"].stringValue
						self.reservation.restaurant!.phoneNumber = res["restaurant"]["phonenumber"].stringValue
						
						self.reservation.customer = Customer()
						self.reservation.customer?.id = res["customer"]["_id"].stringValue
						self.reservation.customer?.fullname = res["customer"]["fullname"].stringValue
						self.reservation.customer?.email = res["customer"]["email"].stringValue
						self.reservation.customer?.phoneNumber = res["customer"]["phonenumber"].stringValue
						
						if !(res["status"].stringValue.isEmpty) {
							if (res["status"].stringValue.lowercased() == "pending") {
								self.reservation.status = .Pending
							} else if (res["status"].stringValue.lowercased() == "inprogress") {
								self.reservation.status = .InProgress
							} else if (res["status"].stringValue.lowercased() == "completed") {
								self.reservation.status = .Completed
							} else if (res["status"].stringValue.lowercased() == "confirmed") {
								self.reservation.status = .Confirmed
							} else if (res["status"].stringValue.lowercased() == "cancelled") {
								self.reservation.status = .Cancelled
							} else {
								self.reservation.status = .Expired
							}
						}
						
						for item in res["reservationItems"].arrayValue {
							let reservationItem = ReservationItem()
							reservationItem.name = item["name"].stringValue
							reservationItem.price = item["price"].floatValue
							reservationItem.quantity = item["quantity"].intValue
							self.reservation.reservationItems.append(reservationItem)
						}
						DispatchQueue.main.async {
							// Go to reservation details
							completion("")
						}
					}
				} else {
					// Display error message for non-confirmed reservations
				}
			}
		}
	}
	
//	override var prefersStatusBarHidden: Bool {
//        return true
//    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
		let nextVC = segue.destination as! ReservationDetailsVC
		nextVC.reservation = self.reservation
    }
}
