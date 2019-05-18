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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Changeing color after stop info loaded, set the background color theme as transport types
        switch routeType {  // Transport type category on API PDF Page43
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
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell0 = tableView.dequeueReusableCell(withIdentifier: "stopInfo", for: indexPath)
            
            return cell0
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "nextService", for: indexPath)
        
            
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
