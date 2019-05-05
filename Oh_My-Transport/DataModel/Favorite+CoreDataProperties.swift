//
//  Favorite+CoreDataProperties.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 5/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//
//

import Foundation
import CoreData


extension Favorite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favorite> {
        return NSFetchRequest<Favorite>(entityName: "Favorite")
    }

    @NSManaged public var routeDirectionid: Int32
    @NSManaged public var routeid: Int32
    @NSManaged public var routeType: Int32
    @NSManaged public var stopid: Int32
    @NSManaged public var routeName: String?
    @NSManaged public var stopName: String?

}
