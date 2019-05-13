//
//  HomeViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 3/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit
import CommonCrypto
import Foundation
import CoreData
import CoreLocation

// Data struct has been moved to /PTVdataStruct.swift

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var nslock = NSLock()
    var currentLocation:CLLocation!
    
    var stopFetchedResultsController: NSFetchedResultsController<FavStop>!
    var routeFetchedResultsController: NSFetchedResultsController<FavRoute>!

    var nearbyStops: [stopGeosearch] = []
    var departureSequence: [departure] = []         // Departure data: data to be present
    var departureSequenceTemp: [departure] = []     // Departure data:Store all excesss data
    var nextRouteInfo: [RouteWithStatus] = []       // Route data: data to be present
    var nextrouteInfoTemp: [RouteWithStatus] = []   // Route data: store all excess data fetched

    var nextRouteCount: Int = 0
    var filteredRoutes: [FavRoute] = []
    var filteredStops: [FavStop] = []
    
    var lookupRouteName: Bool = true
    
    var latitude: Double = 0.0
    var longtitude: Double = 0.0
    
    @IBOutlet weak var stopsTableView: UITableView!
    
    let hardcodedURL:String = "http://timetableapi.ptv.vic.gov.au"
    let hardcodedDevID:String = "3001122"
    let hardcodedDevKey:String = "3c74a383-c69a-4e8d-b2f8-2e4c598b50b2"
    
    // Testing path
    func createResultString(Pattern:String)->String{
        let hardcodedURL:String = "http://timetableapi.ptv.vic.gov.au"
        let hardcodedDevID:String = "3001122"
        let hardcodedDevKey:String = "3c74a383-c69a-4e8d-b2f8-2e4c598b50b2"
        let searchPattern:String = "/v3/search/"+Pattern+"?devid="+hardcodedDevID;
        let signature:String = searchPattern.hmac(algorithm: CryptoAlgorithm.SHA1, key: hardcodedDevKey);
        
        let resultString:String = hardcodedURL+searchPattern+"&signature="+signature;
        
        return resultString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopsTableView.delegate = self
        stopsTableView.dataSource = self

        // Do any additional setup after loading the view.
        
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
                self.nearbyStops = (nearbyData.stops)!
                
                print(self.nearbyStops.count)   // Fetching time for next depart
                
                if self.nearbyStops.count == 0{
                    DispatchQueue.main.async {
                        self.navigationItem.title = "Oh My Transport"
                        self.stopsTableView.reloadData()
                    }
                }else if self.nearbyStops.count == 1{
                    let nextDepartUrl = URL(string: self.nextDepartureByStop(routeType: self.nearbyStops[0].routeType!, stopId: self.nearbyStops[0].stopId!))
                    self.getStopInfoReload(nextDepartUrl, reloadTableView: true)
                }else if self.nearbyStops.count > 1 {
                    let nextDepartUrl0 = URL(string: self.nextDepartureByStop(routeType: self.nearbyStops[0].routeType!, stopId: self.nearbyStops[0].stopId!))
                    let nextDepartUrl1 = URL(string: self.nextDepartureByStop(routeType: self.nearbyStops[1].routeType!, stopId: self.nearbyStops[1].stopId!))
                    self.getStopInfoReload(nextDepartUrl0, reloadTableView: false)
                    self.getStopInfoReload(nextDepartUrl1, reloadTableView: true)
                }
            }
            catch{
                print("Error:\(error)")
            }
        }.resume()
        
        print("Fetch Finished")
        
        // End of Allocate near by 2 stops
        
        // Allocate saved stops from CoreData
        
        // Allocate Saved routes from CoreData
    }
    fileprivate func getStopInfoReload(_ nextDepartUrl: URL?, reloadTableView: Bool!) {
        _ = URLSession.shared.dataTask(with: nextDepartUrl!){ (data, response, error) in
            if error != nil {
                print("Next departure fetch failed:\(error)")
                return
            }
            do{
                let nextDepartureData = try JSONDecoder().decode(departuresResponse.self, from: data!)
                self.departureSequenceTemp = nextDepartureData.departures
                var cycle = 0;
                for nextdeparts in self.departureSequenceTemp{
                    self.departureSequence.append(nextdeparts);
                    do{
                        let url = URL(string: self.lookupRoutes(routeId: nextdeparts.routesId!))
                        print("\nFrom:\(nextdeparts.routesId) + Content:\(url)");
                        let nextRouteTask = URLSession.shared.dataTask(with: url!){ (data, response, error) in
                            if error != nil {
                                print("Stop information fetch failed:\(error)")
                                return
                            }
                            do{
                                let decoder = JSONDecoder()
                                let nextRouteData = try decoder.decode(RouteResponse.self, from: data!)
                                self.nextRouteInfo.append(nextRouteData.route!)
                                
                                if reloadTableView == true && self.nextRouteInfo.count == self.departureSequence.count{ // Matching 3/6 routes info, avoid exit loop early
                                    DispatchQueue.main.async {
                                        self.navigationItem.title = "Oh My Transport"
                                        self.stopsTableView.reloadData()
                                    }
                                }
                            }
                            catch{
                                print("Error:\(error)")
                            }
                        }.resume()
                    } catch {
                        print(error)
                    }
                    
                    if cycle == 2{
                        break
                    }
                    cycle += 1
                }
            }
            catch{
                print("Error:\(error)")
            }
            }.resume()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return nearbyStops.count    //Show Nearby stops only
        } else if section == 1 {
            return filteredStops.count  // Show all saved stops
        } else {
            return filteredRoutes.count // Show all saved routes
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "nearbyStopsCell", for: indexPath) as! nearbyStopTableViewCell
            let nearbystops = nearbyStops[indexPath.row];
            cell.stopNameLabel.text = nearbystops.stopName
            if nearbystops.routeType == 4{
                cell.stopNameLabel.text = "\(nearbystops.stopName!) (Night Bus)"
            }
            cell.stopSuburbLabel.text = nearbystops.stopSuburb
            cell.nearbyLabel.text = "Near by: \(Int(nearbystops.stopDistance!))m"
            
            cell.dep1timeLabel.text = iso8601DateConvert(iso8601Date: (departureSequence[indexPath.row*3].estimatedDepartureUTC) ?? ((self.departureSequence[indexPath.row*3].scheduledDepartureUTC ?? nil)!), withDate: false)
            cell.dep2timeLabel.text = iso8601DateConvert(iso8601Date: (departureSequence[(indexPath.row*3)+1].estimatedDepartureUTC) ?? ((self.departureSequence[(indexPath.row*3)+1].scheduledDepartureUTC ?? nil)!), withDate: false)
            cell.dep3timeLabel.text = iso8601DateConvert(iso8601Date: (departureSequence[(indexPath.row*3)+2].estimatedDepartureUTC) ?? ((self.departureSequence[(indexPath.row*3)+2].scheduledDepartureUTC ?? nil)!), withDate: false)
                
            cell.departure1Label.text = self.nextRouteInfo[indexPath.row*3].routeNumber
            cell.departure1Label.textColor = UIColor.white
            cell.departure1Label.backgroundColor = changeColorForRouteBackground(routeType: self.nextRouteInfo[indexPath.row*3].routeType!)
            
            cell.departure2Label.text = self.nextRouteInfo[(indexPath.row*3)+1].routeNumber
            cell.departure2Label.textColor = UIColor.white
            cell.departure2Label.backgroundColor = changeColorForRouteBackground(routeType: self.nextRouteInfo[(indexPath.row*3)+1].routeType!)
            
            cell.departure3Label.text = self.nextRouteInfo[(indexPath.row*3)+2].routeNumber
            cell.departure3Label.textColor = UIColor.white
            cell.departure3Label.backgroundColor = changeColorForRouteBackground(routeType: self.nextRouteInfo[(indexPath.row*3)+2].routeType!)
            
            return cell
        }
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "savedStopsCell", for: indexPath) as! favoriteStopTableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "favorRouteCell", for: indexPath) as! favoriteRouteTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showNearByStop" || segue.identifier == "showSavedStop"{
            let page2:StopsViewController = segue.destination as! StopsViewController
            page2.nextDepartsURL = nextDepartureByStop(routeType: (nearbyStops[stopsTableView.indexPathForSelectedRow!.row]).routeType! , stopId: (nearbyStops[stopsTableView.indexPathForSelectedRow!.row]).stopId! )
            page2.stopURL = lookupStops(stopId: (nearbyStops[stopsTableView.indexPathForSelectedRow!.row]).stopId! , routeType: (nearbyStops[stopsTableView.indexPathForSelectedRow!.row]).routeType! )
            page2.routeType = (nearbyStops[stopsTableView.indexPathForSelectedRow!.row]).routeType!
        }
        if segue.identifier == "busRouteSegue"{
            
        }
    }
    // MARK: - Search Function
//    func updateSearchResults(for searchController: UISearchController) {
//        if taskFetchedResultsController.fetchedObjects?.isEmpty == false{
//            searchAllTasks = taskFetchedResultsController.fetchedObjects!
//        }
//        if let searchText = searchController.searchBar.text?.lowercased(), searchText.count > 0{
//            filteredTasks = searchAllTasks.filter({(favorite: Favorite) -> Bool in
//                return (favorite.title?.lowercased().contains(searchText))!
//            })
//        }else{
//            filteredTasks = searchAllTasks;
//        }
//        tableView.reloadData()
//    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations location: [CLLocation]) {  // Get User location
        nslock.lock()
        currentLocation = location.last //用最后一个经纬度数组定位
        latitude = currentLocation.coordinate.latitude
        longtitude = currentLocation.coordinate.longitude
        locationManager.stopUpdatingLocation()
        nslock.unlock()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while get user location:\(error)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning() // Dispose of any resources that can be recreated.
    }
    
//    Construct PTV lookup address
    fileprivate func extractedFunc(_ request: String) -> String {
        let signature: String = request.hmac(algorithm: CryptoAlgorithm.SHA1, key: hardcodedDevKey)
        let requestAddress: String = hardcodedURL+request+"&signature="+signature
        
        print(requestAddress)
        return requestAddress
    }
    
    func nearByStops(latitude: Double, longtitude: Double) -> String{
        let request: String = "/v3/stops/location/\(latitude),\(longtitude)?max_results=2&max_distance=1000&devid="+hardcodedDevID
        return extractedFunc(request)
    }
    
    func nextDepartureByStop(routeType: Int, stopId: Int) -> String{
        let request: String = "/v3/departures/route_type/\(routeType)/stop/\(stopId)?max_results=3&devid="+hardcodedDevID
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
        if minutes < 120{
            return "\(minutes) mins"
        }
        if minutes >= 1440{
            return "≥ 1 day"
        } else if minutes >= 120 {
            return "≥ 2 hours"
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

enum CryptoAlgorithm {
    case MD5, SHA1
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:      result = kCCHmacAlgMD5
        case .SHA1:     result = kCCHmacAlgSHA1
        }
        return CCHmacAlgorithm(result)
    }
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:      result = CC_MD5_DIGEST_LENGTH
        case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
        }
        return Int(result)
    }
}


//// Database Controller Delegate - all-in-one
//extension TaskListTableViewController: NSFetchedResultsControllerDelegate{
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            if let indexPath = newIndexPath{
//                tableView.insertRows(at: [indexPath], with: .automatic)
//            }
//        case .delete:
//            if let indexPath = indexPath{
//                tableView.deleteRows(at: [indexPath], with: .automatic)
//            }
//        case .update:
//            if let indexPath = indexPath, let _ = tableView.cellForRow(at: indexPath){
//                _ = taskFetchedResultsController.object(at: indexPath)
//            }
//        default:
//            break
//        }
//    }
//}
