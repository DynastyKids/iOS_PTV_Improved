//
//  FavStopData.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 28/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import Foundation

class FavStopData: NSObject, Decodable{
    var stopSuburb: String?
    var stopName: String?
    var stopId: Int?
    var routeType: Int?
    
    private enum CodingKeys: String, CodingKey{
        case stopSuburb
        case stopName
        case stopId
        case routeType
    }
    
    required init(from decoder: Decoder) throws {
        let StopContainer = try decoder.container(keyedBy: CodingKeys.self)
        
        self.routeType = try StopContainer.decode(Int.self, forKey: .routeType)
        self.stopId = try StopContainer.decode(Int.self, forKey: .stopId)
        self.stopSuburb = try StopContainer.decode(String.self, forKey: .stopSuburb)
        self.stopName = try StopContainer.decode(String.self, forKey: .stopName)
    }
}
