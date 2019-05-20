//
//  StopPageTableViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 18/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

// Note: Re Construct on Stop Page, replace previsouly build by UIViewController

import UIKit
import CoreData

class StopPageTableViewController: UITableViewController {
    
    // MARK: - CD Properties
    var managedContext: NSManagedObjectContext!
    var stops: FavStop?
    
    var stopURL: String = ""
    var stopId: Int = 0
    var routeType: Int = 0
    var stopName: String = ""
    var stopSuburb: String = ""
    
    var departureData: [departure] = []
    var routeInfo: [RouteWithStatus] = []

    let hardcodedURL:String = "https://timetableapi.ptv.vic.gov.au"
    let hardcodedDevID:String = "3001122"
    let hardcodedDevKey:String = "3c74a383-c69a-4e8d-b2f8-2e4c598b50b2"
    
    var currentLoopCount = 0
    var fetchingLimit = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get the stop name
        _ = URLSession.shared.dataTask(with: URL(string: lookupStops(stopId: stopId, routeType: routeType))!) { (data, response, error) in
            if let error = error {
                print("Download failed: \(String(describing: error))")
                return
            }
            do {    // Data recieved.  Decode it from JSON.
                let stopDetail = try JSONDecoder().decode(stopResposeById.self, from: data!)
                DispatchQueue.main.async {
                    self.stopName = (stopDetail.stop?.stopName)!
                }
            } catch {
                print("Error:"+error.localizedDescription)
            }
            }.resume()
        

        print("Next Depart URL:\(nextDepartureURL(routeType: routeType, stopId: stopId))")
        
        _ = URLSession.shared.dataTask(with: URL(string: nextDepartureURL(routeType: routeType, stopId: stopId))!) { (data, response, error) in
            if let error = error {
                print("Download failed: \(String(describing: error))")
                return
            }
            do {
                // Data recieved.  Decode it from JSON.
                let showDeparture = try JSONDecoder().decode(departuresResponse.self, from: data!)
                self.departureData = showDeparture.departures
                DispatchQueue.main.async {
                    self.tableView.reloadData() // Details data will be loaded when loading cell
                }
            } catch {
                print(error)
            }
            }.resume()
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        let stop = FavStop(context: managedContext)
        stop.routeType = Int32(routeType)
        stop.stopId = Int32(stopId)
        stop.stopName = stopName
        stop.stopSuburb = stopSuburb

        do {
            try managedContext?.save()
            let _ = navigationController?.popViewController(animated: true)
        } catch {
            print("Error to save stop")
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return 1
        } else{
            return departureData.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell0 = tableView.dequeueReusableCell(withIdentifier: "stopInfo", for: indexPath) as! stopInfoTableViewCell
            cell0.stopNameLabel.text = stopName
            cell0.disruptionButton.setTitle("No Disruptions in effect", for: UIControl.State.normal)
            cell0.backgroundColor = getStopTypeColour(routeType: routeType)
            return cell0
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "nextService", for: indexPath) as! nextServiceTableViewCell
        cell.routeToLabel.text = " to "
        _ = URLSession.shared.dataTask(with: URL(string: self.showRoute(routeId: departureData[indexPath.row].routesId!))!){(data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            do{
                let showRoute = try JSONDecoder().decode(routeResponse.self, from: data!)
                DispatchQueue.main.async {
                    if(showRoute.route?.routeType == 0 || showRoute.route?.routeType == 3){
                        let str: String = showRoute.route!.GtfsId!
                        let start = str.index(str.startIndex, offsetBy: 2)
                        cell.routeSignLabel.text = String(str[start...])      // Metro and vline will using its gtfsid to ident which line's service is running
                    } else {
                        cell.routeSignLabel.text = showRoute.route?.routeNumber // All other service using existing route numbers
                    }
                    cell.routeSignLabel.textColor = UIColor.white
                }
            } catch{
                print("Error on looking up route")
            }
            }.resume()
        _ = URLSession.shared.dataTask(with: URL(string: self.showAllDirections(routeId: departureData[indexPath.row].routesId!))!){(data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            do{
                let showDirection = try JSONDecoder().decode(directionsResponse.self, from: data!)
                print("\(indexPath.row), Destination:\(showDirection.directions![0].directionName!)")
                DispatchQueue.main.async {
                    cell.routeDestinationLabel.text = showDirection.directions![0].directionName!
                }
            }catch{
                print(error)
            }
            }.resume()
        
        cell.routeSignLabel.backgroundColor = getStopTypeColour(routeType: routeType)
//        cell.routeDestinationLabel.text = routesDest[indexPath.row]
        cell.routeDetailslabel.text = "Temporary Empty"
        
        cell.routeDueTimeLabel.text = iso8601toRemainTime(iso8601Date: departureData[indexPath.row].estimatedDepartureUTC ?? departureData[indexPath.row].scheduledDepartureUTC!)
        if departureData[indexPath.row].estimatedDepartureUTC == nil {
            cell.routeStatusLabel.text = "Scheduled"
            cell.routeStatusLabel.textColor = UIColor.gray
        }else {
            let mintes = iso8601toStatus(iso8601DateSchedule: departureData[indexPath.row].scheduledDepartureUTC!, iso8601DateActual: departureData[indexPath.row].estimatedDepartureUTC!)
            if mintes > 1 {
                cell.routeStatusLabel.text = "Late \(mintes) mins"
                cell.routeStatusLabel.textColor = UIColor.red
            } else if mintes == 1{
                cell.routeStatusLabel.text = "Late 1 min"
                cell.routeStatusLabel.textColor = UIColor.orange
            } else if mintes == 0 {
                cell.routeStatusLabel.text = "On Time"
                cell.routeStatusLabel.textColor = UIColor.green
            } else if mintes == -1{
                cell.routeStatusLabel.text = "Early 1 min"
                cell.routeStatusLabel.textColor = UIColor.green
            } else if mintes < -1 {
                let min = mintes * -1
                cell.routeStatusLabel.text = "Early \(min) mins"
                cell.routeStatusLabel.textColor = UIColor.brown
            }
        }
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*
     // MARK: - Self defined reuseable functions
     // Different colors for difference transport types
     */
    func getStopTypeColour(routeType: Int) -> UIColor {
        // Changeing color after stop info loaded, set the background color theme as transport types
        switch routeType {  // Transport type category on API PDF Page43
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
    
    // Extracted functions for genreate URL on different pages
    fileprivate func generateRequestAddress(_ request: String) -> String {
        let signature: String = request.hmac(algorithm: CryptoAlgorithm.SHA1, key: hardcodedDevKey)
        let requestAddress: String = hardcodedURL+request+"&signature="+signature
        
        return requestAddress
    }
    
    func showRoute(routeId: Int) -> String{
        let request: String = "/v3/routes/\(routeId)?devid="+hardcodedDevID
        return generateRequestAddress(request)
    }
    
    func showAllDirections(routeId: Int) -> String{
        let request: String = "/v3/directions/route/\(routeId)?devid="+hardcodedDevID
        return generateRequestAddress(request)
    }
    
    func nextDepartureURL(routeType: Int, stopId: Int) -> String{
        let request: String = "/v3/departures/route_type/\(routeType)/stop/\(stopId)?max_results=200&devid="+hardcodedDevID
        return generateRequestAddress(request)
    }
    
    func lookupStops(stopId: Int, routeType: Int) -> String{
        let request: String = "/v3/stops/\(stopId)/route_type/\(routeType)?devid="+hardcodedDevID
        return generateRequestAddress(request)
    }
    
    // Time convert function
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
    
    func iso8601toRemainTime(iso8601Date: String) -> String {
        if iso8601Date == "nil"{
            fatalError()
        }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let date:Date = formatter.date(from: iso8601Date)!
        let differences = Calendar.current.dateComponents([.minute], from: NSDate.init(timeIntervalSinceNow: 0) as Date, to: date)
        let minutes = differences.minute ?? 0
        
        if minutes < 0{
            let mydateformat = DateFormatter()
            mydateformat.dateFormat = "hh:mm a"
            return mydateformat.string(from: date)
        }
        if minutes == 0{
            return "Now"
        }
        if minutes == 1{
            return "1 min"
        }
        if minutes <= 90{
            return "\(minutes) mins"
        }
        if minutes > 2880{
            let day = minutes / 1440
            return "\(day) days"
        }
        if minutes > 1440{
            return "1 day"
        } else if minutes > 90 {
            let mydateformat = DateFormatter()
            mydateformat.dateFormat = "hh:mm a"
            return mydateformat.string(from: date)
        }
        return ""
    }
    
    func iso8601toStatus(iso8601DateSchedule: String, iso8601DateActual: String) -> Int {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let scheduleDate:Date = formatter.date(from: iso8601DateSchedule)!
        let actualDate:Date = formatter.date(from: iso8601DateActual)!
        let differences = Calendar.current.dateComponents([.minute], from: scheduleDate, to: actualDate)
        let minutes = differences.minute ?? 0
        
        return minutes
    }
}
