//
//  StopsViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 3/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit

class StopsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var nextServiceTableView: UITableView!
    @IBOutlet weak var disruptionButton: UIButton!
    @IBOutlet weak var runningMapButton: UIButton!
    
    @IBOutlet weak var showAllTransport: UIBarButtonItem!
    @IBOutlet weak var busOnlyButton: UIBarButtonItem!
    @IBOutlet weak var tramOnlyButton: UIBarButtonItem!
    @IBOutlet weak var trainOnlyButton: UIBarButtonItem!
    @IBOutlet weak var vlineOnlyButton: UIBarButtonItem!
    
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

    fileprivate func routeIdLookUp(_ eachDeparture: departure) {
        // Looking up the route Id, match to route name
        _ = URLSession.shared.dataTask(with: URL(string: self.showRoute(routeId: eachDeparture.routesId!))!){(data, response, error) in
            if error != nil{
                print("Route info fetch failed for \(eachDeparture.routesId!)")
            }
            do{
                let showRoute = try JSONDecoder().decode(routeResponse.self, from: data!)
                print("Route Id:\(String(describing: eachDeparture.routesId)) Route Name:\(String(describing: showRoute.route?.routeNumber))")
                self.routesName.append((showRoute.route?.routeNumber)!)
                if (self.fetchingLimit == self.routesDest.count && self.routesDest.count == self.routesName.count){
                    print("Ready to reload data")
                    DispatchQueue.main.async {  // When all data has been loaded, then reload the whole table
                        print("Fetch Requested from RoutesDest")
                        self.nextServiceTableView.reloadData()
                    }
                }
                
            } catch{
                print("Error on looking up route")
            }
            }.resume()
    }
    
    fileprivate func destinationLookUp(_ eachDeparture: departure) {
        // Looking up direction Id, match it to Destination
        _ = URLSession.shared.dataTask(with: URL(string: self.showAllDirections(routeId: eachDeparture.routesId!))!){(data, response, error) in
            if error != nil {
                print("Route direction fetch error for \(eachDeparture.routesId!)")
                print(error)
                return
            }
            do{
                let showDirection = try JSONDecoder().decode(directionsResponse.self, from: data!)
                print("Route Id:\(String(describing: eachDeparture.routesId)) to \(String(describing: showDirection.directions![0].directionName))")
                self.routesDest.append(showDirection.directions![0].directionName!)
                if (self.fetchingLimit == self.routesDest.count && self.routesDest.count == self.routesName.count){
                    print("Ready to reload data")
                    DispatchQueue.main.async {  // When all data has been loaded, then reload the whole table
                        print("Fetch Requested from RoutesDest")
                        self.nextServiceTableView.reloadData()
                    }
                }
            }catch{
                print("Fetch error for route:\(String(describing: eachDeparture.routesId))")
            }
            }.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch routeType {  // Set the background color theme as transport types
        // Transport type category on API PDF Page43
        case 0: //Train (metropolitan)
            view.backgroundColor = UIColor.init(red: 0.066, green: 0.455, blue: 0.796, alpha: 1)
            break
        case 1: //Tram
            view.backgroundColor = UIColor.init(red: 0.4784, green: 0.7372, blue: 0.1882, alpha: 1)
            break
        case 2: //Bus (metropolitan, regional and Skybus, but not V/Line)
            view.backgroundColor = UIColor.init(red: 0.993, green: 0.5098, blue: 0.1372, alpha: 1)
            break
        case 3: //  V/Line train and coach
            view.backgroundColor = UIColor.init(red: 0.5568, green: 0.1333, blue: 0.5765, alpha: 1)
            break
        case 4: //Night Bus (which replaced NightRider)
            view.backgroundColor = UIColor.init(red: 0.993, green: 0.5098, blue: 0.1372, alpha: 1)
            break
        default:
            view.backgroundColor = UIColor.white
        }

        nextServiceTableView.delegate = self
        nextServiceTableView.dataSource = self  
        
        // Do any additional setup after loading the view.
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
                
                //Fetching Stopping Infos
                if self.departureData.count < 200{
                    self.fetchingLimit = self.departureData.count
                }
                for eachDeparture in self.departureData{
                    self.routeIdLookUp(eachDeparture)
                    
                    self.destinationLookUp(eachDeparture)
                    
//                     End of lookingup direction ID
                    if self.currentLoopCount >= 200{
                        print(self.tableView(self.nextServiceTableView, numberOfRowsInSection: 0))

                        break
                    }
                    self.currentLoopCount += 1
                }
            } catch {
                print(error)
            }
        }.resume()
        
        //Get the stop name
        _ = URLSession.shared.dataTask(with: URL(string: lookupStops(stopId: stopId, routeType: routeType))!) { (data, response, error) in
            if let error = error {
                print("Download failed: \(String(describing: error))")
                return
            }
            do {    // Data recieved.  Decode it from JSON.
                let stopDetail = try JSONDecoder().decode(stopResposeById.self, from: data!)
                DispatchQueue.main.async {
                    self.stopNameLabel.text = stopDetail.stop?.stopName
                }
            } catch {
                print("Error:"+error.localizedDescription)
            }
            }.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("\(departureData.count), \(fetchingLimit)")
        if departureData.count >= fetchingLimit{
            return fetchingLimit                  // Avoiding fetching too much data to crush
        }
        return departureData.count      // Showing all departures data if total data is less than 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nextService", for: indexPath) as! upcomingServiceTableViewCell
        let departuredata = departureData[indexPath.row]
        cell.typeLabel.text = routesName[indexPath.row]
        cell.typeLabel.backgroundColor = view.backgroundColor
        cell.serviceDestLabel.text = routesDest[indexPath.row]
        cell.detailsLabel.text = ""
//        if departuredata.flags == "DOO"{
//            cell.detailsLabel.text = "Set Down Only"
//        } else if departuredata.flags == "RR"{
//            cell.detailsLabel.text = "Reservations Required on this service"
//        } else if departuredata.flags == "PUO"{
//            cell.detailsLabel.text = "Pick-up Only"
//        } else if departuredata.flags == "SS"{
//            cell.detailsLabel.text = "Special Serivce - only running on School days"
//        } else if departuredata.flags == "GC"{
//            cell.detailsLabel.text = "Guaranteed Connection"
//        } else {
//            cell.detailsLabel.text = ""
//        }
        cell.dueTimeLabel.text = iso8601DateConvert(iso8601Date: departuredata.estimatedDepartureUTC ?? departuredata.scheduledDepartureUTC!, withDate: false)
//        cell.statusLabel.text = ""
        return cell
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
