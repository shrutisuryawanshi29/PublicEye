//
//  Utils.swift
//  PublicEye
//
//  Created by Shruti Suryawanshi on 2/24/24.
//

import UIKit
import MaterialTextField

class Utils {
    static let shared = Utils()
    
    func cornerRadius(view: UIView, radius: CGFloat = 5) {
        view.layer.cornerRadius = radius
    }
    
    func setupTextField(textfield: MFTextField, placeholder: String="") {
        textfield.placeholderColor = CustomColors.shared.primaryDark
        textfield.tintColor = CustomColors.shared.primaryDark
        textfield.textColor = .black
        textfield.placeholderAnimatesOnFocus = true
        textfield.placeholder = placeholder
        textfield.defaultPlaceholderColor = .gray
    }
    
    func showError(title: String = "Error!", message: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    
    func getCurrentDate() -> String{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormatterGet.string(from: Date())
    }
    
    func generateRandomIssueID(digits: Int = 5) -> String {
        var number = String()
        for _ in 1...digits {
            number += "\(Int.random(in: 1...9))"
        }
        return "PE"+number+"\(Date().timeIntervalSince1970)"
    }
}

extension UIView {
    func dropShadow(scale: Bool = true, shadowOpacity: Float = 0.1, shadowRadius: Float = 6) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = .zero
        layer.shadowRadius = 6
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
