//
//  ViewController.swift
//  PublicEye
//
//  Created by Shruti Suryawanshi on 2/24/24.
//

import UIKit
import MaterialTextField
import FirebaseCore
import GoogleSignIn
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var txtFldEmail: MFTextField!
    @IBOutlet weak var txtFldPassword: MFTextField!
    @IBOutlet weak var txtFname: MFTextField!
    @IBOutlet weak var txtLname: MFTextField!
    @IBOutlet weak var viewBg: UIView!      //registration view
    @IBOutlet weak var viewRegister: UIView!
    @IBOutlet weak var viewLogin: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var txtloginemail: MFTextField!
    @IBOutlet weak var txtloginpwd: MFTextField!
    
    @IBOutlet weak var btnCommonLoginRegister: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        initialSetup()
        
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        
        if let userExists = UserDefaults.standard.object(forKey: "FIRUser") as? Data {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
                let controller = storyboard.instantiateViewController(identifier: "DashboardViewController") as! DashboardViewController
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true)
            }
        }
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        txtFldEmail.text = ""
        txtFldPassword.text = ""
        txtFname.text = ""
        txtLname.text = ""
        txtloginemail.text = ""
        txtloginpwd.text = ""
    }
    
    func initialSetup() {
        self.viewRegister.isHidden = true
        self.viewLogin.isHidden = false
        self.view.backgroundColor = CustomColors.shared.primaryDark
        self.viewBg.backgroundColor = CustomColors.shared.background
        self.viewLogin.backgroundColor = CustomColors.shared.background
        self.viewRegister.backgroundColor = CustomColors.shared.background
        self.viewBg.dropShadow()
        self.viewLogin.dropShadow()
        Utils.shared.cornerRadius(view: self.imgLogo, radius: 10)
        
        self.registerBtn.addTarget(self, action: #selector(loginWithEmailPwd(_:)), for: .touchUpInside)
        self.loginBtn.addTarget(self, action: #selector(loginUser(_:)), for: .touchUpInside)
        self.btnCommonLoginRegister.addTarget(self, action: #selector(toggle(_:)), for: .touchUpInside)
        
        viewBg.layer.borderWidth = 1.0
        viewBg.layer.borderColor = CustomColors.shared.borderColor.cgColor
        Utils.shared.cornerRadius(view: viewBg, radius: 20)
        
        viewRegister.layer.borderWidth = 1.0
        viewRegister.layer.borderColor = CustomColors.shared.borderColor.cgColor
        Utils.shared.cornerRadius(view: viewRegister, radius: 20)

        
        viewLogin.layer.borderWidth = 1.0
        viewLogin.layer.borderColor = CustomColors.shared.borderColor.cgColor
        Utils.shared.cornerRadius(view: viewLogin, radius: 20)
        
        registerBtn.backgroundColor = CustomColors.shared.primaryLight
        Utils.shared.cornerRadius(view: registerBtn)
        
        loginBtn.backgroundColor = CustomColors.shared.primaryLight
        Utils.shared.cornerRadius(view: loginBtn)
        
        Utils.shared.setupTextField(textfield: txtFldEmail, placeholder: "Email")
        Utils.shared.setupTextField(textfield: txtFldPassword, placeholder: "Password")
        
        Utils.shared.setupTextField(textfield: txtFname, placeholder: "First Name")
        Utils.shared.setupTextField(textfield: txtLname, placeholder: "Last Name")
        
        Utils.shared.setupTextField(textfield: txtloginemail, placeholder: "Email")
        Utils.shared.setupTextField(textfield: txtloginpwd, placeholder: "Password")
    }
    
    @objc func toggle(_ sender: UIButton) {
        self.viewRegister.isHidden = !self.viewRegister.isHidden
        self.viewLogin.isHidden = !self.viewLogin.isHidden
        self.viewBg.backgroundColor = CustomColors.shared.background
    }
    
    //login
    @objc func loginUser(_ sender: UIButton) {
        
        if txtloginemail.text?.isEmpty ?? true {
            self.present(Utils.shared.showError(message: "Enter email"), animated: true)
        } else if txtloginpwd.text?.isEmpty ?? true {
            self.present(Utils.shared.showError(message: "Enter password"), animated: true)
        }
        else {
            if let email = txtloginemail.text, let pwd = txtloginpwd.text {
                Auth.auth().signIn(withEmail: email, password: pwd) { [weak self] authResult, error in
                    guard let strongSelf = self else { return }
                    if error != nil {
                        self?.present(Utils.shared.showError(message: "Error with Login! Try Again!"), animated: true)
                        return
                    }
                    
                    var user = FIRUser()
                    user.email = authResult?.user.email
                    user.name = authResult?.user.displayName
                    user.uid = authResult?.user.uid
                    
                    if let encoded = try? JSONEncoder().encode(user) {
                        let defaults = UserDefaults.standard
                        defaults.set(encoded, forKey: "FIRUser")
                    }
                    
                    let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
                    let controller = storyboard.instantiateViewController(identifier: "DashboardViewController") as! DashboardViewController
                    controller.modalPresentationStyle = .fullScreen
                    self?.present(controller, animated: true)
                }
            }
        }
    }
    
    //register
    @objc func loginWithEmailPwd(_ sender: UIButton) {
        
        if txtFname.text?.isEmpty ?? true {
            self.present(Utils.shared.showError(message: "Enter first name"), animated: true)
        } else if txtLname.text?.isEmpty ?? true {
            self.present(Utils.shared.showError(message: "Enter last name"), animated: true)
        } else if txtFldEmail.text?.isEmpty ?? true {
            self.present(Utils.shared.showError(message: "Enter email"), animated: true)
        } else if txtFldPassword.text?.isEmpty ?? true {
            self.present(Utils.shared.showError(message: "Enter password"), animated: true)
        }
        else {
            if let email = txtFldEmail.text, let pwd = txtFldPassword.text {
                Auth.auth().createUser(withEmail: email, password: pwd) { [weak self] authResult, error in
                    guard let strongSelf = self else { return }
                    if error != nil {
                        self?.present(Utils.shared.showError(message: "Error with Registration! Try Again!"), animated: true)
                        return
                    }
                    
                    var user = FIRUser()
                    user.email = authResult?.user.email
                    user.name = authResult?.user.displayName
                    user.uid = authResult?.user.uid
                    
                    if let encoded = try? JSONEncoder().encode(user) {
                        let defaults = UserDefaults.standard
                        defaults.set(encoded, forKey: "FIRUser")
                    }
                    
                    let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
                    let controller = storyboard.instantiateViewController(identifier: "DashboardViewController") as! DashboardViewController
                    controller.modalPresentationStyle = .fullScreen
                    self?.present(controller, animated: true)
                }
            }
        }
    }
    
    @objc func openDashboard(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { result, error in
                
                
                if error != nil {
                    return
                }
                
                var user = FIRUser()
                user.email = result?.user.email
                user.name = result?.user.displayName
                user.uid = result?.user.uid
                
                if let encoded = try? JSONEncoder().encode(user) {
                    let defaults = UserDefaults.standard
                    defaults.set(encoded, forKey: "FIRUser")
                }
                
                let storyboard = UIStoryboard(name: "Dashboard", bundle: nil)
                let controller = storyboard.instantiateViewController(identifier: "DashboardViewController") as! DashboardViewController
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true)
            }
        }
    }
}
