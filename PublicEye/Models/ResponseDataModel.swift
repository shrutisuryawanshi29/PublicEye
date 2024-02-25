//
//  ResponseDataModel.swift
//  PublicEye
//
//  Created by Shruti Suryawanshi on 2/24/24.
//

import Foundation

class ResponseDataModel {
    
    var description: String?
    var landmark: String?
    var pincode: String?
    var currentDate: String?
    var imageUrl: String?
    var issueId: String?
    var uid: String?
    var status: String?
    
    init(description: String? = nil, landmark: String? = nil, pincode: String? = nil, currentDate: String? = nil, imageUrl: String? = nil, issueId: String? = nil, uid: String? = nil, status: String? = nil) {
        self.description = description
        self.landmark = landmark
        self.pincode = pincode
        self.currentDate = currentDate
        self.imageUrl = imageUrl
        self.issueId = issueId
        self.uid = uid
        self.status = status
    }
    
}
