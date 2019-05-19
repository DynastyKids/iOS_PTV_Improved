//
//  FavStop+CoreDataProperties.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 20/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//
//

import Foundation
import CoreData


extension FavStop {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavStop> {
        return NSFetchRequest<FavStop>(entityName: "FavStop")
    }

    @NSManaged public var routeType: Int32
    @NSManaged public var stopId: Int32
    @NSManaged public var stopName: String?
    @NSManaged public var stopSuburb: String?

}
