//
//  WelcomeViewController.swift
//  PublicEye
//
//  Created by Shruti Suryawanshi on 2/25/24.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var btnAddIssue: UIButton!
    @IBOutlet var bgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnAddIssue.backgroundColor = CustomColors.shared.primaryLight
        Utils.shared.cornerRadius(view: btnAddIssue, radius: 40.0)
        
        btnAddIssue.setTitle(" ADD ISSUE", for: .normal)
        btnAddIssue.setTitleColor(.white, for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        self.dismiss(animated: false)
    }
    
    
    
}
