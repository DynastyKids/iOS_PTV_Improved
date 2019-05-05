//
//  Disruption.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 6/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

// Data class containing information about basic disruption info. Valid until App destoried

import Foundation
import UIKit

class Disruption: NSObject {
    var disruption_id: Int
    var title: String
    var url: String
    var descriptions: String
    var disruption_status: String
    var disruption_type: String
    var published_on: Date
    var last_updated: Date
    var from_date: Date
    var to_date: Date
    
    init(disruption_id: Int,title: String,url: String,descriptions: String,disruption_status: String, disruption_type: String,published_on: Date,last_updated: Date,from_date: Date,to_date: Date) {
        self.disruption_id = disruption_id
        self.title = title
        self.url = url
        self.descriptions = descriptions
        self.disruption_status = disruption_status
        self.disruption_type = disruption_type
        self.published_on = published_on
        self.last_updated = last_updated
        self.from_date = from_date
        self.to_date = to_date
    }
}
