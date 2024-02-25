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
import CoreML
import Vision

class AddIssueViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var addIssueTblViw: UITableView!
    @IBOutlet weak var backBtn: UIButton!
    
    var imageIssue: UIImage? = nil
    var activityView : UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    var locationManager: CLLocationManager?
    var imageURL: URL? = nil
    var pincode = ""
    
    var optionSelected = 1
    
    var request: VNCoreMLRequest?
    var visionModel: VNCoreMLModel?
    
    var locationUrl = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        locationManager?.requestWhenInUseAuthorization()
        
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
        activityView.color = .black
        self.view.addSubview(activityView)
        
        submitBtn.backgroundColor = CustomColors.shared.primaryLight
        submitBtn.setTitleColor(.white, for: .normal)
        Utils.shared.cornerRadius(view: submitBtn)
        addIssueTblViw.register(UINib(nibName: "AddIssueTableViewCell", bundle: nil), forCellReuseIdentifier: "AddIssueTableViewCell")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //show initial popup
            let alert = UIAlertController(title: "We have automated things for you!", message: "Do you want to manually enter the data or auto detect by our application?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "AUTO DETECT", style: .default) {_ in
                self.optionSelected = 1
                self.locationManager?.requestLocation()
                
                let vc = UIImagePickerController()
                vc.sourceType = .camera
                vc.allowsEditing = false
                vc.delegate = self
                self.present(vc, animated: true)
            })
            alert.addAction(UIAlertAction(title: "ENTER MANUALLY", style: .cancel) {_ in
                self.optionSelected = 2
                self.activityView.startAnimating()
                self.locationManager?.requestLocation()
            })
            self.present(alert, animated: true)
        }
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
                 "landmark": self.locationUrl == "" ? cell.txtFldLandmark.text : self.locationUrl,
                 "pincode": cell.txtFldLocation.text,
                 "current_date": Utils.shared.getCurrentDate(),
                 "image_url": self.imageURL?.absoluteString,
                 "uid": Auth.auth().currentUser!.uid,
                 "issue_id": Utils.shared.generateRandomIssueID(),
                 "status": "Open",
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
    
    
    private func analyzeImage(image: UIImage?) {
        guard let buffer = image?.resize(size: CGSize(width: 150, height: 150))?
            .getCVPixelBuffer() else {
            return
        }
        
//        do {
//            let config = MLModelConfiguration()
//            let model = try PublicEye(configuration: config)
//            let input = PublicEyeInput(conv2d_input: buffer)
//            
//            let output = try model.prediction(input: input)
//            let text = output.IdentityShapedArray
//            if text.scalars[0] < text.scalars[1] {
//                print("Pothole spotted in the given location. Requesting the concerned authorities to kindly fix it")
//            }
//            else {
//                print("Great Road, no complains")
//            }
//            
//        }
//        catch {
//            print(error.localizedDescription)
//        }
        
        do {
            let config = MLModelConfiguration()
            let model = try PredictIssue(configuration: config)
            let input = PredictIssueInput(conv2d_input: buffer)
            
            let output = try model.prediction(input: input)
            let text = output.IdentityShapedArray
            
            if text.scalars.firstIndex(of: text.scalars.max() ?? 0) == 2 || text.scalars.firstIndex(of: text.scalars.max() ?? 0) == 1{
                if let cell = self.addIssueTblViw.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddIssueTableViewCell {
                    cell.txtFldDescription.text = "Pothole found"
                }
            }
            else if text.scalars.firstIndex(of: text.scalars.max() ?? 0) == 0 {
                
                self.imageIssue = nil
                self.imageURL = nil
                self.addIssueTblViw.reloadData()
                self.present(Utils.shared.showError(message: "It seems there is nothing wrong with this image! Try recapture image."), animated: true)
            }
            
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        
        activityView.startAnimating()
        
        self.imageIssue = image
        self.addIssueTblViw.reloadData()
        
        if optionSelected == 1 {
            analyzeImage(image: image)
        }
        
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

extension AddIssueViewController {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            print("When user did not yet determined")
        case .restricted:
            print("Restricted by parental control")
        case .denied:
            print("When user select option Dont't Allow")
        case .authorizedWhenInUse:
            print("When user select option Allow While Using App or Allow Once")
            locationManager?.requestAlwaysAuthorization()
        default:
            print("default")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
        
        print("http://maps.google.com/?ll=\(location.coordinate.latitude),\(location.coordinate.longitude)")
        self.locationUrl = "http://maps.google.com/?ll=\(location.coordinate.latitude),\(location.coordinate.longitude)"
        self.activityView.stopAnimating()
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: { (placemarks, error) -> Void in
            guard let getlocation = placemarks?.first?.postalCode else { print("Returned Nil"); return }
            self.pincode = getlocation
            
            if let cell = self.addIssueTblViw.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddIssueTableViewCell {
                cell.txtFldLocation.text = self.pincode
                cell.txtFldLandmark.text = self.locationUrl
                self.addIssueTblViw.reloadData()
            }
            
        })
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //
    }
}
