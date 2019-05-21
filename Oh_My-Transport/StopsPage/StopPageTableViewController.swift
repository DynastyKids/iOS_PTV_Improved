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
    
    var departureData: [Departure] = []
    var routeInfo: [RouteWithStatus] = []
    
    var routeName:[String] = []
    
    var currentLoopCount = 0
    var fetchingLimit = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Get the stop name
        _ = URLSession.shared.dataTask(with: URL(string: showStopsInfo(stopId: stopId, routeType: routeType))!) { (data, response, error) in
            if let error = error {
                print("Download failed: \(String(describing: error))")
                return
            }
            do {    // Data recieved.  Decode it from JSON.
                let stopDetail = try JSONDecoder().decode(stopResposeByStopId.self, from: data!)
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
                let showDeparture = try JSONDecoder().decode(DeparturesResponse.self, from: data!)
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
            cell0.backgroundColor = changeColorByRouteType(routeType: routeType)
            return cell0
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "nextService", for: indexPath) as! nextServiceTableViewCell
        cell.routeToLabel.text = " to "
        _ = URLSession.shared.dataTask(with: URL(string: showRouteInfo(routeId: departureData[indexPath.row].routesId!))!){(data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            do{
                let showRoute = try JSONDecoder().decode(RouteResponse.self, from: data!)
                DispatchQueue.main.async {
                    if(showRoute.route?.routeType == 0 || showRoute.route?.routeType == 3){
                        let str: String = showRoute.route!.GtfsId!
                        let start = str.index(str.startIndex, offsetBy: 2)
                        cell.routeSignLabel.text = String(str[start...])      // Metro and vline will using its gtfsid to ident which line's service is running
                    } else {
                        cell.routeSignLabel.text = showRoute.route?.routeNumber // All other service using existing route numbers
                    }
                    self.routeName.append(cell.routeSignLabel.text!)
                    cell.routeSignLabel.textColor = UIColor.white
                }
            } catch{
                print("Error on looking up route")
            }
            }.resume()
        _ = URLSession.shared.dataTask(with: URL(string: showDirectionsOnRoute(routeId: departureData[indexPath.row].routesId!))!){(data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            do{
                let showDirection = try JSONDecoder().decode(DirectionsResponse.self, from: data!)
                DispatchQueue.main.async {
                    var count = 0
                    while self.departureData[indexPath.row].directionId != showDirection.directions![count].directionId {
                        count += 1
                    }
                    cell.routeDestinationLabel.text = showDirection.directions![count].directionName!
                }
            }catch{
                print(error)
            }
            }.resume()
        
        cell.routeSignLabel.backgroundColor = changeColorByRouteType(routeType: routeType)
//        cell.routeDestinationLabel.text = routesDest[indexPath.row]
        cell.routeDetailslabel.text = "Temporary Empty"
        
        cell.routeDueTimeLabel.text = Iso8601Countdown(iso8601Date: departureData[indexPath.row].estimatedDepartureUTC ?? departureData[indexPath.row].scheduledDepartureUTC!)
        if departureData[indexPath.row].estimatedDepartureUTC == nil {
            cell.routeStatusLabel.text = "Scheduled"
            cell.routeStatusLabel.textColor = UIColor.gray
        }else {
            let mintes = Iso8601toStatus(iso8601DateSchedule: departureData[indexPath.row].scheduledDepartureUTC!, iso8601DateActual: departureData[indexPath.row].estimatedDepartureUTC!)
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Click on Disruptions Button
        if segue.identifier == "showStopDisruptions"{
            let page2:DisruptionsTableViewController = segue.destination as! DisruptionsTableViewController
            page2.url = URL(string: disruptionByStop(stopID: stopId))
        }
        // Click on Route Cell
        if segue.identifier == "showRouteDetails" {
            let page2:RouteDetailsViewController = segue.destination as! RouteDetailsViewController
            page2.myRunId = departureData[tableView.indexPathForSelectedRow!.row].runId!
            page2.myRouteId = departureData[tableView.indexPathForSelectedRow!.row].routesId!
            page2.myRouteType = routeType
            page2.navigationTitle = "Route: \(routeName[tableView.indexPathForSelectedRow!.row])"
        }
    }
}
