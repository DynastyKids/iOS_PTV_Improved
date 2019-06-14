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
    var nearbyStops: [StopGeosearch] = []
    
    // MARK: - Saved Stops property
    var stopId: [Int] = []
    var stopName: [String] = []
    var routeType: [Int] = []
    var stopSuburb: [String] = []
    
    // MARK: - Properties used by routes cell
    let coreDataStack = CoreDataStack()
    var stopFetchedResultsController: NSFetchedResultsController<FavStop>!
    var routeFetchedResultsController: NSFetchedResultsController<FavRoute>!
    
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
            var nearbyStopsDeaprtureSequence: [Departure] = []      // Departure data:Store all excesss data
            cell.stopNameLabel.text = nearbystops.stopName
            cell.stopSuburbLabel.text = nearbystops.stopSuburb
            cell.stopSuburbLabel.textColor = UIColor.black
            cell.nearbyTextLabel.text = "*Near By Stop, \(Int(nearbystops.stopDistance!))m away"
            cell.nearbyTextLabel.textColor = UIColor.gray
            
            // Fetching data inside (Departure time)
            _ = URLSession.shared.dataTask(with: URL(string: nextDepartureURL(routeType: nearbystops.routeType!, stopId: nearbystops.stopId!))!){ (data, response, error) in
                if error != nil {
                    print("Next departure fetch failed:\(error!)")
                    return
                }
                do{
                    // using JSON Dictonary to fetch Route data
                    var avoidRouteList: [Int] = []       // Create a list avoiding fetch route with "combined"
                    let nextDepartureDictonary: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                    let nextDepartRoutes = nextDepartureDictonary.value(forKey: "routes") as! NSDictionary
                    var nextDepartRoutesData:[RouteWithStatus] = []
                    for(_, value) in nextDepartRoutes{
                        let nextDepartRouteData: NSDictionary = value as! NSDictionary
                        var routeGtfsId: String = ""
                        var routeRouteType: Int = 0
                        var routeId: Int = 0
                        var routeName: String = ""
                        var routeNumber: String = ""
                        for(key2, value2) in nextDepartRouteData{
                            if "\(key2)" == "route_gtfs_id" && (value2 is NSNull) == false{
                                routeGtfsId = value2 as! String
                            }else if "\(key2)" == "route_type" && (value2 is NSNull) == false{
                                routeRouteType = value2 as! Int
                            }else if "\(key2)" == "route_id" && (value2 is NSNull) == false{
                                routeId = value2 as! Int
                            }else if "\(key2)" == "route_name" && (value2 is NSNull) == false{
                                routeName = value2 as! String
                            }else if "\(key2)" == "route_number" && (value2 is NSNull) == false{
                                    routeNumber = value2 as! String
                            }
                        }
                        if routeNumber.contains("combined"){
                            avoidRouteList.append(routeId)
                        }
                        nextDepartRoutesData.append(RouteWithStatus.init(routeType: routeRouteType, routeId: routeId, routeName: routeName, routeNumber: routeNumber, GtfsId: routeGtfsId))
                    }
                    
                    let nextDepartureData = try JSONDecoder().decode(DeparturesResponse.self, from: data!)
                    if nextDepartureData.departures?.count ?? 0 > 0 {
                        if avoidRouteList.count > 0 {
                            for eachDeparture in nextDepartureData.departures!{
                                var appendFlag = true
                                for eachRouteId in avoidRouteList{
                                    if eachRouteId == eachDeparture.routesId{
                                        appendFlag = false
                                        break
                                    }
                                }
                                if appendFlag == true{
                                    nearbyStopsDeaprtureSequence.append(eachDeparture)
                                }
                            }
                        } else {
                            nearbyStopsDeaprtureSequence = nextDepartureData.departures!
                        }
                    }
                    
                    DispatchQueue.main.async {
                        if nextDepartureData.departures?.count ?? 0 > 0 {
                            // Route 0
                            cell.departure0Time.text = Iso8601Countdown(iso8601Date: (nearbyStopsDeaprtureSequence[0].estimatedDepartureUTC) ?? ((nearbyStopsDeaprtureSequence[0].scheduledDepartureUTC ?? nil)!), status: false)
                            cell.departure0Time.textColor = UIColor.black
                            let searchRouteId0 = nearbyStopsDeaprtureSequence[0].routesId
                            for each in nextDepartRoutesData{
                                if searchRouteId0 == each.routeId{
                                    cell.departure0Route.backgroundColor = changeColorByRouteType(routeType: each.routeType!)
                                    cell.departure0Route.textColor = UIColor.white
                                    if (each.routeType == 2 && each.GtfsId != "" && each.routeNumber == ""){    // Patch fix for regional buses
                                        var routeName: String
                                        routeName = each.GtfsId!
                                        let cuttedName = routeName.index(routeName.startIndex, offsetBy: 2)
                                        routeName = String(routeName[cuttedName...])
                                        cell.departure0Route.text = routeName.uppercased()
                                    }else if(each.routeType == 0 || each.routeType == 3 || each.routeType == nil){
                                        var routeName: String
                                        if (each.GtfsId == "" || each.GtfsId == nil) && (each.routeName != nil && each.routeName != ""){
                                            routeName = each.routeName!     // City Loop train will having no route gtfsid
                                            cell.departure0Route.text = routeName.uppercased()
                                        } else{
                                            routeName = each.GtfsId!
                                            let cuttedName = routeName.index(routeName.startIndex, offsetBy: 2)
                                            cell.departure0Route.text = String(routeName[cuttedName...])
                                        }
                                    }else{
                                        cell.departure0Route.text = each.routeNumber
                                    }
                                }
                            }
                            // Route 1
                            cell.departure1Time.text = Iso8601Countdown(iso8601Date: (nearbyStopsDeaprtureSequence[1].estimatedDepartureUTC) ?? ((nearbyStopsDeaprtureSequence[1].scheduledDepartureUTC ?? nil)!), status: false)
                            cell.departure1Time.textColor = UIColor.black
                            let searchRouteId1 = nearbyStopsDeaprtureSequence[1].routesId
                            for each in nextDepartRoutesData{
                                if searchRouteId1 == each.routeId{
                                    cell.departure1Route.backgroundColor = changeColorByRouteType(routeType: each.routeType!)
                                    cell.departure1Route.textColor = UIColor.white
                                    if (each.routeType == 2 && each.GtfsId != "" && each.routeNumber == ""){    // Patch fix for regional buses
                                        var routeName: String
                                        routeName = each.GtfsId!
                                        let cuttedName = routeName.index(routeName.startIndex, offsetBy: 2)
                                        routeName = String(routeName[cuttedName...])
                                        cell.departure1Route.text = routeName.uppercased()
                                    }else if(each.routeType == 0 || each.routeType == 3 || each.routeType == nil){
                                        var routeName: String
                                        if (each.GtfsId == "" || each.GtfsId == nil) && (each.routeName != nil && each.routeName != ""){
                                            routeName = each.routeName!     // City Loop train will having no route gtfsid
                                            cell.departure1Route.text = routeName.uppercased()
                                        } else{
                                            routeName = each.GtfsId!
                                            let cuttedName = routeName.index(routeName.startIndex, offsetBy: 2)
                                            cell.departure1Route.text = String(routeName[cuttedName...])
                                        }
                                    }else{
                                        cell.departure1Route.text = each.routeNumber
                                    }
                                }
                            }
                            // Route 2
                            cell.departure2Time.text = Iso8601Countdown(iso8601Date: (nearbyStopsDeaprtureSequence[2].estimatedDepartureUTC) ?? ((nearbyStopsDeaprtureSequence[2].scheduledDepartureUTC ?? nil)!), status: false)
                            cell.departure2Time.textColor = UIColor.black
                            let searchRouteId2 = nearbyStopsDeaprtureSequence[2].routesId
                            for each in nextDepartRoutesData{
                                if searchRouteId2 == each.routeId{
                                    cell.departure2Route.backgroundColor = changeColorByRouteType(routeType: each.routeType!)
                                    cell.departure2Route.textColor = UIColor.white
                                    if (each.routeType == 2 && each.GtfsId != "" && each.routeNumber == ""){    // Patch fix for regional buses
                                        var routeName: String
                                        routeName = each.GtfsId!
                                        let cuttedName = routeName.index(routeName.startIndex, offsetBy: 2)
                                        routeName = String(routeName[cuttedName...])
                                        cell.departure0Route.text = routeName.uppercased()
                                    }else if(each.routeType == 0 || each.routeType == 3 || each.routeType == nil){
                                        var routeName: String
                                        if (each.GtfsId == "" || each.GtfsId == nil) && (each.routeName != nil && each.routeName != ""){
                                            routeName = each.routeName!     // City Loop train will having no route gtfsid
                                            cell.departure2Route.text = routeName.uppercased()
                                        } else{
                                            routeName = each.GtfsId!
                                            let cuttedName = routeName.index(routeName.startIndex, offsetBy: 2)
                                            cell.departure2Route.text = String(routeName[cuttedName...])
                                        }
                                    }else{
                                        cell.departure2Route.text = each.routeNumber
                                    }
                                }
                            }
                        }
                    }
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
                    var avoidRouteList: [Int] = []
                    var savedStopsDeaprtureSequence: [Departure] = []
                    let nextDepartureDictonary: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                    let nextDepartRoutes = nextDepartureDictonary.value(forKey: "routes") as! NSDictionary
                    var nextDepartRoutesData:[RouteWithStatus] = []
                    for(_, value) in nextDepartRoutes{
                        let nextDepartRouteData: NSDictionary = value as! NSDictionary
                        var routeGtfsId: String = ""
                        var routeRouteType: Int = 0
                        var routeId: Int = 0
                        var routeName: String = ""
                        var routeNumber: String = ""
                        for(key2, value2) in nextDepartRouteData{
                            if "\(key2)" == "route_gtfs_id"{
                                routeGtfsId = value2 as! String
                            }else if "\(key2)" == "route_type"{
                                routeRouteType = value2 as! Int
                            }else if "\(key2)" == "route_id"{
                                routeId = value2 as! Int
                            }else if "\(key2)" == "route_name"{
                                routeName = value2 as! String
                            }else if "\(key2)" == "route_number"{
                                routeNumber = value2 as! String
                            }
                        }
                        if routeNumber.contains("combined"){
                            avoidRouteList.append(routeId)
                        }
                        nextDepartRoutesData.append(RouteWithStatus.init(routeType: routeRouteType, routeId: routeId, routeName: routeName, routeNumber: routeNumber, GtfsId: routeGtfsId))
                    }
                    let nextDepartureData = try JSONDecoder().decode(DeparturesResponse.self, from: data!)
                    if nextDepartureData.departures?.count ?? 0 > 0 {
                        if avoidRouteList.count > 0 {
                            for eachDeparture in nextDepartureData.departures!{
                                var appendFlag = true
                                for eachRouteId in avoidRouteList{
                                    if eachRouteId == eachDeparture.routesId{
                                        appendFlag = false
                                        break
                                    }
                                }
                                if appendFlag == true{
                                    savedStopsDeaprtureSequence.append(eachDeparture)
                                }
                            }
                        } else {
                            savedStopsDeaprtureSequence = nextDepartureData.departures!
                        }
                    }

                    DispatchQueue.main.async {
                        if nextDepartureData.departures != nil{
                            // Route 0
                            cell.departure0Time.text = Iso8601Countdown(iso8601Date: (savedStopsDeaprtureSequence[0].estimatedDepartureUTC) ?? ((savedStopsDeaprtureSequence[0].scheduledDepartureUTC ?? nil)!), status: false)
                            cell.departure0Time.textColor = UIColor.black
                            let searchRouteId0 = savedStopsDeaprtureSequence[0].routesId
                            for each in nextDepartRoutesData{
                                if searchRouteId0 == each.routeId{
                                    cell.departure0Route.backgroundColor = changeColorByRouteType(routeType: each.routeType!)
                                    cell.departure0Route.textColor = UIColor.white
                                    if (each.routeType == 2 && each.GtfsId != "" && each.routeNumber == ""){    // Patch fix for regional buses
                                        var routeName: String
                                        routeName = each.GtfsId!
                                        let cuttedName = routeName.index(routeName.startIndex, offsetBy: 2)
                                        routeName = String(routeName[cuttedName...])
                                        cell.departure0Route.text = routeName.uppercased()
                                    }else if(each.routeType == 0 || each.routeType == 3 || each.routeType == nil){
                                        var routeName: String
                                        if (each.GtfsId == "" || each.GtfsId == nil) && (each.routeName != nil && each.routeName != ""){
                                            routeName = each.routeName!     // City Loop train will having no route gtfsid
                                            cell.departure0Route.text = routeName.uppercased()
                                        } else{
                                            routeName = each.GtfsId!
                                            let cuttedName = routeName.index(routeName.startIndex, offsetBy: 2)
                                            cell.departure0Route.text = String(routeName[cuttedName...])
                                        }
                                    }else{
                                        cell.departure0Route.text = each.routeNumber
                                    }
                                }
                            }
                            // Route 1
                            cell.departure1Time.text = Iso8601Countdown(iso8601Date: (savedStopsDeaprtureSequence[1].estimatedDepartureUTC) ?? ((savedStopsDeaprtureSequence[1].scheduledDepartureUTC ?? nil)!), status: false)
                            cell.departure1Time.textColor = UIColor.black
                            let searchRouteId1 = savedStopsDeaprtureSequence[1].routesId
                            for each in nextDepartRoutesData{
                                if searchRouteId1 == each.routeId{
                                    cell.departure1Route.backgroundColor = changeColorByRouteType(routeType: each.routeType!)
                                    cell.departure1Route.textColor = UIColor.white
                                    if (each.routeType == 2 && each.GtfsId != "" && each.routeNumber == ""){    // Patch fix for regional buses
                                        var routeName: String
                                        routeName = each.GtfsId!
                                        let cuttedName = routeName.index(routeName.startIndex, offsetBy: 2)
                                        routeName = String(routeName[cuttedName...])
                                        cell.departure1Route.text = routeName.uppercased()
                                    }else if(each.routeType == 0 || each.routeType == 3 || each.routeType == nil){
                                        var routeName: String
                                        if (each.GtfsId == "" || each.GtfsId == nil) && (each.routeName != nil && each.routeName != ""){
                                            routeName = each.routeName!     // City Loop train will having no route gtfsid
                                            cell.departure1Route.text = routeName
                                        } else{
                                            routeName = each.GtfsId!
                                            let cuttedName = routeName.index(routeName.startIndex, offsetBy: 2)
                                            cell.departure1Route.text = String(routeName[cuttedName...])
                                        }
                                    }else{
                                        cell.departure1Route.text = each.routeNumber
                                    }
                                }
                            }
                            
                            // Route 2
                            cell.departure2Time.text = Iso8601Countdown(iso8601Date: (savedStopsDeaprtureSequence[2].estimatedDepartureUTC) ?? ((savedStopsDeaprtureSequence[2].scheduledDepartureUTC ?? nil)!), status: false)
                            cell.departure2Time.textColor = UIColor.black
                            let searchRouteId2 = savedStopsDeaprtureSequence[2].routesId
                            for each in nextDepartRoutesData{
                                if searchRouteId2 == each.routeId{
                                    cell.departure2Route.backgroundColor = changeColorByRouteType(routeType: each.routeType!)
                                    cell.departure2Route.textColor = UIColor.white
                                    if (each.routeType == 2 && each.GtfsId != "" && each.routeNumber == ""){    // Patch fix for regional buses
                                        var routeName: String
                                        routeName = each.GtfsId!
                                        let cuttedName = routeName.index(routeName.startIndex, offsetBy: 2)
                                        routeName = String(routeName[cuttedName...])
                                        cell.departure2Route.text = routeName.uppercased()
                                    }else if(each.routeType == 0 || each.routeType == 3 || each.routeType == nil){
                                        var routeName: String
                                        if (each.GtfsId == "" || each.GtfsId == nil) && (each.routeName != nil && each.routeName != ""){
                                            routeName = each.routeName!     // City Loop train will having no route gtfsid
                                            cell.departure2Route.text = routeName
                                        } else{
                                            routeName = each.GtfsId!
                                            let cuttedName = routeName.index(routeName.startIndex, offsetBy: 2)
                                            cell.departure2Route.text = String(routeName[cuttedName...])
                                        }
                                    }else{
                                        cell.departure2Route.text = each.routeNumber
                                    }
                                }
                            }
                        }
                    }
                }catch{
                    print("Error:\(error)")
                }
                }.resume()
            return cell
        }
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "savedRouteCell", for: indexPath) as! savedRouteTableViewCell
            let readIndexPath = IndexPath(row: indexPath.row, section: 0)
            let savedRoute = routeFetchedResultsController.object(at: readIndexPath)
            let routeType = Int(savedRoute.routeType)
            _ = URLSession.shared.dataTask(with: URL(string: showRouteInfo(routeId: Int(savedRoute.routeId)))!){ (data, response, error) in
                if error != nil {
                    print("Next departure fetch failed:\(error!)")
                    return
                }
                do{
                    let routeInfo = try JSONDecoder().decode(RouteResponse.self, from: data!)
                    if routeInfo.message != nil {     // Error message response
                        self.displayMessage(title: "Oops!", message: "Reveice error response from server, please try again later")
                        return;
                    }
                    DispatchQueue.main.async {
                        cell.routeNameLabel.text = routeInfo.route?.routeName
                        cell.routeNumberLabel.backgroundColor = changeColorByRouteType(routeType: routeType)
                        cell.routeNumberLabel.textColor = UIColor.white
                        switch routeType{
                        case 0:
                            let routeName: String = routeInfo.route?.GtfsId ?? (routeInfo.route?.routeName)!
                            let cuttedName = routeName.index(routeName.startIndex, offsetBy: 2)
                            cell.routeNumberLabel.text = String(routeName[cuttedName...])
                            cell.routeTypeImage.image = UIImage(named: "trainIcon_PTVColour")
                        case 1:
                            cell.routeNumberLabel.text = routeInfo.route?.routeNumber
                            cell.routeTypeImage.image = UIImage(named: "tramIcon_PTVColour")
                        case 2:
                            cell.routeNumberLabel.text = routeInfo.route?.routeNumber
                            cell.routeTypeImage.image = UIImage(named: "busIcon_PTVColour")
                        case 3:
                            let routeName: String = routeInfo.route?.GtfsId ?? (routeInfo.route?.routeName)!
                            let cuttedName = routeName.index(routeName.startIndex, offsetBy: 2)
                            cell.routeNumberLabel.text = String(routeName[cuttedName...])
                            cell.routeTypeImage.image = UIImage(named: "regionalTrainIcon_PTVColour")
                        case 4:
                            cell.routeNumberLabel.text = routeInfo.route?.routeNumber
                            cell.routeTypeImage.image = UIImage(named: "busIcon_PTVColour")
                        default:
                            break
                        }
                    }
                } catch {
                    print("Error:\(error)")
                }
            }.resume()
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotExist", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {    // Setting Section Name
        case 0:
            if nearbyStops.count == 0 {
                return NSLocalizedString("", comment: "")
            }
            return NSLocalizedString("Nearby Stops:", comment: "Nearby stops")
        case 1:
            if stopFetchedResultsController.sections?[0].numberOfObjects == 0{
                return NSLocalizedString("", comment: "")
            }
            return NSLocalizedString("Saved Stops:", comment: "Favorite stops:")
        case 2:
            if routeFetchedResultsController.sections?[0].numberOfObjects == 0{
                return NSLocalizedString("", comment: "")
            }
            return NSLocalizedString("Saved Routes:", comment: "Favorite Route")
        default:
            return NSLocalizedString("", comment: "")
        }
        return NSLocalizedString("", comment: "")
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1{
            let action = UIContextualAction(style: .destructive, title: "Remove"){(action, view, completion) in
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
        
        let swipeAction = UISwipeActionsConfiguration(actions: [])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
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
            page2.managedContext = stopFetchedResultsController.managedObjectContext
            page2.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        if segue.identifier == "showSavedStop"{
            let page2:StopPageTableViewController = segue.destination as! StopPageTableViewController
            page2.routeType = (routeType[(homeTableView.indexPathForSelectedRow!.row)])
            page2.stopId = (stopId[(homeTableView.indexPathForSelectedRow!.row)])
            page2.managedContext = stopFetchedResultsController.managedObjectContext
            page2.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        if segue.identifier == "routeDirectionSegue"{
            let page2:DirectionsViewController = segue.destination as! DirectionsViewController
            let readIndexPath = IndexPath(row: homeTableView.indexPathForSelectedRow!.row, section: 0)
            let savedRoute = routeFetchedResultsController.object(at: readIndexPath)
            page2.routeId = Int(savedRoute.routeId)
            page2.managedContext = routeFetchedResultsController.managedObjectContext
            page2.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        if segue.identifier == "showAllDisruptions"{
            let page2:DisruptionsTableViewController = segue.destination as! DisruptionsTableViewController
            page2.url = URL(string: disruptionAll())
        }
        if segue.identifier == "showMap"{
            let page2:SelectStopOnMapViewController = segue.destination as! SelectStopOnMapViewController
            page2.managedContext = stopFetchedResultsController.managedObjectContext
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
        displayMessage(title: "Oops~", message: "Unable to access your location, please make sure you have correct setting")
        print("Unable to access location:\(error)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
        
        // Allocate saved stops from CoreData
        // Create Request for CoreData
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
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        homeTableView.reloadData()
        
        // Allocate near by stops
        let nearbyStopurl = URL(string: nearByStops(latitude: locationManager.location?.coordinate.latitude ?? -37.8171571, longtitude: locationManager.location?.coordinate.longitude ?? 144.9663325)) // If value is null, default will set at City.
        _ = URLSession.shared.dataTask(with: nearbyStopurl!){ (data, response, error) in
            if error != nil {
                print("Nearby stop fetch failed")
                return
            }
            do{
                let nearbyData = try JSONDecoder().decode(StopResponseByLocation.self, from: data!)
                guard nearbyData.status?.health == 1 else{
                    return
                }
                self.nearbyStops = nearbyData.stops!
                
                DispatchQueue.main.async {
                    self.navigationItem.title = "Oh My Transport"
                    self.homeTableView.reloadData()
                }
            }
            catch{
                print("Error:\(error)")
            }
            }.resume()
        // End of Allocate near by stops
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle:
            UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
        return
    }
}

extension HomepageViewController: NSFetchedResultsControllerDelegate{
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        homeTableView.endUpdates()
    }
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        homeTableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
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
