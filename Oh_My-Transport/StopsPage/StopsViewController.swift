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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch routeType {  //API PDF Page43
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
        
        let getTableData = URLSession.shared.dataTask(with: URL(string: nextDepartureURL(routeType: routeType, stopId: stopId))!) { (data, response, error) in
            if let error = error {
                print("Download failed: \(String(describing: error))")
                return
            }
            do {
                // Data recieved.  Decode it from JSON.
                let showDeparture = try JSONDecoder().decode(departuresResponse.self, from: data!)
                self.departureData = showDeparture.departures

                // Get Route name
                for eachDeparture in self.departureData{
                    _ = URLSession.shared.dataTask(with: URL(string: self.nextServiceURL(routeId: eachDeparture.routesId!))!){ (data,response,error) in
                        if let error = error{
                            print(error)
                            return
                        }
                        do{
                            let showRouteName = try JSONDecoder().decode(RouteResponse.self, from: data!)
                            self.routesName.append((showRouteName.route?.routeName)!)
                            DispatchQueue.main.async {
                                self.nextServiceTableView.reloadData()
                            }
                        } catch{
                            print(error)
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
        getTableData.resume()
        _ = URLSession.shared.dataTask(with: URL(string: lookupStops(stopId: stopId, routeType: routeType))!) { (data, response, error) in
            if let error = error {
                print("Download failed: \(String(describing: error))")
                return
            }
            do {    // Data recieved.  Decode it from JSON.
                let stopDetail = try JSONDecoder().decode(stopResposeById.self, from: data!)
                self.stopNameLabel.text = stopDetail.stop?.stopName
            } catch {
                print("Error:"+error.localizedDescription)
            }
            }.resume()
        
        //                // Get Route Destination
        //                _ = URLSession.shared.dataTask(with: <#T##URL#>){ (data,response,error) in
        //                    if let error = error{
        //                        print(error)
        //                        return
        //                    }
        //                    do{
        //                        let showDestination = try JSONDecoder().decode(RouteResponse.self, from: data!)
        //                        self.routesDest.append(RouteResponse.)
        //                    } catch{
        //                        print(error)
        //                    }
        //                }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1    //Section to be fixed
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nextService", for: indexPath) as! upcomingServiceTableViewCell
        
//        let departuredata = departureData[indexPath.row]
//        cell.typeLabel.text = routesDest[indexPath.row]
//        cell.serviceDestLabel.text = routesName[indexPath.row]
//        cell.detailsLabel.text = ""
//        cell.dueTimeLabel.text = iso8601DateConvert(iso8601Date: departuredata.estimatedDepartureUTC ?? departuredata.scheduledDepartureUTC!, withDate: false)
//        cell.statusLabel.text = ""
        return cell
    }

    fileprivate func extractedFunc(_ request: String) -> String {
        let signature: String = request.hmac(algorithm: CryptoAlgorithm.SHA1, key: hardcodedDevKey)
        let requestAddress: String = hardcodedURL+request+"&signature="+signature
        
        return requestAddress
    }
    
    func nextServiceURL(routeId: Int) -> String{
        let request: String = "/v3/routes/\(routeId)?devid="+hardcodedDevID
        return extractedFunc(request)
    }
    
    func nextDepartureURL(routeType: Int, stopId: Int) -> String{
        let request: String = "/v3/departures/route_type/\(routeType)/stop/\(stopId)?include_cancelled=true&max_results=200&devid="+hardcodedDevID
        return extractedFunc(request)
    }
    
    func lookupStops(stopId: Int, routeType: Int) -> String{
        let request: String = "/v3/stops/\(stopId)/route_type/\(routeType)?devid="+hardcodedDevID
        return extractedFunc(request)
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
