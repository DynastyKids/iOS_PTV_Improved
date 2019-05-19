//
//  homePageContainerTableViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 20/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit
import CommonCrypto
import Foundation
import CoreData
import CoreLocation

class homePageContainerTableViewController: UITableViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    var nslock = NSLock()
    var currentLocation:CLLocation!
    
    var nearbyStops: [stopGeosearch] = []
    var departureSequence: [departure] = []      // Departure data:Store all excesss data
    var nextRouteInfo0: RouteWithStatus? = nil       // Route data: data to be present
    var nextRouteInfo1: RouteWithStatus? = nil       // Route data: data to be present
    var nextRouteInfo2: RouteWithStatus? = nil       // Route data: data to be present
    var nextRouteCount: Int = 0
    
    var stopFetchedResultsController: NSFetchedResultsController<FavStop>!
    //    var routeFetchedResultsController: NSFetchedResultsController<FavRoute>!
    let coreDataStack = CoreDataStack()
    var filteredRoutes: [FavRoute] = []
    var filteredStops: [FavStop] = []
    
    var lookupRouteName: Bool = true
    
    var latitude: Double = 0.0
    var longtitude: Double = 0.0
    
    let hardcodedURL:String = "http://timetableapi.ptv.vic.gov.au"
    let hardcodedDevID:String = "3001122"
    let hardcodedDevKey:String = "3c74a383-c69a-4e8d-b2f8-2e4c598b50b2"
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
                let nearbyData = try decoder.decode(stopResponseByLocation.self, from: data!)
                self.nearbyStops = nearbyData.stops!
                
                print(self.nearbyStops.count)   // Fetching time for next depart
                
                DispatchQueue.main.async {
                    self.navigationItem.title = "Oh My Transport"
                    self.tableView.reloadData()
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
//        stopFetchedResultsController.delegate = self as! NSFetchedResultsControllerDelegate
        
        do {
            try stopFetchedResultsController.performFetch()
        } catch{
            print("Saved Stops Core Data fetching error")
        }
        
        // Allocate Saved routes from CoreData
        //        let routesFetchedRequest: NSFetchRequest<FavRoute> = FavRoute.fetchRequest()
        //        let routeSortDescriptoprs = NSSortDescriptor(key: "routeId", ascending: true)
        //        routesFetchedRequest.sortDescriptors = [routeSortDescriptoprs]
        //        routeFetchedResultsController = NSFetchedResultsController(fetchRequest: routesFetchedRequest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        //        routeFetchedResultsController.delegate = self as? NSFetchedResultsControllerDelegate
        //        do {
        //            try routeFetchedResultsController.performFetch()
        //        } catch {
        //            print("Saved Route Core Data fetching error")
        //        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return nearbyStops.count    //Show Nearby stops only
        } else if section == 1 {
            return stopFetchedResultsController.sections?[0].objects?.count ?? 0
        } else {
            //            return routeFetchedResultsController.sections?[0].objects?.count ?? 0
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nearbyStopsCell", for: indexPath) as! nearbyStopsTableViewCell
            let nearbystops = nearbyStops[indexPath.row];
            cell.stopNameLabel.text = nearbystops.stopName
            cell.stopSuburbLabel.text = nearbystops.stopSuburb
            cell.nearbyTextLabel.text = "Near by: \(Int(nearbystops.stopDistance!))m"
            
            
            // Fetching data inside (Departure time)
            _ = URLSession.shared.dataTask(with: URL(string: nextDepartureByStop(routeType: nearbystops.routeType!, stopId: nearbystops.stopId!))!){ (data, response, error) in
                if error != nil {
                    print("Next departure fetch failed:\(error!)")
                    return
                }
                do{
                    let nextDepartureData = try JSONDecoder().decode(departuresResponse.self, from: data!)
                    self.departureSequence = nextDepartureData.departures
                    DispatchQueue.main.async {
                        cell.departure0Time.text = self.iso8601DateConvert(iso8601Date: (self.departureSequence[0].estimatedDepartureUTC) ?? ((self.departureSequence[0].scheduledDepartureUTC ?? nil)!), withDate: false)
                        cell.departure1Time.text = self.iso8601DateConvert(iso8601Date: (self.departureSequence[1].estimatedDepartureUTC) ?? ((self.departureSequence[1].scheduledDepartureUTC ?? nil)!), withDate: false)
                        cell.departure2Time.text = self.iso8601DateConvert(iso8601Date: (self.departureSequence[2].estimatedDepartureUTC) ?? ((self.departureSequence[2].scheduledDepartureUTC ?? nil)!), withDate: false)
                    }
                    
                    //                     Fetching Data inside (depart Routes)
                    // Route 0
                    _ = URLSession.shared.dataTask(with: URL(string: self.lookupRoutes(routeId: self.departureSequence[0].routesId!))!){ (data, response, error) in
                        if error != nil {
                            print("Stop information fetch failed:\(error!)")
                            return
                        }
                        do{
                            let decoder = JSONDecoder()
                            let nextRouteData = try decoder.decode(routeResponse.self, from: data!)
                            self.nextRouteInfo0 = nextRouteData.route!
                            
                            DispatchQueue.main.async {
                                if (self.nextRouteInfo0!.routeType == 0 || self.nextRouteInfo0!.routeType == 3){
                                    let str: String = self.nextRouteInfo0!.GtfsId!
                                    let start = str.index(str.startIndex, offsetBy: 2)
                                    cell.departure0Route.text = String(str[start...])
                                } else {
                                    cell.departure0Route.text = self.nextRouteInfo0!.routeNumber
                                }
                                cell.departure0Route.textColor = UIColor.white
                                cell.departure0Route.backgroundColor = self.changeColorForRouteBackground(routeType: (self.nextRouteInfo0?.routeType!)!)
                            }
                        }catch{
                            print("Error:\(error)")
                        }
                        }.resume()
                    // Route 1
                    _ = URLSession.shared.dataTask(with: URL(string: self.lookupRoutes(routeId: self.departureSequence[1].routesId!))!){ (data, response, error) in
                        if error != nil {
                            print("Stop information fetch failed:\(error!)")
                            return
                        }
                        do{
                            let decoder = JSONDecoder()
                            let nextRouteData = try decoder.decode(routeResponse.self, from: data!)
                            self.nextRouteInfo1 = nextRouteData.route!
                            
                            DispatchQueue.main.async {
                                if (self.nextRouteInfo1!.routeType == 0 || self.nextRouteInfo1!.routeType == 3){
                                    let str: String = self.nextRouteInfo1!.GtfsId!
                                    let start = str.index(str.startIndex, offsetBy: 2)
                                    cell.departure1Route.text = String(str[start...])
                                } else {
                                    cell.departure1Route.text = self.nextRouteInfo1!.routeNumber
                                }
                                cell.departure1Route.textColor = UIColor.white
                                cell.departure1Route.backgroundColor = self.changeColorForRouteBackground(routeType: (self.nextRouteInfo1?.routeType!)!)
                            }
                        }catch{
                            print("Error:\(error)")
                        }
                        }.resume()
                    // Route 2
                    _ = URLSession.shared.dataTask(with: URL(string: self.lookupRoutes(routeId: self.departureSequence[2].routesId!))!){ (data, response, error) in
                        if error != nil {
                            print("Stop information fetch failed:\(error!)")
                            return
                        }
                        do{
                            let decoder = JSONDecoder()
                            let nextRouteData = try decoder.decode(routeResponse.self, from: data!)
                            self.nextRouteInfo2 = nextRouteData.route!
                            
                            DispatchQueue.main.async {
                                if (self.nextRouteInfo2!.routeType == 0 || self.nextRouteInfo2!.routeType == 3){
                                    let str: String = self.nextRouteInfo1!.GtfsId!
                                    let start = str.index(str.startIndex, offsetBy: 2)
                                    cell.departure2Route.text = String(str[start...])
                                } else {
                                    cell.departure2Route.text = self.nextRouteInfo2!.routeNumber
                                }
                                cell.departure2Route.textColor = UIColor.white
                                cell.departure2Route.backgroundColor = self.changeColorForRouteBackground(routeType: (self.nextRouteInfo2?.routeType!)!)
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
        //        if indexPath.section == 1 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedStopsCell", for: indexPath) as! savedStopsTableViewCell
        let savedStop = stopFetchedResultsController.object(at: indexPath)
        cell.stopNameLabel.text = savedStop.stopName
        cell.stopSuburbLabel.text = savedStop.stopSuburb
        return cell
        //        }
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "favorRouteCell", for: indexPath) as! savedRoutesTableViewCell
        //        let savedRoute = routeFetchedResultsController.object(at: indexPath)
        //        cell.routeNumber.text = savedRoute.routeNumber
        //        cell.routeInfo.text = savedRoute.routeName
        //        cell.routeSign = savedRoute.routeType
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName: String
        switch section {
        case 0:
            sectionName = NSLocalizedString("Nearby Stops:", comment: "Nearby stops")
        case 1:
            sectionName = NSLocalizedString("My Favorite Stops:", comment: "Favorite stops:")
        case 2:
            sectionName = NSLocalizedString("My favorite Routes:", comment: "favorite Route")
        default:
            sectionName = ""
        }
        return sectionName
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "showNearByStop") {
            let page2:StopPageTableViewController = segue.destination as! StopPageTableViewController
            page2.stopURL = lookupStops(stopId: (nearbyStops[tableView.indexPathForSelectedRow!.row]).stopId! , routeType: (nearbyStops[tableView.indexPathForSelectedRow!.row]).routeType! )
            page2.routeType = (nearbyStops[tableView.indexPathForSelectedRow!.row]).routeType!
            page2.stopId = (nearbyStops[tableView.indexPathForSelectedRow!.row]).stopId!
            page2.stopSuburb = (nearbyStops[tableView.indexPathForSelectedRow!.row]).stopSuburb!
        }
        if segue.identifier == "showSavedStop" {
            if let page2 = segue.destination as? StopPageTableViewController, let _ = sender as? savedRouteTableViewCell {
                page2.stopURL = lookupStops(stopId: (nearbyStops[tableView.indexPathForSelectedRow!.row]).stopId! , routeType: (nearbyStops[tableView.indexPathForSelectedRow!.row]).routeType! )
                page2.routeType = (nearbyStops[tableView.indexPathForSelectedRow!.row]).routeType!
                page2.stopId = (nearbyStops[tableView.indexPathForSelectedRow!.row]).stopId!
                page2.stopSuburb = (nearbyStops[tableView.indexPathForSelectedRow!.row]).stopSuburb!
                page2.managedContext = coreDataStack.managedContext
            }
        }
        if segue.identifier == "busRouteSegue"{
            
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
    
    //    Construct PTV lookup address
    fileprivate func extractedFunc(_ request: String) -> String {
        let signature: String = request.hmac(algorithm: CryptoAlgorithm.SHA1, key: hardcodedDevKey)
        let requestAddress: String = hardcodedURL+request+"&signature="+signature
        
        print(requestAddress)
        return requestAddress
    }
    
    func nearByStops(latitude: Double, longtitude: Double) -> String{
        let request: String = "/v3/stops/location/\(latitude),\(longtitude)?max_results=3&max_distance=1500&devid="+hardcodedDevID
        return extractedFunc(request)
    }
    
    func nextDepartureByStop(routeType: Int, stopId: Int) -> String{
        let request: String = "/v3/departures/route_type/\(routeType)/stop/\(stopId)?include_cancelled=true&max_results=3&devid="+hardcodedDevID
        return extractedFunc(request)
    }
    
    func lookupRoutes(routeId: Int) -> String{
        let request: String = "/v3/routes/\(routeId)?devid="+hardcodedDevID
        return extractedFunc(request)
    }
    
    func lookupStops(stopId: Int, routeType: Int) -> String{
        let request: String = "/v3/stops/\(stopId)/route_type/\(routeType)?devid="+hardcodedDevID
        return extractedFunc(request)
    }
    
    func iso8601DateConvert(iso8601Date: String, withTime: Bool?) -> String{
        if iso8601Date == "nil"{
            return ""
        }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let date = formatter.date(from: iso8601Date)
        
        var secondsFromUTC: Int{ return TimeZone.current.secondsFromGMT()}
        
        let mydateformat = DateFormatter()
        if withTime == false {
            mydateformat.dateFormat = "EEE dd MMM yyyy"
        }else{
            mydateformat.dateFormat = "EEE dd MMM yyyy  hh:mm a"
        }
        return mydateformat.string(from: date!)
    }
    func iso8601DateConvert(iso8601Date: String, withDate: Bool?) -> String{
        if iso8601Date == "nil"{
            return ""
        }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let date = formatter.date(from: iso8601Date)
        
        var secondsFromUTC: Int{ return TimeZone.current.secondsFromGMT()}
        
        let mydateformat = DateFormatter()
        if withDate == false {
            mydateformat.dateFormat = "hh:mm a"
        }else{
            mydateformat.dateFormat = "EEE dd MMM yyyy  hh:mm a"
        }
        return mydateformat.string(from: date!)
    }
    
    func iso8601toDate(iso8601Date: String) -> Date {
        if iso8601Date == "nil"{
            fatalError()
        }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let date:Date = formatter.date(from: iso8601Date)!
        return date
    }
    
    func timeRemainCalculate(date: Date) -> String{
        let differences = Calendar.current.dateComponents([.minute], from: NSDate.init(timeIntervalSinceNow: 0) as Date, to: date)
        let minutes = differences.minute ?? 0
        
        if minutes == 1{
            return "1 min"
        }
        if minutes <= 90{
            return "\(minutes) mins"
        }
        if minutes >= 1440{
            return "≥ 1 day"
        } else if minutes > 90 {
            let mydateformat = DateFormatter()
            mydateformat.dateFormat = "hh:mm a"
            return mydateformat.string(from: date)
        }
        return ""
    }
    
    func changeColorForRouteBackground(routeType: Int) -> UIColor{
        switch routeType {  //API PDF Page43
        case 0: //Train (metropolitan)
            return UIColor.init(red: 0.066, green: 0.455, blue: 0.796, alpha: 1)
        case 1: //Tram
            return UIColor.init(red: 0.4784, green: 0.7372, blue: 0.1882, alpha: 1)
        case 2: //Bus (metropolitan, regional and Skybus, but not V/Line)
            return UIColor.init(red: 0.993, green: 0.5098, blue: 0.1372, alpha: 1)
        case 3: //  V/Line train and coach
            return UIColor.init(red: 0.5568, green: 0.1333, blue: 0.5765, alpha: 1)
        case 4: //Night Bus (which replaced NightRider)
            return UIColor.init(red: 0.993, green: 0.5098, blue: 0.1372, alpha: 1)
        default:
            return UIColor.white
        }
    }
}
