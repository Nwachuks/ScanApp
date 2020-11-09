//
//  KeyboardHandlingVC.swift
//  Table4TwoAdmin
//
//  Created by Nwachukwu Ejiofor on 16/09/2020.
//  Copyright © 2020 Nwachukwu Ejiofor. All rights reserved.
//

import UIKit

class KeyboardHandlingVC: UIViewController {
	@IBOutlet weak var backgroundScrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		subscribeToNotification(UIResponder.keyboardWillShowNotification, selector: #selector(keyboardWillShowOrHide(notification:)))
		subscribeToNotification(UIResponder.keyboardWillHideNotification, selector: #selector(keyboardWillShowOrHide(notification:)))
		initializeHideKeyboard()
    }
	
	override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
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

private extension KeyboardHandlingVC {
	func initializeHideKeyboard() {
		let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		view.addGestureRecognizer(tap)
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
		NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
	}
	
	func unsubscribeFromAllNotifications() {
		NotificationCenter.default.removeObserver(self)
	}
	
	@objc func keyboardWillShowOrHide(notification: NSNotification) {
		if let scrollView = backgroundScrollView, let userInfo = notification.userInfo, let endValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey], let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey], let curveValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] {
			let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
			let keyboardOverlap = scrollView.frame.maxY - endRect.origin.y + 5
			scrollView.contentInset.bottom = keyboardOverlap
			scrollView.verticalScrollIndicatorInsets.bottom = keyboardOverlap
			
			let duration = (durationValue as AnyObject).doubleValue
			let options = UIView.AnimationOptions(rawValue: UInt((curveValue as AnyObject).integerValue << 16))
			UIView.animate(withDuration: duration!, delay: 0, options: options, animations: {
				self.view.layoutIfNeeded()
			}, completion: nil)
		}
	}
}
