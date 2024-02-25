//
//  AddIssueTableViewCell.swift
//  PublicEye
//
//  Created by Shruti Suryawanshi on 2/24/24.
//

import UIKit
import MaterialTextField

class AddIssueTableViewCell: UITableViewCell {

    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var imgViw: UIImageView!
    
    @IBOutlet weak var txtFldLocation: MFTextField!
    @IBOutlet weak var txtFldLandmark: MFTextField!
    @IBOutlet weak var txtFldDescription: MFTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        Utils.shared.setupTextField(textfield: txtFldLocation, placeholder: "Pincode")
        Utils.shared.setupTextField(textfield: txtFldLandmark, placeholder: "Landmark")
        Utils.shared.setupTextField(textfield: txtFldDescription, placeholder: "Description")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
