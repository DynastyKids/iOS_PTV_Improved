//
//  DirectionsViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 19/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DirectionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var nslock = NSLock()
    var currentLocation:CLLocation!
    
    var runningServices: [Run] = []
    var runningDestinations: [String] = []  // Showing services to different destinations
    var nearStopId: [Int] = []              // Showing nearest stops(id) to get the service for different directions(destinations)
    var nearStopName: [String] = []              // Showing nearest stops(name) to get the service for different directions(destinations)
    var directionId: [Int] = []
    var nextDepartureTime: [String] = []
    
    var directions: [Run] = []
    var disruptiondata: [Disruption] = []
    var allstopsdata: [stopOnRoute] = []
    var userPosition = CLLocation(latitude: 0.00, longitude: 0.00)
    
    var routeId: Int = 12753                // Testing value, rely on last page passing value to this page
    var routeName: String = ""
    var routeType: Int = 2
    var runs: [Run] = []
    
    @IBOutlet weak var directionsTableView: UITableView!
    @IBOutlet weak var routeMapView: MKMapView!
    @IBOutlet weak var saveRouteButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        directionsTableView.delegate = self
        directionsTableView.dataSource = self
        
        // Load the MapView
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard locationManager.location != nil else {
                return
            }
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.startUpdatingLocation()
        
        // Checking Runs(Destination may different) - Using runid to check stop patterns - using pattern's stop to find nearest stops
        _ = URLSession.shared.dataTask(with: URL(string: showRouteRuns(routeId: routeId))!){ (data, response, error) in
            if error != nil{
                print("Route running data fetch failed")
                return
            }
            do{
                let runsdata = try JSONDecoder().decode(RunsResponse.self, from: data!)
                self.runningServices = runsdata.runs!
                for eachService in self.runningServices{
                    var flag = true
                    for eachName in self.runningDestinations{
                        if eachName == eachService.destinationName{
                            flag = false
                        }
                    }
                    if flag == true{
                        self.runningDestinations.append(eachService.destinationName!)
                    }
                }
                // 有n个方向的车，每种方向都读出Pattern上所有的车站，然后对比用户当前位置找到最近车站
                for eachPattern in self.runningDestinations{
                    var flag = false //填充这个方向车子的数据，如果填充过了，则Flag=true，后续相同service的填充则跳过
                    for eachService in self.runningServices{
                        if flag == true{
                            break
                        }
                        var dictonaryStopId: [Int] = []
                        var dictonaryStopName: [String] = []
                        var dictonaryStopLatitude: [Double] = []
                        var dictonaryStopLongitude: [Double] = []
                        var count = 0
                        var nearStopId = 0
                        var nearStopName: String = ""
                        var stopDistance:Double = 99999999
                        if eachService.destinationName == eachPattern{
                            flag = true
                            self.directions.append(eachService)
                            _ = URLSession.shared.dataTask(with: URL(string: showPatternonRoute(runId: eachService.runId!, routeType: eachService.routeType!))!){(data, response, error) in
                                if error != nil{
                                    print("Pattern fetch failed")
                                    return
                                }
                                do{
                                    let jsonString: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                                    let patternAllStops = jsonString.value(forKey: "stops") as! NSDictionary
                                    for (_, value) in patternAllStops{       //  key = stopId, Value = Stop Dictonary
                                        let stopDetailsData: NSDictionary = value as! NSDictionary
                                        for (key2,value2) in stopDetailsData{   // Poping values into array
                                            if "\(key2)" == "stop_id"{
                                                dictonaryStopId.append(Int("\(value2)")!)
                                            } else if "\(key2)" == "stop_name"{
                                                dictonaryStopName.append("\(value2)")
                                            } else if "\(key2)" == "stop_latitude"{
                                                dictonaryStopLatitude.append(Double("\(value2)")!)
                                            } else if "\(key2)" == "stop_longitude"{
                                                dictonaryStopLongitude.append(Double("\(value2)")!)
                                            }
                                        }
                                    }
                                    // Comparing with stops pattern and user location to find the nearest stop
                                    for _ in dictonaryStopId{
                                        print("User Location:\(self.userPosition.coordinate.latitude),\(self.userPosition.coordinate.longitude)")
                                        let resultDistance = self.userPosition.distance(from: CLLocation(latitude: dictonaryStopLatitude[count], longitude: dictonaryStopLongitude[count]))
                                        if (Double(resultDistance) < Double(stopDistance)) {
                                            nearStopId = dictonaryStopId[count]
                                            stopDistance = resultDistance
                                            nearStopName = dictonaryStopName[count]
                                        }
                                        count += 1
                                    }
                                    print("Near Stop For Service to:\(eachService.destinationName!), Nearest Stop Id:\(nearStopId),Nearest Stop Name:\(nearStopName), Distance:\(stopDistance)")
                                    self.directionId.append(eachService.directionId!)
                                    self.nearStopName.append(nearStopName)
                                    self.nearStopId.append(nearStopId)
                                    
                                    _ = URLSession.shared.dataTask(with: URL(string: showRouteDepartureOnStop(routeType: self.routeType, stopId: nearStopId, routeId: self.routeId, directionId: eachService.directionId!))!){(data, response, error) in
                                        if error != nil{
                                            print("next departure fetch failed")
                                            return
                                        }
                                        do{
                                            let nextDepartureData = try JSONDecoder().decode(DeparturesResponse.self, from: data!)
                                            let allDepartures = nextDepartureData.departures
                                            count = 0
                                            for each in allDepartures{
                                                let differences = (Calendar.current.dateComponents([.minute], from: NSDate.init(timeIntervalSinceNow: 0) as Date, to: Iso8601toDate(iso8601Date: (allDepartures[count].estimatedDepartureUTC ?? (allDepartures[count].scheduledDepartureUTC ?? nil)!)))).minute ?? 0
                                                if differences >= 0 {
                                                    self.nextDepartureTime.append(allDepartures[count].estimatedDepartureUTC ?? (allDepartures[count].scheduledDepartureUTC ?? nil)!)
                                                    self.nextDepartureTime.append(allDepartures[count+1].estimatedDepartureUTC ?? (allDepartures[count+1].scheduledDepartureUTC ?? nil)!)
                                                    self.nextDepartureTime.append(allDepartures[count+2].estimatedDepartureUTC ?? (allDepartures[count+2].scheduledDepartureUTC ?? nil)!)
                                                    break
                                                }
                                                count += 1
                                            }
                                            DispatchQueue.main.async {
                                                self.directionsTableView.reloadData()
                                            }
                                        }catch{
                                            print("Error\(error)")
                                        }
                                        }.resume()
                                }catch{
                                    print("Error:\(error)")
                                }
                            }.resume()
                        }
                    }
                }
            }catch{
                print("Error:\(error)")
            }
        }.resume()
        
        // Fetching all Stops on MapView
        _ = URLSession.shared.dataTask(with: URL(string: showRoutesStop(routeId: routeId, routeType: routeType))!){(data, response, error) in
            if error != nil{
                print("Stops fetch failed")
                return
            }
            do{
                let stopsdata = try JSONDecoder().decode(StopsResponseByRouteId.self, from: data!)
                self.allstopsdata = stopsdata.stops!
                for each in self.allstopsdata{
                    let latitude:Double = each.stopLatitude ?? 0.0
                    let longitude:Double = each.stopLongtitude ?? 0.0
                    print("\(latitude),\(longitude)")
                    let stopPatterns = MKPointAnnotation()
                    stopPatterns.title = each.stopName
                    stopPatterns.subtitle = each.stopSuburb
                    stopPatterns.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    self.routeMapView.addAnnotation(stopPatterns)
                }
            } catch{
                print("Error:\(error)")
            }
        }.resume()
        
        // Checking if having any disruptions affect this route
        _ = URLSession.shared.dataTask(with: URL(string: disruptionByRoute(routeId: routeId))!){ (data, response, error) in
            if error != nil {
                print("Route directions fetch failed")
                return
            }
            do{
                let disruptionData = try JSONDecoder().decode(DisruptionsResponse.self, from: data!)
                if (self.routeType == 0 && (disruptionData.disruptions?.metroTrain?.count)!>0) {
                    self.disruptiondata += (disruptionData.disruptions?.metroTrain)!
                } else if (self.routeType == 1 && (disruptionData.disruptions?.metroTram?.count)!>0){
                    self.disruptiondata += (disruptionData.disruptions?.metroTram)!
                } else if (self.routeType == 2 && (disruptionData.disruptions?.metroBus?.count)!>0 && (disruptionData.disruptions?.regionalBus?.count)!>0 && (disruptionData.disruptions?.skybus?.count)!>0){
                    self.disruptiondata += (disruptionData.disruptions?.metroBus)!
                    self.disruptiondata += (disruptionData.disruptions?.regionalBus)!
                    self.disruptiondata += (disruptionData.disruptions?.skybus)!
                } else if (self.routeType == 3 && (disruptionData.disruptions?.vlineCoach?.count)!>0 && (disruptionData.disruptions?.vlineTrain?.count)!>0) {
                    self.disruptiondata += (disruptionData.disruptions?.vlineCoach)!
                    self.disruptiondata += (disruptionData.disruptions?.vlineTrain)!
                } else if (self.routeType == 4 && (disruptionData.disruptions?.nightbus?.count)! > 0){
                    self.disruptiondata = (disruptionData.disruptions?.nightbus)!
                }
                DispatchQueue.main.async {
                    self.navigationItem.title = self.routeName
                    self.directionsTableView.reloadData()
                }
            }
            catch{
                print("Error:\(error)")
            }
            }.resume()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNextService"{
            let page2:StopPageTableViewController = segue.destination as! StopPageTableViewController
            page2.routeType = routeType
            page2.routeId = routeId
            page2.stopId = nearStopId[(directionsTableView.indexPathForSelectedRow?.row)!]
        }
        if segue.identifier == "showServiceDisruptions"{
            let page2:DisruptionsTableViewController = segue.destination as! DisruptionsTableViewController
            page2.url = URL(string: disruptionByRoute(routeId: routeId))
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if disruptiondata.count > 0 {
                return 1
            }
            return 0
        }
        return nextDepartureTime.count/3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "disruption", for: indexPath) as! directionDisruptionsTableViewCell
            if disruptiondata.count > 1 {
                cell.disruptionTitleLabel.text = "\(disruptiondata.count) disruptions in effect"
            } else {
                cell.disruptionTitleLabel.text = "\(disruptiondata.count) disruption in effect"
            }
            cell.disruptionSubtitleLabel.text = "Tap to see more details"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "directions", for: indexPath) as! DirectionTableViewCell
        cell.directionNameLabel.text = runningDestinations[indexPath.row]
        cell.nearStopLabel.text = nearStopName[indexPath.row]
        
        cell.departure0Time.text = Iso8601toString(iso8601Date: nextDepartureTime[indexPath.row*3], withTime: true, withDate: false)
        cell.departure1Time.text = Iso8601toString(iso8601Date: nextDepartureTime[indexPath.row*3+1], withTime: true, withDate: false)
        cell.departure2Time.text = Iso8601toString(iso8601Date: nextDepartureTime[indexPath.row*3+2], withTime: true, withDate: false)
        cell.departure0Countdown.text = Iso8601Countdown(iso8601Date: nextDepartureTime[indexPath.row*3], status: true)
        cell.departure1Countdown.text = Iso8601Countdown(iso8601Date: nextDepartureTime[indexPath.row*3+1], status: true)
        cell.departure2Countdown.text = Iso8601Countdown(iso8601Date: nextDepartureTime[indexPath.row*3+2], status: true)
        
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        locationManager.startUpdatingLocation()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Functions for MapView
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        // 使用线路中间车站
        let currentLatitude = locations[0].coordinate.latitude
        let currentLongtitude = locations[0].coordinate.longitude
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongtitude), span: currentLocationSpan)
        userPosition = CLLocation(latitude: currentLatitude, longitude: currentLongtitude)
        self.routeMapView.setRegion(region, animated: true)
        print("Currnet Location = \(currentLatitude),\(currentLongtitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
}
