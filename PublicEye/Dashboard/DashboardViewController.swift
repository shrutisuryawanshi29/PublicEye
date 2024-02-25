//
//  DashboardViewController.swift
//  PublicEye
//
//  Created by Shruti Suryawanshi on 2/24/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DashboardViewController: UIViewController {

    @IBOutlet weak var tblViw: UITableView!
    @IBOutlet weak var btnAddIssue: UIButton!
    
    var responseData = [ResponseDataModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        responseData = []
        let database = Firestore.firestore()
        let query: Query = database.collection("issues").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid)
        
        query.getDocuments(completion: { data, error in
            if error != nil {
                return
            }
            
            for document in data!.documents {
                var dict = document.data()
                self.responseData.append(ResponseDataModel(description: dict["description"] as! String, landmark: dict["landmark"] as! String, pincode: dict["pincode"] as! String, currentDate: dict["current_date"] as! String, imageUrl: dict["image_url"] as! String, issueId: dict["issue_id"] as! String, status: dict["status"] as! String))
            }
            self.tblViw.reloadData()
        })
        
    }
    
    func initialSetup() {
        tblViw.register(UINib(nibName: "DashboardTableViewCell", bundle: nil), forCellReuseIdentifier: "DashboardTableViewCell")
        self.view.backgroundColor = CustomColors.shared.background
        
        btnAddIssue.backgroundColor = CustomColors.shared.primaryLight
        Utils.shared.cornerRadius(view: btnAddIssue, radius: 40.0)
    
        btnAddIssue.setTitle(" ADD ISSUE", for: .normal)
        btnAddIssue.setTitleColor(.white, for: .normal)
    }

    @IBAction func addIssueBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AddIssue", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "AddIssueViewController") as! AddIssueViewController
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true)
    }
    
    @IBAction func btnLogoutClick(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            if let data = UserDefaults.standard.object(forKey: "FIRUser") as? Data,
               let _ = try? JSONDecoder().decode(FIRUser.self, from: data) {
                let defaults = UserDefaults.standard
                defaults.set(nil, forKey: "FIRUser")
                self.dismiss(animated: true)
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

extension DashboardViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.responseData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardTableViewCell", for: indexPath) as! DashboardTableViewCell
        cell.selectionStyle = .none
        Utils.shared.cornerRadius(view: cell.statusViw,radius: 8.0)
        Utils.shared.cornerRadius( view: cell.viewBtn)
        cell.viewBtn.isHidden = true
        cell.viewBtn.backgroundColor = CustomColors.shared.primaryLight
        cell.bgViw.backgroundColor = CustomColors.shared.primaryDark
        cell.bgViw.dropShadow(shadowOpacity: 0.3)
        Utils.shared.cornerRadius(view: cell.bgViw, radius: 10)
        if (responseData[indexPath.row].status == "Closed") {
            cell.statusViw.backgroundColor = .green
        }
        else if (responseData[indexPath.row].status == "Inprogress") {
            cell.statusViw.backgroundColor = .yellow
        }
        else {
            cell.statusViw.backgroundColor = .red
        }
        
        cell.lblIdDate.text = "\(responseData[indexPath.row].issueId!) | \(responseData[indexPath.row].currentDate!)"
        cell.lblDescription.text = "LOCATION: \(responseData[indexPath.row].landmark!)\n\nDESCRIPTION: \(responseData[indexPath.row].description!)"
        cell.lblPincode.text = "ZIPCODE: "+responseData[indexPath.row].pincode!
        
        
        
        return cell
    }
    
    
}
