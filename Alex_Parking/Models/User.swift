//
//  User.swift
//  Alex_Parking
//
//  Created by Alex Olechnowicz on 2023-03-28.
//

import Foundation
import FirebaseFirestoreSwift

class UserModel: Codable{
    @DocumentID var id: String?
    
    var uid: String = ""
    
    var email: String = ""
    var password: String = ""
    
    var name: String = ""
    var number: String = ""
    var licensePlates: [String] = []
    
    //var parkings: [Parking] = []
}
