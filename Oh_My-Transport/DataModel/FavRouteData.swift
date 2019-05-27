//
//  FavRouteData.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 28/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import Foundation

class FavRouteData: NSObject, Decodable{
    var routeType: Int?
    var routeId: Int?
    
    private enum CodingKeys: String, CodingKey{
        case routeType
        case routeId
    }
    
    required init(from decoder: Decoder) throws {
        let routeContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.routeType = try routeContainer.decode(Int.self, forKey: .routeType)
        self.routeId = try routeContainer.decode(Int.self, forKey: .routeId)
    }
}
