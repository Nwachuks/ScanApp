//
//  LoginVC.swift
//  Table4TwoAdmin
//
//  Created by Nwachukwu Ejiofor on 16/09/2020.
//  Copyright © 2020 Nwachukwu Ejiofor. All rights reserved.
//

import UIKit

class LoginVC: KeyboardHandlingVC, UITextFieldDelegate {
	@IBOutlet weak var overview: UIView!
	@IBOutlet weak var welcomeLabel: UILabel!
	@IBOutlet weak var appImageView: UIImageView!
	@IBOutlet weak var appTitleLabel: UILabel!
	@IBOutlet weak var appSubtitleLabel: UILabel!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var forgotPasswordBtn: UIButton!
	@IBOutlet weak var loginBtn: UIButton!
	
//	var restaurantCode = ""
	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		setup()
		disableLogin()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		passwordTextField.text = ""
		disableLogin()
		navigationController?.setNavigationBarHidden(true, animated: animated)
	}
    
	@IBAction func toggleShowPassword(_ sender: UIButton) {
		if passwordTextField.isSecureTextEntry {
			// Show password
			passwordTextField.isSecureTextEntry = false
			sender.setTitle(" Hide", for: .normal)
			sender.setImage(UIImage(named: "closedEye"), for: .normal)
		} else {
			// Hide password
			passwordTextField.isSecureTextEntry = true
			sender.setTitle(" Show", for: .normal)
			sender.setImage(UIImage(named: "openEye"), for: .normal)
		}
	}
	
	@IBAction func forgotPasswordBtnTapped(_ sender: UIButton) {
		
	}
	
	@IBAction func loginBtnTapped(_ sender: UIButton) {
		if (emailTextField.text!.isValidEmail) {
			if let email = emailTextField.text {
				if let password = passwordTextField.text {
					showSpinner()
					let param = "\(email)/\(password)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
					get(controllerName: UIViewController.LOGIN+param) { (success, data) in
						if (success) {
							let userJSON = data!
							let message = userJSON["message"].stringValue
							if !(message.isEmpty) {
								self.showToast(controller: self, message: "Invalid email and password combination", seconds: 2.0)
								self.removeSpinner()
								return
							} else {
								self.user = User()
								self.user!.id = userJSON["_id"].stringValue
								self.user!.updatedAt = userJSON["updatedAt"].stringValue.toDate()
								self.user!.parentRestaurant = userJSON["parentRestaurant"].stringValue
								self.user!.email = userJSON["email"].stringValue
								self.user!.createdAt = userJSON["createdAt"].stringValue.toDate()
								self.user!.username = userJSON["username"].stringValue
								DispatchQueue.main.async {
									self.saveUser()
									self.removeSpinner()
									self.performSegue(withIdentifier: "loginToHomeSegue", sender: self)
								}
							}
						} else {
							self.showToast(controller: self, message: "Invalid login details", seconds: 2.0)
						}
					}
				}
			}
		} else {
			showToast(controller: self, message: "Enter a valid email", seconds: 2.0)
		}
	}
	
	func setup() {
		emailTextField.delegate = self
		passwordTextField.delegate = self
		emailTextField.applyBorder(color: .clear, width: 0, radius: 5)
		emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		passwordTextField.applyBorder(color: .clear, width: 0, radius: 5)
		passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		loginBtn.applyBorder(color: .clear, width: 0, radius: 5)
		overview.applyBorder(color: UIColor.AppBlue!, width: 2, radius: 0)
		if (user != nil) {
			emailTextField.text = user!.email
		}
	}
	
	func disableLogin() {
		loginBtn.isUserInteractionEnabled = false
		loginBtn.alpha = 0.6
	}
	
	func enableLogin() {
		loginBtn.isUserInteractionEnabled = true
		loginBtn.alpha = 1.0
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if (textField == emailTextField) {
			if !(textField.text!.isValidEmail) {
				showToast(controller: self, message: "Enter a valid email", seconds: 2.0)
			} else {
				passwordTextField.becomeFirstResponder()
			}
		} else {
			// Password textfield
			textField.resignFirstResponder()
			if (!emailTextField.text!.isEmpty && !passwordTextField.text!.isEmpty) {
				enableLogin()
			}
		}
		return true
	}
	
	@objc func textFieldDidChange(textField: UITextField) {
		if textField.text!.count > 0 {
			if (!emailTextField.text!.isEmpty && !passwordTextField.text!.isEmpty) {
				enableLogin()
			} else {
				disableLogin()
			}
		} else {
			disableLogin()
		}
	}
	
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
		
    }

}
