////
////  CoreDataController.swift
////  Oh_My-Transport
////
////  Created by OriWuKids on 28/5/19.
////  Copyright © 2019 wgon0001. All rights reserved.
////
//
//import Foundation
//import CoreData
//
//class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate{
//    var listeners = MulticaseDelegate<DatabaseListener>()
//    var persistantContainer: NSPersistentContainer
//    
//    //Results
//    var allStopsFetchedResultController: NSFetchedResultsController<FavStop>?
//    var allRoutesFetchedResultController: NSFetchedResultsController<FavRoute>?
//    
//    override init() {
//        persistantContainer = NSPersistentContainer(name: "localTransportData")
//        persistantContainer.loadPersistentStores(){(description, error) in
//            if let error = error{
//                fatalError("Failed to load CoreData Stack: \(error)")
//            }
//        }
//        super.init()
//    }
//    
//    func saveContext(){
//        if persistantContainer.viewContext.hasChanges{
//            do {
//                try persistantContainer.viewContext.save()
//            } catch{
//                fatalError("Failed to save data to CoreData: \(error)")
//            }
//        }
//    }
//    
//    func addStop(stopData: FavStopData) -> FavStop {
//        let stop = NSEntityDescription.insertNewObject(forEntityName: "FavStop", into: persistantContainer.viewContext) as! FavStop
//        stop.stopId = FavStopData.stopId
//        stop.routeType = FavStopData.routeType
//        stop.stopName = FavStopData.stopName
//        stop.stopSuburb = FavStopData.stopSuburb
//        saveContext()
//        return stop
//    }
//    
//    func addRoute(routeData: FavRouteData) -> FavRoute {
//        let route = NSEntityDescription.insertNewObject(forEntityName: "FavRoute", into: persistantContainer.viewContext) as! FavRoute
//        route.routeId = FavRouteData.routeId
//        route.routeType = FavRouteData.routeType
//        saveContext()
//        return route
//    }
//    
//    func addListener(listener: DatabaseListener) {
//        listeners.addDelegate(listener)
//        
//        listener.onStopListChange(stopList: fetchAllStops())
//        listener.onRouteListChange(routeList: fetchAllRoutes())
//    }
//    
//    func removeListener(listener: DatabaseListener) {
//        listeners.removeDelegate(listener)
//    }
//    
//    func fetchAllRoutes() -> [FavRoute]{
//        if allRoutesFetchedResultController == nil{
//            let fetchRequest: NSFetchRequest<FavRoute> = FavRoute.fetchRequest()
//            let routeSortDescriptor = NSSortDescriptor(key: "routeId", ascending: true)
//            fetchRequest.sortDescriptors = [routeSortDescriptor]
//            allRoutesFetchedResultController = NSFetchedResultsController<FavRoute>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
//            allRoutesFetchedResultController?.delegate = self
//            do {
//                try allRoutesFetchedResultController?.performFetch()
//            } catch {
//                print("CoreData routes fetch failed:\(error)")
//            }
//        }
//        var routes = [FavRoute]()
//        if allRoutesFetchedResultController?.fetchedObjects != nil{
//            routes = (allRoutesFetchedResultController?.fetchedObjects)!
//        }
//        return routes
//    }
//    
//    func fetchAllStops() -> [FavStop]{
//        if allStopsFetchedResultController == nil {
//            let fetchRequest: NSFetchRequest<FavStop> = FavStop.fetchRequest()
//            let nameSortDescriptor = NSSortDescriptor(key: "stopId", ascending: true)
//            fetchRequest.sortDescriptors = [nameSortDescriptor]
//            allStopsFetchedResultController = NSFetchedResultsController<FavStop>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
//            allStopsFetchedResultController?.delegate = self
//        }
//        do {
//            try allStopsFetchedResultController?.performFetch()
//        } catch {
//            print("CoreData stops fetch failed:\(error)")
//        }
//        var stops = [FavStop]()
//        if allStopsFetchedResultController?.fetchedObjects != nil{
//            stops = (allStopsFetchedResultController?.fetchedObjects)!
//        }
//        return stops
//    }
//    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        listeners.invoke{(listener) in
//            listener.onStopListChange(stopList: fetchAllStops())
//            listener.onRouteListChange(routeList: fetchAllRoutes())
//        }
//    }
//}
