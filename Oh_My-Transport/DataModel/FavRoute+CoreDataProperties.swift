//
//  FavRoute+CoreDataProperties.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 19/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//
//

import Foundation
import CoreData


extension FavRoute {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavRoute> {
        return NSFetchRequest<FavRoute>(entityName: "FavRoute")
    }

    @NSManaged public var routeId: Int32
    @NSManaged public var routeType: Int32

}
