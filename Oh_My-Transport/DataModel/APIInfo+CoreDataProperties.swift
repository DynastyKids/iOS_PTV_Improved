//
//  APIInfo+CoreDataProperties.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 19/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//
//

import Foundation
import CoreData


extension APIInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<APIInfo> {
        return NSFetchRequest<APIInfo>(entityName: "APIInfo")
    }

    @NSManaged public var apiKey: String?
    @NSManaged public var userid: String?

}
