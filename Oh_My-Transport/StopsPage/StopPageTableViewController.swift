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
    
    // MARK: - CoreData Properties
    var managedContext: NSManagedObjectContext!
    var stops: FavStop?
    var stopFetchedResultsController: NSFetchedResultsController<FavStop>!
    
    var stopId: Int = 0             // This value require passed from last segue
    var routeType: Int = 0          // This value require passed from last segue
    var stopName: String = ""
    var stopSuburb: String = ""
    var routeId: Int = -1
    
    var stopInfo:StopDetails?
    
    var departureData: [Departure] = []
    var nextDepartRoutesData: [RouteWithStatus] = []
    var nextDepartRunsInfo: [Run] = []
    var nextDepartDirectionInfo: [DirectionWithDescription] = []
    var nextDepartDisruptionInfo: [Disruption] = []
    var nextDepartStopInfo: [stopGeosearch] = []
    
//    var routeName:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = URLSession.shared.dataTask(with: URL(string: showStopsInfo(stopId: stopId, routeType: routeType))!) { (data, response, error) in    //Get the stop name, stop suburb
            if let error = error {
                print("Download failed: \(String(describing: error))")
                return
            }
            do {    // Data recieved.  Decode it from JSON.
                let stopDetail = try JSONDecoder().decode(stopResposeByStopId.self, from: data!)
                self.stopInfo = stopDetail.stop
                DispatchQueue.main.async {
                    self.stopName = stopDetail.stop?.stopName ?? ""
                    self.stopSuburb = stopDetail.stop?.stopLocation?.suburb ?? ""
                    print("Value Received: StopId:\(self.stopId), StopName:\(self.stopName), StopSuburb:\(self.stopSuburb)")
                    self.tableView.reloadData()
                }
            } catch {
                print("Error:"+error.localizedDescription)
            }
            }.resume()
        
        var nextDepart = nextDepartureURL(routeType: routeType, stopId: stopId)
        if routeId != -1 {
            nextDepart = showRouteDepartureOnStop(routeType: routeType, stopId: stopId, routeId: routeId)
            routeId = -1
        }
        _ = URLSession.shared.dataTask(with: URL(string: nextDepart)!) { (data, response, error) in
            if let error = error {
                print("Download failed: \(String(describing: error))")
                return
            }
            do {
                let showDeparture = try JSONDecoder().decode(DeparturesResponse.self, from: data!)
                guard showDeparture.departures != nil else{
                    return
                }
                for each in showDeparture.departures!{
                    let departureTime = each.estimatedDepartureUTC ?? each.scheduledDepartureUTC!
                    let difference = Calendar.current.dateComponents([.minute], from: NSDate.init(timeIntervalSinceNow: 0) as Date, to: Iso8601toDate(iso8601Date: departureTime))
                    if difference.minute! > -10 {
                        self.departureData.append(each)
                    }
                }
                
                let nextDepartureDictonary: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                let nextDepartRoutes = nextDepartureDictonary.value(forKey: "routes") as! NSDictionary
                let nextDepartDisruptions = nextDepartureDictonary.value(forKey: "disruptions") as! NSDictionary
                let nextDepartRuns = nextDepartureDictonary.value(forKey: "runs") as! NSDictionary
                let nextDepartStops = nextDepartureDictonary.value(forKey: "stops") as! NSDictionary
                let nextDepartDirections = nextDepartureDictonary.value(forKey: "directions") as! NSDictionary
                for(_, value) in nextDepartRoutes{
                    let nextDepartRouteData: NSDictionary = value as! NSDictionary
                    var routeGtfsId: String = ""
                    var routeRouteType: Int = 0
                    var routeId: Int = 0
                    var routeName: String = ""
                    var routeNumber: String = ""
                    for(key, value2) in nextDepartRouteData{
                        if "\(key)" == "route_gtfs_id"{
                            routeGtfsId = value2 as! String
                        }else if "\(key)" == "route_type"{
                            routeRouteType = value2 as! Int
                        }else if "\(key)" == "route_id"{
                            routeId = value2 as! Int
                        }else if "\(key)" == "route_name"{
                            routeName = value2 as! String
                        }else if "\(key)" == "route_number"{
                            routeNumber = value2 as! String
                        }
                    }
                    self.nextDepartRoutesData.append(RouteWithStatus.init(routeType: routeRouteType, routeId: routeId, routeName: routeName, routeNumber: routeNumber, GtfsId: routeGtfsId))
                }
                for (_, values) in nextDepartDisruptions{
                    let nextDisruptionsData: NSDictionary = values as! NSDictionary
                    var disruptionId: Int = 0
                    var disruptionTitle: String = ""
                    var disruptionURL: String = ""
                    var disruptionDescription: String = ""
                    var disruptionStatus: String = ""
                    var disruptionType: String = ""
                    var disruptionPublishDate: String = ""
                    var disruptionUpdateDate: String = ""
                    var disruptionStartDate: String = ""
                    var disruptionEndDate: String = ""
                    for(key, value) in nextDisruptionsData{
                        if "\(key)" == "disruption_id" {
                            disruptionId = value as! Int
                        } else if "\(key)" == "title" {
                            disruptionTitle = value as! String
                        } else if "\(key)" == "url" {
                            disruptionURL = value as! String
                        } else if "\(key)" == "description" {
                            disruptionDescription = value as! String
                        } else if "\(key)" == "disruption_status" {
                            disruptionStatus = value as! String
                        } else if "\(key)" == "disruption_type" {
                            disruptionType = value as! String
                        } else if "\(key)" == "published_on" {
                            disruptionPublishDate = value as! String
                        } else if "\(key)" == "last_updateed" {
                            disruptionUpdateDate = value as! String
                        } else if "\(key)" == "from_date" {
                            disruptionStartDate = value as! String
                        } else if "\(key)" == "to_date" {
                            disruptionEndDate = value as! String
                        }
                    }
                    self.nextDepartDisruptionInfo.append(Disruption.init(disruptionId: disruptionId, title: disruptionTitle, url: disruptionURL, description: disruptionDescription, disruptionStatus: disruptionStatus, disruptionType: disruptionType, publishDate: disruptionPublishDate, updateDate: disruptionUpdateDate, startDate: disruptionStartDate, endDate: disruptionEndDate))
                }
                for(_,values) in nextDepartRuns{
                    let nextRunsData: NSDictionary = values as! NSDictionary
                    var runId: Int = 0
                    var routeId: Int = 0
                    var routeType: Int = 0
                    var finalStopId: Int = 0
                    var destinationName: String = ""
                    var status: String = ""
                    var directionId: Int = 0
                    var runSequence: Int = 0
                    var expressStopCount: Int = 0
                    for(key, value) in nextRunsData{
                        if "\(key)" == "run_id"{
                            runId = value as! Int
                        } else if "\(key)" == "route_id"{
                            routeId = value as! Int
                        } else if "\(key)" == "route_type"{
                            routeType = value as! Int
                        } else if "\(key)" == "final_stop_id"{
                            finalStopId = value as! Int
                        } else if "\(key)" == "destination_name"{
                            destinationName = value as! String
                        } else if "\(key)" == "status"{
                            status = value as! String
                        } else if "\(key)" == "direction_id"{
                            directionId = value as! Int
                        } else if "\(key)" == "run_sequence"{
                            runSequence = value as! Int
                        } else if "\(key)" == "express_stop_count"{
                            expressStopCount = value as! Int
                        }
                    }
                    self.nextDepartRunsInfo.append(Run.init(runId: runId, routeId: routeId, routeType: routeType, finalStopId: finalStopId, destinationName: destinationName, status: status, directionId: directionId, runSequence: runSequence, expressStopCount: expressStopCount, vehiclePosition: nil, vehicleDescriptor: nil))
                }
                
                for (_, values) in nextDepartStops{
                    let nextStopData: NSDictionary = values as! NSDictionary
                    var stopDistance: Double = 0
                    var stopSuburb: String = ""
                    var stopName: String = ""
                    var stopId: Int = 0
                    var routeType: Int = 0
                    var stopLatitude: Double = 0
                    var stopLongitude: Double = 0
                    var stopSequence: Int = 0
                    for (key,value) in nextStopData{
                        if "\(key)" == "stop_distance"{
                            stopDistance = value as! Double
                        } else if "\(key)" == "stop_suburb"{
                            stopSuburb = value as! String
                        } else if "\(key)" == "stop_name"{
                            stopName = value as! String
                        } else if "\(key)" == "stop_id"{
                            stopId = value as! Int
                        } else if "\(key)" == "route_type"{
                            routeType = value as! Int
                        } else if "\(key)" == "stop_latitude"{
                            stopLatitude = value as! Double
                        } else if "\(key)" == "stop_longitude"{
                            stopLongitude = value as! Double
                        } else if "\(key)" == "stop_sequence"{
                            stopSequence = value as! Int
                        }
                    }
                    self.nextDepartStopInfo.append(stopGeosearch.init(stopDistance: stopDistance, stopSuburb: stopSuburb, stopName: stopName, stopId: stopId, routeType: routeType, stopLatitude: stopLatitude, stopLongitude: stopLongitude, stopSequence: stopSequence))
                }
                
                for(_, values) in nextDepartDirections{
                    let nextDirectionData: NSDictionary = values as! NSDictionary
                    var directionId: Int = 0
                    var directionName: String = ""
                    var routeId: Int = 0
                    var routeType: Int = 0
                    for(key, value) in nextDirectionData{
                        if "\(key)" == "direction_id"{
                            directionId = value as! Int
                        } else if "\(key)" == "direction_name"{
                            directionName = value as! String
                        } else if "\(key)" == "route_id"{
                            routeId = value as! Int
                        } else if "\(key)" == "route_type"{
                            routeType = value as! Int
                        }
                    }
                    self.nextDepartDirectionInfo.append(DirectionWithDescription.init(routeDirectionDescription: nil, directionId: directionId, directionName: directionName, routeId: routeId, routeType: routeType))
                }
                
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
//            self.navigationController?.popToRootViewController(animated: true)
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
            if(nextDepartDisruptionInfo.count == 1){
                cell0.disruptionButton.setTitle("No Disruption, enjoy your trip", for: UIControl.State.normal)
            }else if(nextDepartDisruptionInfo.count == 1){
                cell0.disruptionButton.setTitle("1 Disruption may affect your travel", for: UIControl.State.normal)
            } else {
                cell0.disruptionButton.setTitle("\(nextDepartDisruptionInfo.count) Disruptions in effect", for: UIControl.State.normal)
            }
            cell0.backgroundColor = changeColorByRouteType(routeType: routeType)
            navigationItem.rightBarButtonItem?.isEnabled = true
            return cell0
        }
        if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "nextService", for: indexPath) as! nextServiceTableViewCell
            let cellData = departureData[indexPath.row]
            for each in nextDepartRoutesData{
                if cellData.routesId == each.routeId{
                    if (each.routeType == 0 || each.routeType == 3 || each.routeNumber == nil){
                        let routeGTFS = each.GtfsId ?? each.routeNumber!
                        let cuttedName = routeGTFS.index(routeGTFS.startIndex, offsetBy: 2)
                        cell.routeSignLabel.text = String(routeGTFS[cuttedName...])
                    }else{
                        cell.routeSignLabel.text = each.routeNumber
                    }
                    cell.routeSignLabel.backgroundColor = changeColorByRouteType(routeType: each.routeType!)
                }
            }
            for each in nextDepartDirectionInfo{
                if cellData.directionId == each.directionId{
                    cell.routeDestinationLabel.text = each.directionName
                }
            }
            cell.routeDueTimeLabel.text = Iso8601Countdown(iso8601Date: cellData.estimatedDepartureUTC ?? cellData.scheduledDepartureUTC!, status: false)
            if cellData.estimatedDepartureUTC == nil {
                cell.routeStatusLabel.text = "Scheduled"
                cell.routeStatusLabel.textColor = UIColor.gray
            }else {
                let mintes = Iso8601toStatus(iso8601DateSchedule: cellData.scheduledDepartureUTC!, iso8601DateActual: cellData.estimatedDepartureUTC!)
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
            if (cell.routeStatusLabel.text == "Scheduled") {
                cell.routeDetailslabel.text = "Real time data unavailable."
            } else{
                cell.routeDetailslabel.text = "Vehicle location data uplinked."
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Nothing", for: indexPath)
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
            page2.runId = departureData[tableView.indexPathForSelectedRow!.row].runId!
            page2.routeId = departureData[tableView.indexPathForSelectedRow!.row].routesId!
            page2.routeType = routeType
            page2.stopInfo = stopInfo
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
