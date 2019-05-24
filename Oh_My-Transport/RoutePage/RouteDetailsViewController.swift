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

    var routeType: Int = 0
    var runId: Int = 0          // Required value from last segue
    var routeId: Int = 0        // Required value from last segue
    
    var stopInfo: StopDetails?     // Optional value from last segue

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
        
        print("Route type:\(routeType); Run Id:\(runId); RouteId:\(routeId)")
        
        // Load the MapView
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard locationManager.location != nil else {
                return
            }
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer  // Less battery required
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }

        _ = URLSession.shared.dataTask(with: URL(string: showPatternonRoute(runId: runId, routeType: routeType))!){(data, response, error) in
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
                for (_, values) in self.patternAllStops{       //  key = stopId, Value = Stop Dictonary
                    let stopDetailsData: NSDictionary = values as! NSDictionary
                        for (key,value) in stopDetailsData{   // Poping values into array
                            if "\(key)" == "stop_id"{
                                self.dictonaryStopId.append(Int("\(value)")!)
                            } else if "\(key)" == "stop_name"{
                                self.dictonaryStopName.append("\(value)")
                            } else if "\(key)" == "stop_suburb"{
                                self.dictonaryStopSuburb.append("\(value)")
                            } else if "\(key)" == "stop_latitude"{
                                self.dictonaryStopLatitude.append(Double("\(value)")!)
                            } else if "\(key)" == "stop_longitude"{
                                self.dictonaryStopLongitude.append(Double("\(value)")!)
                            } else if "\(key)" == "route_type"{
                                self.dictonaryRouteType.append(Int("\(value)")!)
                            }
                        }
                }
                
                var count = 0
                for _ in self.dictonaryStopId{    // Adding stop annotation
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
            page2.routeType = routeType
            page2.stopId = departsData[routeTableView.indexPathForSelectedRow!.row].stopsId!
            page2.managedContext = CoreDataStack().managedContext
            print(routeTableView.indexPathForSelectedRow!.row)
            //车站cell和跳转结果不同 22May
            print("stopId:\(orderedStop[routeTableView.indexPathForSelectedRow!.row].stopId!),StopName:\(orderedStop[routeTableView.indexPathForSelectedRow!.row].stopName!)")
        }
        if segue.identifier == "showRouteDisruption"{
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
            let cellDepartureTime = departsData[indexPath.row].estimatedDepartureUTC ?? departsData[indexPath.row].scheduledDepartureUTC ?? nil!
            //        let cellFlag = departuredata.flags
            
            // Fetching Stop name
            var count = 0
            for each in dictonaryStopId {
                if (each == departsData[indexPath.row].stopsId){     // Due to retrieve data unordered, match data to be present
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
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let myLatitude = stopInfo?.stopLocation?.gps?.latitude ?? locations[0].coordinate.latitude
        let myLongtitude = stopInfo?.stopLocation?.gps?.longitude ?? locations[0].coordinate.longitude
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongtitude), span: currentLocationSpan)
        self.routeMapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
}
