//
//  CoreDataStack.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 5/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    var container: NSPersistentContainer{
        let container = NSPersistentContainer(name: "localTransportData")
        container.loadPersistentStores{ (description,error) in
            // Responsible for loading data model and setting up a store to save stops / routes to local disk
            guard error == nil else{
                print("Coredata stack error:\(error!)",error!)
                return
            }
        }
        return container
    }
    
    // Manage (CRUD) a collection of managed stops / routes
    var managedContext: NSManagedObjectContext{
        return container.viewContext
    }
}
