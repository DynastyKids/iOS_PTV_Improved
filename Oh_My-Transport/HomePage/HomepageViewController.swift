//
//  HomepageViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 20/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import CoreLocation

class HomepageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var homeTableView: UITableView!
    
    let locationManager = CLLocationManager()
    var nslock = NSLock()
    var currentLocation:CLLocation!
    
    // MARK: - Nearby Stops property
    var nearbyStops: [stopGeosearch] = []
    var nearbyStopsDeaprtureSequence: [Departure] = []      // Departure data:Store all excesss data
    
    // MARK: - Saved Stops property
    var stopId: [Int] = []
    var stopName: [String] = []
    var routeType: [Int] = []
    var stopSuburb: [String] = []
    
    // MARK: - Properties reused by stops cell
    var nextRouteInfo0: RouteWithStatus? = nil       // Route data: data to be present
    var nextRouteInfo1: RouteWithStatus? = nil       // Route data: data to be present
    var nextRouteInfo2: RouteWithStatus? = nil       // Route data: data to be present
    var nextRouteCount: Int = 0
    
    // MARK: - Properties used by routes cell
    
    let coreDataStack = CoreDataStack()
    var stopFetchedResultsController: NSFetchedResultsController<FavStop>!
    var routeFetchedResultsController: NSFetchedResultsController<FavRoute>!
    var filteredRoutes: [FavRoute] = []
    var filteredStops: [FavStop] = []
    
    var lookupRouteName: Bool = true
    
    var latitude: Double = 0.0
    var longtitude: Double = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeTableView.delegate = self
        homeTableView.dataSource = self

        //Get user location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Allocate near by 2 stops
        let nearbyStopurl = URL(string: nearByStops(latitude: locationManager.location?.coordinate.latitude ?? -37.8171571, longtitude: locationManager.location?.coordinate.longitude ?? 144.9663325)) // If value is null, default will set at City.
        _ = URLSession.shared.dataTask(with: nearbyStopurl!){ (data, response, error) in
            if error != nil {
                print("Nearby stop fetch failed")
                return
            }
            do{
                let decoder = JSONDecoder()
                let nearbyData = try decoder.decode(StopResponseByLocation.self, from: data!)
                self.nearbyStops = nearbyData.stops!
                
                print(self.nearbyStops.count)   // Fetching time for next depart
                
                DispatchQueue.main.async {
                    self.navigationItem.title = "Oh My Transport"
                    self.homeTableView.reloadData()
                }
            }
            catch{
                print("Error:\(error)")
            }
            }.resume()
        // End of Allocate near by 2 stops
        
        // Allocate saved stops from CoreData
        // Create Request for CD
        let stopsFetchedRequest: NSFetchRequest<FavStop> = FavStop.fetchRequest()
        let stopSortDescriptors = NSSortDescriptor(key: "stopId", ascending: true)
        stopsFetchedRequest.sortDescriptors = [stopSortDescriptors]
        // Initalize Core Data fetch
        stopFetchedResultsController = NSFetchedResultsController(fetchRequest: stopsFetchedRequest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        stopFetchedResultsController.delegate = self
        do {
            try stopFetchedResultsController.performFetch()
        } catch{
            print("Saved Stops Core Data fetching error:\(error)")
        }
        
        // Allocate Saved routes from CoreData
        let routesFetchedRequest: NSFetchRequest<FavRoute> = FavRoute.fetchRequest()
        let routeSortDescriptoprs = NSSortDescriptor(key: "routeId", ascending: true)
        routesFetchedRequest.sortDescriptors = [routeSortDescriptoprs]
        routeFetchedResultsController = NSFetchedResultsController(fetchRequest: routesFetchedRequest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        routeFetchedResultsController.delegate = self
        do {
            try routeFetchedResultsController.performFetch()
        } catch {
            print("Saved Route Core Data fetching error:\(error)")
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return nearbyStops.count    //Show Nearby stops only
        } else if section == 1 {
            return stopFetchedResultsController.sections?[0].numberOfObjects ?? 0
        } else {
            return routeFetchedResultsController.sections?[0].numberOfObjects ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nearbyStopsCell", for: indexPath) as! nearbyStopsTableViewCell
            let nearbystops = nearbyStops[indexPath.row];
            cell.stopNameLabel.text = nearbystops.stopName
            cell.stopSuburbLabel.text = nearbystops.stopSuburb
            cell.stopSuburbLabel.textColor = UIColor.black
            cell.nearbyTextLabel.text = "*Near By Stop    Distance:\(Int(nearbystops.stopDistance!))m"
            cell.nearbyTextLabel.textColor = UIColor.gray
            
            
            // Fetching data inside (Departure time)
            _ = URLSession.shared.dataTask(with: URL(string: nextDepartureURL(routeType: nearbystops.routeType!, stopId: nearbystops.stopId!))!){ (data, response, error) in
                if error != nil {
                    print("Next departure fetch failed:\(error!)")
                    return
                }
                do{
                    let nextDepartureData = try JSONDecoder().decode(DeparturesResponse.self, from: data!)
                    self.nearbyStopsDeaprtureSequence = nextDepartureData.departures!
                    DispatchQueue.main.async {
                        cell.departure0Time.text = Iso8601Countdown(iso8601Date: (self.nearbyStopsDeaprtureSequence[0].estimatedDepartureUTC) ?? ((self.nearbyStopsDeaprtureSequence[0].scheduledDepartureUTC ?? nil)!), status: false)
                        cell.departure1Time.text = Iso8601Countdown(iso8601Date: (self.nearbyStopsDeaprtureSequence[1].estimatedDepartureUTC) ?? ((self.nearbyStopsDeaprtureSequence[1].scheduledDepartureUTC ?? nil)!), status: false)
                        cell.departure2Time.text = Iso8601Countdown(iso8601Date: (self.nearbyStopsDeaprtureSequence[2].estimatedDepartureUTC) ?? ((self.nearbyStopsDeaprtureSequence[2].scheduledDepartureUTC ?? nil)!), status: false)
                    }
                    
                    //                     Fetching Data inside (depart Routes)
                    // Route 0
                    _ = URLSession.shared.dataTask(with: URL(string: showRouteInfo(routeId: self.nearbyStopsDeaprtureSequence[0].routesId!))!){ (data, response, error) in
                        if error != nil {
                            print("Stop information fetch failed:\(error!)")
                            return
                        }
                        do{
                            let decoder = JSONDecoder()
                            let nextRouteData = try decoder.decode(RouteResponse.self, from: data!)
                            self.nextRouteInfo0 = nextRouteData.route!
                            
                            DispatchQueue.main.async {
                                if (self.nextRouteInfo0!.routeType == 0 || self.nextRouteInfo0!.routeType == 3){
                                    let str: String = self.nextRouteInfo0!.GtfsId ?? (self.nextRouteInfo0?.routeName)!
                                    let start = str.index(str.startIndex, offsetBy: 2)
                                    cell.departure0Route.text = String(str[start...])
                                } else {
                                    cell.departure0Route.text = self.nextRouteInfo0!.routeNumber
                                }
                                cell.departure0Route.textColor = UIColor.white
                                cell.departure0Route.backgroundColor = changeColorByRouteType(routeType: (self.nextRouteInfo0?.routeType!)!)
                            }
                        }catch{
                            print("Error:\(error)")
                        }
                        }.resume()
                    // Route 1
                    _ = URLSession.shared.dataTask(with: URL(string: showRouteInfo(routeId: self.nearbyStopsDeaprtureSequence[1].routesId!))!){ (data, response, error) in
                        if error != nil {
                            print("Stop information fetch failed:\(error!)")
                            return
                        }
                        do{
                            let decoder = JSONDecoder()
                            let nextRouteData = try decoder.decode(RouteResponse.self, from: data!)
                            self.nextRouteInfo1 = nextRouteData.route!
                            
                            DispatchQueue.main.async {
                                if (self.nextRouteInfo1!.routeType == 0 || self.nextRouteInfo1!.routeType == 3){
                                    let str: String = self.nextRouteInfo1!.GtfsId ?? (self.nextRouteInfo1?.routeName)!
                                    let start = str.index(str.startIndex, offsetBy: 2)
                                    cell.departure1Route.text = String(str[start...])
                                } else {
                                    cell.departure1Route.text = self.nextRouteInfo1!.routeNumber
                                }
                                cell.departure1Route.textColor = UIColor.white
                                cell.departure1Route.backgroundColor = changeColorByRouteType(routeType: (self.nextRouteInfo1?.routeType!)!)
                            }
                        }catch{
                            print("Error:\(error)")
                        }
                        }.resume()
                    // Route 2
                    _ = URLSession.shared.dataTask(with: URL(string: showRouteInfo(routeId: self.nearbyStopsDeaprtureSequence[2].routesId!))!){ (data, response, error) in
                        if error != nil {
                            print("Stop information fetch failed:\(error!)")
                            return
                        }
                        do{
                            let decoder = JSONDecoder()
                            let nextRouteData = try decoder.decode(RouteResponse.self, from: data!)
                            self.nextRouteInfo2 = nextRouteData.route!
                            
                            DispatchQueue.main.async {
                                if (self.nextRouteInfo2!.routeType == 0 || self.nextRouteInfo2!.routeType == 3){
                                    let str: String = self.nextRouteInfo2!.GtfsId ?? (self.nextRouteInfo2?.routeName)!
                                    let start = str.index(str.startIndex, offsetBy: 2)
                                    cell.departure2Route.text = String(str[start...])
                                } else {
                                    cell.departure2Route.text = self.nextRouteInfo2!.routeNumber
                                }
                                cell.departure2Route.textColor = UIColor.white
                                cell.departure2Route.backgroundColor = changeColorByRouteType(routeType: (self.nextRouteInfo2?.routeType!)!)
                            }
                        }catch{
                            print("Error:\(error)")
                        }
                        }.resume()
                    
                }catch{
                    print("Error:\(error)")
                }
                }.resume()
            return cell
        }
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "savedStopsCell", for: indexPath) as! savedStopsTableViewCell
            let readIndexPath = IndexPath(row: indexPath.row, section: 0)
            let savedStop = stopFetchedResultsController.object(at: readIndexPath)
            cell.stopNameLabel.text = savedStop.stopName
            cell.stopSuburbLabel.text = savedStop.stopSuburb
            let savedStopId = savedStop.stopId
            let savedStopType = savedStop.routeType
            
            stopId.append(Int(savedStop.stopId))
            stopName.append(savedStop.stopName ?? "")
            stopSuburb.append(savedStop.stopSuburb ?? "")
            routeType.append(Int(savedStop.routeType))
            
            // Fetching data inside (Departure time)
            _ = URLSession.shared.dataTask(with: URL(string: nextDepartureURL(routeType: Int(savedStopType), stopId: Int(savedStopId)))!){ (data, response, error) in
                if error != nil {
                    print("Next departure fetch failed:\(error!)")
                    return
                }
                do{
                    let nextDepartureData = try JSONDecoder().decode(DeparturesResponse.self, from: data!)
                    self.nearbyStopsDeaprtureSequence = nextDepartureData.departures!
                    DispatchQueue.main.async {
                        cell.departure0Time.text = Iso8601Countdown(iso8601Date: (self.nearbyStopsDeaprtureSequence[0].estimatedDepartureUTC) ?? ((self.nearbyStopsDeaprtureSequence[0].scheduledDepartureUTC ?? nil)!), status: false)
                        cell.departure1Time.text = Iso8601Countdown(iso8601Date: (self.nearbyStopsDeaprtureSequence[1].estimatedDepartureUTC) ?? ((self.nearbyStopsDeaprtureSequence[1].scheduledDepartureUTC ?? nil)!), status: false)
                        cell.departure2Time.text = Iso8601Countdown(iso8601Date: (self.nearbyStopsDeaprtureSequence[2].estimatedDepartureUTC) ?? ((self.nearbyStopsDeaprtureSequence[2].scheduledDepartureUTC ?? nil)!), status: false)
                    }
                    
                    //                     Fetching Data inside (depart Routes)
                    // Route 0
                    _ = URLSession.shared.dataTask(with: URL(string: showRouteInfo(routeId: self.nearbyStopsDeaprtureSequence[0].routesId!))!){ (data, response, error) in
                        if error != nil {
                            print("Stop information fetch failed:\(error!)")
                            return
                        }
                        do{
                            let nextRouteData = try JSONDecoder().decode(RouteResponse.self, from: data!)
                            self.nextRouteInfo0 = nextRouteData.route!
                            if (self.nextRouteInfo0!.routeType == 0 || self.nextRouteInfo0!.routeType == 3){
                                let str: String = self.nextRouteInfo0!.GtfsId!
                                let start = str.index(str.startIndex, offsetBy: 2)
                                cell.departure0Route.text = String(str[start...])
                            } else {
                                cell.departure0Route.text = self.nextRouteInfo0!.routeNumber
                            }
                            cell.departure0Route.textColor = UIColor.white
                            cell.departure0Route.backgroundColor = changeColorByRouteType(routeType: (self.nextRouteInfo0?.routeType!)!)
                        }catch{
                            print("Error:\(error)")
                        }
                        }.resume()
                    // Route 1
                    _ = URLSession.shared.dataTask(with: URL(string: showRouteInfo(routeId: self.nearbyStopsDeaprtureSequence[1].routesId!))!){ (data, response, error) in
                        if error != nil {
                            print("Stop information fetch failed:\(error!)")
                            return
                        }
                        do{
                            let nextRouteData = try JSONDecoder().decode(RouteResponse.self, from: data!)
                            self.nextRouteInfo1 = nextRouteData.route!
                            if (self.nextRouteInfo1!.routeType == 0 || self.nextRouteInfo1!.routeType == 3){
                                let str: String = self.nextRouteInfo1!.GtfsId!
                                let start = str.index(str.startIndex, offsetBy: 2)
                                cell.departure1Route.text = String(str[start...])
                            } else {
                                cell.departure1Route.text = self.nextRouteInfo1!.routeNumber
                            }
                            cell.departure1Route.textColor = UIColor.white
                            cell.departure1Route.backgroundColor = changeColorByRouteType(routeType: (self.nextRouteInfo1?.routeType!)!)
                        }catch{
                            print("Error:\(error)")
                        }
                        }.resume()
                    // Route 2
                    _ = URLSession.shared.dataTask(with: URL(string: showRouteInfo(routeId: self.nearbyStopsDeaprtureSequence[2].routesId!))!){ (data, response, error) in
                        if error != nil {
                            print("Stop information fetch failed:\(error!)")
                            return
                        }
                        do{
                            let nextRouteData = try JSONDecoder().decode(RouteResponse.self, from: data!)
                            self.nextRouteInfo2 = nextRouteData.route!
                            if (self.nextRouteInfo2!.routeType == 0 || self.nextRouteInfo2!.routeType == 3){
                                let str: String = self.nextRouteInfo2!.GtfsId!
                                let start = str.index(str.startIndex, offsetBy: 2)
                                cell.departure2Route.text = String(str[start...])
                            } else {
                                cell.departure2Route.text = self.nextRouteInfo2!.routeNumber
                            }
                            cell.departure2Route.textColor = UIColor.white
                            cell.departure2Route.backgroundColor = changeColorByRouteType(routeType: (self.nextRouteInfo2?.routeType!)!)
                        }catch{
                            print("Error:\(error)")
                        }
                        }.resume()
                    
                }catch{
                    print("Error:\(error)")
                }
                }.resume()
            
            
            return cell
            
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedRouteCell", for: indexPath) as! savedRouteTableViewCell
        let readIndexPath = IndexPath(row: indexPath.row, section: 0)
        let savedRoute = routeFetchedResultsController.object(at: readIndexPath)
        cell.routeNumberLabel.text = savedRoute.routeNumber
        cell.routeNameLabel.text = savedRoute.routeName
        //        cell.routeTypeImage = savedRoute.routeType
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName: String
        switch section {
        case 0:
            sectionName = NSLocalizedString("Nearby Stops:", comment: "Nearby stops")
        case 1:
            sectionName = NSLocalizedString("Saved Stops:", comment: "Favorite stops:")
        case 2:
            sectionName = NSLocalizedString("Saved Routes:", comment: "Favorite Route")
        default:
            sectionName = ""
        }
        return sectionName
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1{
            let action = UIContextualAction(style: .destructive, title: "Remove"){(action, view, completion) in
                print("indexPath = \(indexPath)")
                let OverrideIndexPath = IndexPath(row: indexPath.row, section: 0)
                let item = self.stopFetchedResultsController.object(at: OverrideIndexPath)
                self.stopFetchedResultsController.managedObjectContext.delete(item)
                do{
                    try self.stopFetchedResultsController.managedObjectContext.save()
                    completion(true)
                } catch{
                    print("Delete failed:\(error)")
                }
            }
            action.backgroundColor = UIColor.red
            return UISwipeActionsConfiguration(actions: [action])
        }
        if indexPath.section == 2{
            let action = UIContextualAction(style: .destructive, title: "Remove"){(action, view, completion) in
                let OverrideIndexPath = IndexPath(row: indexPath.row, section: 0)
                let item = self.routeFetchedResultsController.object(at: OverrideIndexPath)
                self.routeFetchedResultsController.managedObjectContext.delete(item)
                do{
                    try self.routeFetchedResultsController.managedObjectContext.save()
                    completion(true)
                } catch{
                    print("Delete failed:\(error)")
                }
            }
            action.backgroundColor = UIColor.red
            return UISwipeActionsConfiguration(actions: [action])
        }
        
        let action = UIContextualAction(style: .destructive, title: "Nothing", handler:{_, _, completion in
            completion(true)
        })
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showNearByStop" {
            let page2:StopPageTableViewController = segue.destination as! StopPageTableViewController
            page2.routeType = (nearbyStops[homeTableView.indexPathForSelectedRow!.row]).routeType!
            page2.stopId = (nearbyStops[homeTableView.indexPathForSelectedRow!.row]).stopId!
            page2.stopSuburb = (nearbyStops[homeTableView.indexPathForSelectedRow!.row]).stopSuburb!
            page2.stopName = (nearbyStops[homeTableView.indexPathForSelectedRow!.row]).stopName!
            page2.managedContext = stopFetchedResultsController.managedObjectContext
        }
        if segue.identifier == "showSavedStop"{
            let page2:StopPageTableViewController = segue.destination as! StopPageTableViewController
            page2.routeType = (routeType[(homeTableView.indexPathForSelectedRow!.row)])
            page2.stopId = (stopId[(homeTableView.indexPathForSelectedRow!.row)])
            page2.stopSuburb = stopSuburb[(homeTableView.indexPathForSelectedRow?.row)!]
            page2.stopName = stopName[(homeTableView.indexPathForSelectedRow?.row)!]
            page2.managedContext = stopFetchedResultsController.managedObjectContext
            page2.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        if segue.identifier == "routeDirectionSegue"{
            let page2:DirectionsViewController = segue.destination as! DirectionsViewController
            let readIndexPath = IndexPath(row: homeTableView.indexPathForSelectedRow!.row, section: 0)
            let savedRoute = routeFetchedResultsController.object(at: readIndexPath)
            page2.routeId = Int(savedRoute.routeId)
            
        }
        if segue.identifier == "showAllDisruptions"{
            let page2:DisruptionsTableViewController = segue.destination as! DisruptionsTableViewController
            page2.url = URL(string: disruptionAll())
        }
    }
    
    // Location functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations location: [CLLocation]) {  // Get User location
        nslock.lock()
        currentLocation = location.last // Using last array to get user location
        latitude = currentLocation.coordinate.latitude
        longtitude = currentLocation.coordinate.longitude
        locationManager.stopUpdatingLocation()
        nslock.unlock()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while get user location:\(error)")
    }
}

extension HomepageViewController: NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        homeTableView.endUpdates()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        homeTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                print("Insert at:\(indexPath)")
                var overrideIndexPath = indexPath
                if controller == stopFetchedResultsController{
                    overrideIndexPath = IndexPath(row: indexPath.row, section: 1)
                }
                if controller == routeFetchedResultsController{
                    overrideIndexPath = IndexPath(row: indexPath.row, section: 2)
                }
                homeTableView.insertRows(at: [overrideIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                print("Delete at:\(indexPath)")
                var overrideIndexPath = indexPath
                if controller == stopFetchedResultsController{
                    overrideIndexPath = IndexPath(row: indexPath.row, section: 1)
                }
                if controller == routeFetchedResultsController{
                    overrideIndexPath = IndexPath(row: indexPath.row, section: 2)
                }
                homeTableView.deleteRows(at: [overrideIndexPath], with: .automatic)
            }
        default:
            break
        }
    }
}


