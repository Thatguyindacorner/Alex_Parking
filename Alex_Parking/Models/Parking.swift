//
//  Parking.swift
//  Alex_Parking
//
//  Created by Alex Olechnowicz on 2023-03-28.
//

import Foundation
import FirebaseFirestoreSwift

class Parking: Codable{
    
    @DocumentID var id: String? = "\(UUID())"
    
    var plateID: String = "" //2-8 alphanumeric charactors
    
    var buildingCode: String = "" //5 alphanumeric charactors
    var pHours: Int = 1 //<1, 4, 12, 24
    var roomNum: String = "" //2-5 alphanumeric charactors
    
    var pLocation: String = "" //latLng or street address (convert to address)
    var pDateTime: Date = Date() //system data/time
    
    init(){}
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decode(DocumentID<String>.self, forKey: .id)
        self.plateID = try container.decode(String.self, forKey: .plateID)
        self.buildingCode = try container.decode(String.self, forKey: .buildingCode)
        self.pHours = try container.decode(Int.self, forKey: .pHours)
        self.roomNum = try container.decode(String.self, forKey: .roomNum)
        self.pLocation = try container.decode(String.self, forKey: .pLocation)
        self.pDateTime = try container.decode(Date.self, forKey: .pDateTime)
    }
    
}
