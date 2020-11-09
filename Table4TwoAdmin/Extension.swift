//
//  Extension.swift
//  Table4TwoAdmin
//
//  Created by Nwachukwu Ejiofor on 22/09/2020.
//  Copyright © 2020 Nwachukwu Ejiofor. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

fileprivate var aView: UIView?

class Generic {
    static func GetUser() -> User? {
        if let data = UserDefaults.standard.object(forKey: "user") as? Data {
            let decoder = JSONDecoder()
            if let img = try? decoder.decode(User.self, from: data) {
                return img
            }
        }
        return  nil
    }
    
    static  func SaveUser(object: User) {
        let encoder = JSONEncoder();
        encoder.outputFormatting = .prettyPrinted;
        if let encode = try? encoder.encode(object) {
            UserDefaults.standard.set(encode, forKey: "user");
        }
    }
    
    static  func DeleteUser() {
        if UserDefaults.standard.object(forKey: "user") != nil {
            UserDefaults.standard.removeObject(forKey: "user");
            UserDefaults.standard.synchronize();
        }
    }
}

extension UIViewController {
	private static var _user: User? = nil
	static var baseUrl: String = "https://t4t.endearng.net/api/"
	static var LOGIN = "customer/login/"
	static var GET_RESERVATIONS = "reservation/getReservations/"
	static var SCAN_RESERVATION = "reservation/updateScannedStatus"
	static var UPDATE_RESERVATION = "reservation/updateReservation"
	
	var user: User? {
        get {
            if UIViewController._user == nil && Generic.GetUser() != nil {
                UIViewController._user = Generic.GetUser()!
                return  UIViewController._user!
            }
            else if UIViewController._user != nil{
                return  UIViewController._user!
            }
            return nil
        }
        set (newVal) {
            UIViewController._user = newVal
        }
    }
    
    func saveUser() {
        if UIViewController._user != nil {
			Generic.SaveUser(object: UIViewController._user!)
        }
    }
    
    func deleteUser() {
        Generic.DeleteUser()
        UIViewController._user = nil
    }
	
	func showToast(controller: UIViewController, message: String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = .white
        alert.view.alpha = 0.1
        alert.view.layer.cornerRadius = 15
        
        controller.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
	
	func showSpinner() {
        aView = UIView(frame: self.view.bounds)
        aView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        
		let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = UIColor.AppBlue!
        spinner.center = aView!.center
        spinner.startAnimating()
        aView?.addSubview(spinner)
        self.view.addSubview(aView!)
        
        Timer.scheduledTimer(withTimeInterval: 20.0, repeats: false) { (t) in
            self.removeSpinner()
        }
    }
    
    func removeSpinner() {
        aView?.removeFromSuperview()
        aView = nil
    }
	
	func get(controllerName: String, parameters: [String : Any]? = [:], headers: [String : Any]? = [:], completion: @escaping (_ success: Bool, _ object: SwiftyJSON.JSON?) -> ()) {
		var headersss: HTTPHeaders = [
			"Accept": "application/json"
		]
		headers!.forEach {
			headersss[$0.key] = $0.value as? String
		}
		let url = UIViewController.baseUrl + controllerName
		Alamofire.request(url, method: .get, parameters: parameters!.count == 0 ? nil : parameters, headers: headersss).validate(statusCode: 200..<599).responseJSON { (responseData) -> Void in
			if((responseData.result.value) != nil) {
				switch responseData.result {
				case .success(let data):
					let result = JSON(data)
					completion(true,result)
				case .failure(let error):
					let result = JSON(error.localizedDescription);
					if let error = error as? AFError {
						switch error {
						case .invalidURL(let url):
							completion(false, result)
							print("Invalid URL: \(url) - \(error.localizedDescription)")
						case .parameterEncodingFailed(let reason):
							completion(false, result)
							print("Parameter encoding failed: \(error.localizedDescription)")
							print("Failure Reason: \(reason)")
						case .multipartEncodingFailed(let reason):
							completion(false, result)
							print("Multipart encoding failed: \(error.localizedDescription)")
							print("Failure Reason: \(reason)")
						case .responseValidationFailed(let reason):
							completion(false, result)
							print("Response validation failed: \(error.localizedDescription)")
							print("Failure Reason: \(reason)")
							
							switch reason {
							case .dataFileNil, .dataFileReadFailed:
								print("Downloaded file could not be read")
							case .missingContentType(let acceptableContentTypes):
								print("Content Type Missing: \(acceptableContentTypes)")
							case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
								print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
							case .unacceptableStatusCode(let code):
								print("Response status code was unacceptable: \(code)")
							}
						case .responseSerializationFailed(let reason):
							print("Response serialization failed: \(error.localizedDescription)")
							print("Failure Reason: \(reason)")
						}
						print("Underlying error: \(String(describing: error.underlyingError))")
					} else if let error = error as? URLError {
					   completion(false, JSON(error))
					} else {
						completion(false, JSON(error))
					}
				}
			}
		}
	}
		
	func post(controllerName: String, parameters: [String : AnyObject], headers: [String : Any]? = [:], completion: @escaping (_ success: Bool, _ object: SwiftyJSON.JSON?) -> ()) {
		var headersss: HTTPHeaders = [
			"Accept": "application/json"
		]
		headers!.forEach {
			headersss[$0.key] = $0.value as? String
		}
		Alamofire.request(UIViewController.baseUrl+controllerName, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headersss).responseJSON { (responseData) -> Void in
			if ((responseData.result.value) != nil) {
				switch responseData.result {
				case .success(let data):
					let result = JSON(data)
					completion(true,result)
				case .failure(let error):
					let result = JSON(error.localizedDescription)
					if let error = error as? AFError {
						switch error {
						case .invalidURL(let url):
							completion(false, result)
							print("Invalid URL: \(url) - \(error.localizedDescription)")
						case .parameterEncodingFailed(let reason):
							completion(false, result)
							print("Parameter encoding failed: \(error.localizedDescription)")
							print("Failure Reason: \(reason)")
						case .multipartEncodingFailed(let reason):
							completion(false, result)
							print("Multipart encoding failed: \(error.localizedDescription)")
							print("Failure Reason: \(reason)")
						case .responseValidationFailed(let reason):
							completion(false, result)
							print("Response validation failed: \(error.localizedDescription)")
							print("Failure Reason: \(reason)")
							
							switch reason {
							case .dataFileNil, .dataFileReadFailed:
								print("Downloaded file could not be read")
							case .missingContentType(let acceptableContentTypes):
								print("Content Type Missing: \(acceptableContentTypes)")
							case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
								print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
							case .unacceptableStatusCode(let code):
								print("Response status code was unacceptable: \(code)")
							}
						case .responseSerializationFailed(let reason):
							print("Response serialization failed: \(error.localizedDescription)")
							print("Failure Reason: \(reason)")
						}
						
						print("Underlying error: \(String(describing: error.underlyingError))")
					} else if let error = error as? URLError {
						completion(false, JSON(error))
					} else {
						completion(false, JSON(error))
					}
				}
			}
		}
	}
		
	func put(controllerName: String, parameters: [String : Any], headers: [String : Any]? = [:], completion: @escaping (_ success: Bool, _ object: SwiftyJSON.JSON?) -> ()) {
		var headersss: HTTPHeaders = [
			"Accept": "application/json"
		]
		headers!.forEach {
			headersss[$0.key] = $0.value as? String
		}
		Alamofire.request(UIViewController.baseUrl+controllerName, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headersss).responseJSON { (responseData) -> Void in
			if((responseData.result.value) != nil) {
				switch responseData.result {
				case .success(let data):
					let result = JSON(data);
					completion(true,result);
					// Do your code here...
					
				case .failure(let error):
					let result = JSON(error.localizedDescription);
					if let error = error as? AFError {
						switch error {
						case .invalidURL(let url):
							completion(false,result);
							print("Invalid URL: \(url) - \(error.localizedDescription)")
						case .parameterEncodingFailed(let reason):
							completion(false,result);
							print("Parameter encoding failed: \(error.localizedDescription)")
							print("Failure Reason: \(reason)")
						case .multipartEncodingFailed(let reason):
							completion(false,result);
							print("Multipart encoding failed: \(error.localizedDescription)")
							print("Failure Reason: \(reason)")
						case .responseValidationFailed(let reason):
							completion(false,result);
							print("Response validation failed: \(error.localizedDescription)")
							print("Failure Reason: \(reason)")
							
							switch reason {
							case .dataFileNil, .dataFileReadFailed:
								print("Downloaded file could not be read")
							case .missingContentType(let acceptableContentTypes):
								print("Content Type Missing: \(acceptableContentTypes)")
							case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
								print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
							case .unacceptableStatusCode(let code):
								print("Response status code was unacceptable: \(code)")
							}
						case .responseSerializationFailed(let reason):
							print("Response serialization failed: \(error.localizedDescription)")
							print("Failure Reason: \(reason)")
						}
						
						print("Underlying error: \(String(describing: error.underlyingError))")
					} else if let error = error as? URLError {
						completion(false,JSON(error));
					} else {
						completion(false,JSON(error));
					}
				}
			}
		}
	}
}

extension UIView {
	func applyBorder(color:UIColor, width:Int, radius:Int) {
        let view = self
        view.layer.cornerRadius = CGFloat(radius)
        view.layer.borderWidth = CGFloat(width)
        view.layer.borderColor = color.cgColor
        view.clipsToBounds = true
    }
}

extension Date {
	func toString(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
    func from(year: Int, month: Int, day: Int) -> Date? {
        let calendar = Calendar.init(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return calendar.date(from: dateComponents) ?? nil
    }
}

extension String {
	var isValidEmail: Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
	
	func toDate() -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        let date = formatter.date(from: self)
        return date!
    }
}

extension UIColor {
	static let AppBlue = UIColor(hexString: "#011D3E")
	static let LightBlue = UIColor(hexString: "#D3EAEE")
	static let AppYellow = UIColor(hexString: "#CBCF34")
	static let AppGreen = UIColor(hexString: "#008000")
	
	public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
			var hexColor = String(hexString[start...])
            if hexColor.count == 6 {
                hexColor = hexColor + "ff"
            }
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        return nil
    }
}

extension UINavigationController {
	func removeViewController(_ controller: UIViewController.Type) {
		if let viewController = viewControllers.first(where: { $0.isKind(of: controller.self)}) {
			viewController.removeFromParent()
		}
	}
}

extension UITextField {
	func setLeftInset(width: CGFloat) {
		let insetView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: self.frame.height))
		self.leftView = insetView
		self.leftViewMode = .always
	}
}
