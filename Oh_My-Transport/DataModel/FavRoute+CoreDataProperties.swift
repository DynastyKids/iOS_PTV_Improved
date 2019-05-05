//
//  FavRoute+CoreDataProperties.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 5/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//
//

import Foundation
import CoreData


extension FavRoute {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavRoute> {
        return NSFetchRequest<FavRoute>(entityName: "FavRoute")
    }

    @NSManaged public var route_id: Int16
    @NSManaged public var route_name: String?
    @NSManaged public var route_number: String?
    @NSManaged public var route_type: Int16

}
