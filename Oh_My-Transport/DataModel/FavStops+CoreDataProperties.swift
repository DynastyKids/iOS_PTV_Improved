//
//  FavStops+CoreDataProperties.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 5/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//
//

import Foundation
import CoreData


extension FavStops {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavStops> {
        return NSFetchRequest<FavStops>(entityName: "FavStops")
    }

    @NSManaged public var routeDirectionid: Int16
    @NSManaged public var routeID: Int32
    @NSManaged public var routeName: String?
    @NSManaged public var routeType: Int32

}
