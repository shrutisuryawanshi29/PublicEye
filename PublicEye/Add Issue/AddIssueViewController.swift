//
//  AddIssueViewController.swift
//  PublicEye
//
//  Created by Shruti Suryawanshi on 2/24/24.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import CoreLocation

class AddIssueViewController: UIViewController {

    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var addIssueTblViw: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    
    var imageIssue: UIImage? = nil
    var activityView : UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    var imageURL: URL? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func openCamera(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = false
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func initialSetup() {
        self.view.backgroundColor = CustomColors.shared.background
        
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        
        submitBtn.backgroundColor = CustomColors.shared.primaryLight
        submitBtn.setTitleColor(.white, for: .normal)
        Utils.shared.cornerRadius(view: submitBtn)
        addIssueTblViw.register(UINib(nibName: "AddIssueTableViewCell", bundle: nil), forCellReuseIdentifier: "AddIssueTableViewCell")
    }
    
    @IBAction func backBtnClick(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func submitBtnClick(_ sender: Any) {
        activityView.startAnimating()
        if let cell = addIssueTblViw.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddIssueTableViewCell {
            if cell.txtFldLocation.text?.isEmpty ?? true {
                self.present(Utils.shared.showError(message: "Enter Location"), animated: true)
            } else if cell.txtFldLandmark.text?.isEmpty ?? true {
                self.present(Utils.shared.showError(message: "Enter Landmark"), animated: true)
            } else if cell.txtFldDescription.text?.isEmpty ?? true {
                self.present(Utils.shared.showError(message: "Enter Description"), animated: true)
            } else if self.imageURL == nil {
                self.present(Utils.shared.showError(message: "Capture Image"), animated: true)
            } else {
                var dict =
                ["description": cell.txtFldDescription.text,
                 "landmark": cell.txtFldLandmark.text,
                 "pincode": cell.txtFldLocation.text,
                 "current_date": Utils.shared.getCurrentDate(),
                 "image_url": self.imageURL?.absoluteString,
                 "uid": Auth.auth().currentUser!.uid,
                 "issue_id": Utils.shared.generateRandomIssueID(),
                ] as [String : Any]
                
                let database = Firestore.firestore()
                var collec = database.collection("issues")
                
                collec.addDocument(data: dict) { error in
                    if error != nil {
                        self.present(Utils.shared.showError(message: error?.localizedDescription ?? ""), animated: true)
                        return
                    }
                    
                    let alert = UIAlertController(title: "Success!!", message: "You have successfully logged the issue", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel){_ in
                        self.dismiss(animated: true)
                    })
                    self.present(alert, animated: true)
                }
                
            }
        }
    }
    
}

extension AddIssueViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddIssueTableViewCell", for: indexPath) as! AddIssueTableViewCell
        cell.selectionStyle = .none
        cell.cameraBtn.backgroundColor = CustomColors.shared.primaryLight
        cell.cameraBtn.tintColor = .white
        cell.cameraBtn.addTarget(self, action: #selector(openCamera(_:)), for: .touchUpInside)
        Utils.shared.cornerRadius(view: cell.cameraBtn)
        
        cell.cameraBtn.setTitle(imageIssue == nil ? "TAKE A PIC" : "RETAKE PIC"  , for: .normal)
        cell.imgViw.image = self.imageIssue
        Utils.shared.cornerRadius(view: cell.imgViw)
        
        cell.txtFldLandmark.delegate = self
        cell.txtFldLocation.delegate = self
        cell.txtFldDescription.delegate = self
        
        return cell
    }
}

extension AddIssueViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        activityView.startAnimating()
        self.imageIssue = image
        self.addIssueTblViw.reloadData()
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {return}
        let storageRef = Storage.storage(url: "gs://publiceye-aaac5.appspot.com").reference()
        let userPhotoRef = storageRef.child(Auth.auth().currentUser!.uid).child("\(Date().timeIntervalSince1970)")
        
        userPhotoRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            
            userPhotoRef.downloadURL { url, error in
                self.activityView.stopAnimating()
                guard let imgurl = url else {return }
                self.imageURL = imgurl
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
