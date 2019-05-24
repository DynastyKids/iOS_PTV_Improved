//
//  RouteDetailsViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 19/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RouteDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!

    var myRouteType: Int = 0
    var myRunId: Int = 0
    var myRouteId: Int = 0

    // MARK: - Receiving data from whole array carrying all necessary data
    var disruptiondata: [Disruption] = []
    var departsData: [Departure] = []
    var orderedStop: [StopDetails] = []
    
    var navigationTitle: String = ""
    
    var patternAllStops: NSDictionary = [:]
    var dictonaryStopId: [Int] = []
    var dictonaryStopName: [String] = []
    var dictonaryStopSuburb: [String] = []
    var dictonaryStopLatitude: [Double] = []
    var dictonaryStopLongitude: [Double] = []
    var dictonaryRouteType: [Int] = []
    
    @IBOutlet weak var routeMapView: MKMapView!
    @IBOutlet weak var routeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navigationTitle
        routeTableView.delegate = self
        routeTableView.dataSource = self
        
        print("Route type:\(myRouteType); Run Id:\(myRunId); RouteId:\(myRouteId)")
        
        // Load the MapView
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard locationManager.location != nil else {
                return
            }
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters  // Less battery required
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }

        _ = URLSession.shared.dataTask(with: URL(string: showPatternonRoute(runId: myRunId, routeType: myRouteType))!){(data, response, error) in
            if error != nil{
                print("Pattern fetch failed")
                return
            }
            do{
                let patternData = try JSONDecoder().decode(PatternResponse.self, from: data!)
                // Loading disruption data
                if((patternData.disruptions?.count)!>0){
                    self.disruptiondata = patternData.disruptions!
                }
                if((patternData.departures?.count)!>0){
                    self.departsData = patternData.departures!
                }
                let routePatternDictonary: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary      // Alternative method by NSDictonary to fetching all stops data
                self.patternAllStops = routePatternDictonary.value(forKey: "stops") as! NSDictionary
                for (key, value) in self.patternAllStops{       //  key = stopId, Value = Stop Dictonary
                    let stopDetailsData: NSDictionary = value as! NSDictionary
                        for (key2,value2) in stopDetailsData{   // Poping values into array
                            if "\(key2)" == "stop_id"{
                                self.dictonaryStopId.append(Int("\(value2)")!)
                            } else if "\(key2)" == "stop_name"{
                                self.dictonaryStopName.append("\(value2)")
                            } else if "\(key2)" == "stop_suburb"{
                                self.dictonaryStopSuburb.append("\(value2)")
                            } else if "\(key2)" == "stop_latitude"{
                                self.dictonaryStopLatitude.append(Double("\(value2)")!)
                            } else if "\(key2)" == "stop_longitude"{
                                self.dictonaryStopLongitude.append(Double("\(value2)")!)
                            } else if "\(key2)" == "route_type"{
                                self.dictonaryRouteType.append(Int("\(value2)")!)
                            }
                        }
                }
                
                var count = 0
                for each in self.dictonaryStopId{    // Adding stop annotation
                    let stopPatterns = MKPointAnnotation()
                    stopPatterns.title = self.dictonaryStopName[count]
                    stopPatterns.subtitle = self.dictonaryStopSuburb[count]
                    stopPatterns.coordinate = CLLocationCoordinate2D(latitude: self.dictonaryStopLatitude[count], longitude: self.dictonaryStopLongitude[count])
                    self.routeMapView.addAnnotation(stopPatterns)
                    count += 1
                }
                DispatchQueue.main.async {
                    print("Reload table view")
                    self.routeTableView.reloadData()
                }
            } catch {
                print("Error:\(error)")
            }
        }.resume()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStopFromPatternPage" {
            let page2:StopPageTableViewController = segue.destination as! StopPageTableViewController
            page2.routeType = myRouteType
            page2.stopId = orderedStop[routeTableView.indexPathForSelectedRow!.row].stopId!
            page2.stopSuburb = orderedStop[routeTableView.indexPathForSelectedRow!.row].stopLocation!.suburb ?? ""
            page2.stopName = orderedStop[routeTableView.indexPathForSelectedRow!.row].stopName!
            page2.managedContext = CoreDataStack().managedContext
            print(routeTableView.indexPathForSelectedRow!.row)
            //车站cell和跳转结果不同 22May
            print("stopId:\(orderedStop[routeTableView.indexPathForSelectedRow!.row].stopId!),StopName:\(orderedStop[routeTableView.indexPathForSelectedRow!.row].stopName!)")
        }
        if segue.identifier == "showRouteDisruption"{
            let page2:DisruptionsTableViewController = segue.destination as! DisruptionsTableViewController
            page2.url = URL(string: disruptionByRoute(routeId: myRouteId))
        }
    }

    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if disruptiondata.count > 0{
                return 1
            }
            return 0
        }
        return dictonaryStopId.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {     // Section 0 (Disruptions)
            let cell = tableView.dequeueReusableCell(withIdentifier: "routeDisruption", for: indexPath) as! RoutesDisruptionsTableViewCell
            cell.disruptionInfoLabel.text = "\(disruptiondata.count) Disruptions may affect your travel"
            print("Disruptions: \(disruptiondata.count)")
            return cell
        }
        if indexPath.section == 1 {     // Section 1 (Stops)
            let cell = tableView.dequeueReusableCell(withIdentifier: "routeStops", for: indexPath) as! RoutesStopTableViewCell
            let departuredata = departsData[indexPath.row]
            let cellDepartureTime = departuredata.estimatedDepartureUTC ?? departuredata.scheduledDepartureUTC ?? nil!
            //        let cellFlag = departuredata.flags
            
            // Fetching Stop name
            var count = 0
            for each in dictonaryStopId {
                if (each == departuredata.stopsId){     // Due to retrieve data unordered, match data to be present
                    cell.routeStopNameLabel.text = dictonaryStopName[count]
                    let coordinate = Gps(latitude: dictonaryStopLatitude[count], longitude: dictonaryStopLongitude[count])
                    let stopLocation = StopLocation(gps: coordinate, suburb: dictonaryStopSuburb[count])
                    let stops = StopDetails(disruptionIds: nil, stationType: nil, stationDescription: nil, routeType: dictonaryRouteType[count], stopLocation: stopLocation, stopId: dictonaryStopId[count], stopName: dictonaryStopName[count])
                    orderedStop.append(stops)
                }
                count += 1
            }
            cell.routeStopTimeLabel.text = Iso8601toString(iso8601Date: cellDepartureTime, withTime: true, withDate: false)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "doesNotExist", for: indexPath) as! RoutesStopTableViewCell
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Functions for MapView
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        // 先尝试Fetch车辆位置，不可用后使用用户中心
        let myLatitude = locations[0].coordinate.latitude
        let myLongtitude = locations[0].coordinate.longitude
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongtitude), span: currentLocationSpan)
        self.routeMapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
}
