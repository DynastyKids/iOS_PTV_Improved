//
//  StopPageTableViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 18/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit

class StopPageTableViewController: UITableViewController {
    
    var stopURL: String = ""
    var stopId: Int = 0
    var routeType: Int = 0
    var stopName: String = ""
    
    var departureData: [departure] = []
    var routeInfo: [RouteWithStatus] = []
    
    var routesName: [String] = []
    var routesDest: [String] = []
    
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
                //Departure Data fetch Finished.
                print("Verify data fetch is finished.")
                
//                //Fetching Stopping Infos
//                if self.departureData.count < 200{
//                    self.fetchingLimit = self.departureData.count
//                }
//                for eachDeparture in self.departureData{
//                    // Looking up the route Id, match to route name
//                    _ = URLSession.shared.dataTask(with: URL(string: self.showRoute(routeId: eachDeparture.routesId!))!){(data, response, error) in
//                        if error != nil{
//                            print("Route info fetch failed for \(eachDeparture.routesId!)")
//                        }
//                        do{
//                            let showRoute = try JSONDecoder().decode(routeResponse.self, from: data!)
//                            print("CurrentLoop:\(self.currentLoopCount), Route Id:\(String(describing: eachDeparture.routesId)) Route Name:\(String(describing: showRoute.route?.routeNumber))")
//                            self.routesName.append((showRoute.route?.routeNumber)!)
//                            if (self.fetchingLimit == self.routesName.count && self.routesDest.count == self.routesName.count){
//                                print("Ready to reload data")
//                                DispatchQueue.main.async {  // When all data has been loaded, then reload the whole table
//                                    print("Fetch Requested from RoutesDest")
//                                    self.tableView.reloadData()
//                                }
//                            }
//
//                        } catch{
//                            print("Error on looking up route")
//                        }
//                        }.resume()
//
//
//                    // Looking up direction Id, match it to Destination
//                    _ = URLSession.shared.dataTask(with: URL(string: self.showAllDirections(routeId: eachDeparture.routesId!))!){(data, response, error) in
//                        if error != nil {
//                            print("Route direction fetch error for \(eachDeparture.routesId!)")
//                            return
//                        }
//                        do{
//                            let showDirection = try JSONDecoder().decode(directionsResponse.self, from: data!)
//                            print("CurrentLoop:\(self.currentLoopCount), Route Id:\(String(describing: eachDeparture.routesId)) to \(String(describing: showDirection.directions![0].directionName))")
//                            self.routesDest.append(showDirection.directions![0].directionName!)
//                            if (self.fetchingLimit == self.routesDest.count && self.routesDest.count == self.routesName.count){
//                                print("Ready to reload data")
                                DispatchQueue.main.async {  // When all data has been loaded, then reload the whole table
//                                    print("Fetch Requested from RoutesDest")
                                    self.tableView.reloadData()
                                }
//                            }
//                        }catch{
//                            print("Fetch error for route:\(String(describing: eachDeparture.routesId))")
//                        }
//                        }.resume()
//                    // End of lookingup direction ID
//
//                    if self.currentLoopCount >= 200{
//                        print(self.tableView(self.tableView, numberOfRowsInSection: 0))
//                        break
//                    }
//                    self.currentLoopCount += 1
//                }
            } catch {
                print(error)
            }
            }.resume()
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
//        cell.routeSignLabel.text = routesName[indexPath.row]
        cell.routeToLabel.text = " to "
        _ = URLSession.shared.dataTask(with: URL(string: self.showRoute(routeId: departureData[indexPath.row].routesId!))!){(data, response, error) in
            if error != nil{
                print(error)
                return
            }
            do{
                let showRoute = try JSONDecoder().decode(routeResponse.self, from: data!)
                print("\(indexPath.row), Route:\(showRoute.route?.routeNumber)")
                cell.routeSignLabel.text = showRoute.route?.routeNumber
                cell.routeSignLabel.textColor = UIColor.white
            } catch{
                print("Error on looking up route")
            }
            }.resume()
        _ = URLSession.shared.dataTask(with: URL(string: self.showAllDirections(routeId: departureData[indexPath.row].routesId!))!){(data, response, error) in
            if error != nil {
                print(error)
                return
            }
            do{
                let showDirection = try JSONDecoder().decode(directionsResponse.self, from: data!)
                print("\(indexPath.row), Destination:\(showDirection.directions![0].directionName!)")
                cell.routeDestinationLabel.text = showDirection.directions![0].directionName!
            }catch{
                print(error)
            }
            }.resume()
        
        
        cell.routeSignLabel.backgroundColor = getStopTypeColour(routeType: routeType)
//        cell.routeDestinationLabel.text = routesDest[indexPath.row]
        cell.routeDetailslabel.text = "Temporary Empty"
        
        cell.routeDueTimeLabel.text = iso8601DateConvert(iso8601Date: departureData[indexPath.row].estimatedDepartureUTC ?? departureData[indexPath.row].scheduledDepartureUTC!, withDate: false)
        if departureData[indexPath.row].estimatedDepartureUTC == nil {
            cell.routeStatusLabel.text = "Scheduled"
            cell.routeStatusLabel.textColor = UIColor.black
        }else {
            cell.routeStatusLabel.text = "Testing Status"
        }
        return cell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func getStopTypeColour(routeType: Int) -> UIColor {
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
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
}
