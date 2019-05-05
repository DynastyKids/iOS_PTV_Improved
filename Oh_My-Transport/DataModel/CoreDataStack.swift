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
        container.loadPersistentStores{
            (description,error) in
            guard error == nil
                else{
                    print("Coredata stack error:\(error!)",error!)
                    return
            }
        }
        return container
    }
    
    // Core data CRUD control
    var managedContext: NSManagedObjectContext{
        return container.viewContext
    }
}
