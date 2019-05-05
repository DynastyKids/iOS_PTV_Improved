//
//  FavStop+CoreDataProperties.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 5/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//
//

import Foundation
import CoreData


extension FavStop {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavStop> {
        return NSFetchRequest<FavStop>(entityName: "FavStop")
    }

    @NSManaged public var route_type: Int16
    @NSManaged public var stop_id: Int32
    @NSManaged public var stop_latitude: Float
    @NSManaged public var stop_longitude: Float
    @NSManaged public var stop_name: String?
    @NSManaged public var stop_suburb: String?

}
