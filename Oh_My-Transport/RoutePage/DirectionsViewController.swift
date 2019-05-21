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
    
    var routeId: Int = 12753
    var directions: [DirectionWithDescription] = []
    var disruptiondata: [Disruption] = []
    var allstopsdata: [stopOnRoute] = []
    var userPosition = CLLocation(latitude: 0.00, longitude: 0.00)
    
    var routeName: String = ""
    var routeType: Int = 2
    var directionId: [Int] = []
    
    var runs: [Run] = []
    var selectedRuns: [Run] = []
    
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
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        //Get all Route directions
        _ = URLSession.shared.dataTask(with: URL(string: showDirectionsOnRoute(routeId: routeId))!){ (data, response, error) in
            if error != nil {
                print("Route directions fetch failed")
                return
            }
            do{
                let directionData = try JSONDecoder().decode(DirectionsResponse.self, from: data!)
                self.directions = directionData.directions!
                
//                // Fetching all running service on this route
//                _ = URLSession.shared.dataTask(with: URL(string: disruptionByRoute(routeId: self.routeId))!){ (data, response, error) in
//                    if error != nil {
//                        print("Route directions fetch failed")
//                        return
//                    }
//                    do{
//                        let allServices = try JSONDecoder().decode(RunsResponse.self, from: data!)
//                        self.runs = allServices.runs!
//                        for each in self.directions{
//                            var count = 0
//                            for i in self.runs{
//                                if i.directionId == each.directionId{
//                                    self.selectedRuns.append(i)
//                                }
//                                if count == 2{
//                                    break
//                                }
//                                count += 1
//                            }
//                        }
                        DispatchQueue.main.async {
                            self.navigationItem.title = self.routeName
                            self.directionsTableView.reloadData()
                        }
//                    }catch{
//                        print("Error\(error)")
//                    }
//                    }.resume()
                
                
            }
            catch{
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
            let page2:RouteDetailsViewController = segue.destination as! RouteDetailsViewController
            page2.myRouteType = 0
            page2.myRunId = 0
            page2.myRouteId = 0
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
        return directions.count
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
        // Fetching all directions
        let directionInfo = directions[indexPath.row]
        cell.directionNameLabel.text = directionInfo.directionName
        
        
//        var stopDistance:Double = 999990000
//        var nearStopId = 0
//        for each in allstopsdata{
//            let stopCoordinates = CLLocation(latitude: each.stopLatitude!, longitude: each.stopLongtitude!)
//            let resultDistance = userPosition.distance(from: stopCoordinates)
//            if stopDistance > resultDistance {
//                print("Near Stop:\(each.stopName), Distance:\(stopDistance)")
//                cell.nearStopLabel.text = each.stopName
//                nearStopId = each.stopId ?? 0
//            }
//        }
        // Find next departure on this route
//        _ = URLSession.shared.dataTask(with: URL(string: showRouteDepartureOnStop(routeType: routeType, stopId: nearStopId, routeId: routeId, directionId: directionInfo.directionId!))!){(data, response, error) in
//            if error != nil{
//                print("Stops fetch failed")
//                return
//            }
//            do{
//                let cellNextDepartureData = try JSONDecoder().decode(DeparturesResponse.self, from: data!)
//                DispatchQueue.main.async {
//                    cell.departure0Time.text = Iso8601toString(iso8601Date: cellNextDepartureData.departures[0].estimatedDepartureUTC ?? cellNextDepartureData.departures[0].scheduledDepartureUTC ?? nil, withTime: true, withDate: false)
//                    cell.departure1Time.text = Iso8601toString(iso8601Date: cellNextDepartureData.departures[1].estimatedDepartureUTC ?? cellNextDepartureData.departures[1].scheduledDepartureUTC ?? nil, withTime: true, withDate: false)
//                    cell.departure2Time.text = Iso8601toString(iso8601Date: cellNextDepartureData.departures[2].estimatedDepartureUTC ?? cellNextDepartureData.departures[2].scheduledDepartureUTC ?? nil, withTime: true, withDate: false)
//
//                    cell.departure0Countdown.text = Iso8601Countdown(iso8601Date: cellNextDepartureData.departures[0].estimatedDepartureUTC ?? cellNextDepartureData.departures[0].scheduledDepartureUTC!)
//                    cell.departure1Countdown.text = Iso8601Countdown(iso8601Date: cellNextDepartureData.departures[1].estimatedDepartureUTC ?? cellNextDepartureData.departures[1].scheduledDepartureUTC!)
//                    cell.departure2Countdown.text = Iso8601Countdown(iso8601Date: cellNextDepartureData.departures[2].estimatedDepartureUTC ?? cellNextDepartureData.departures[2].scheduledDepartureUTC!)
//                }
//            }catch{
//                print("Error\(error)")
//            }
//        }.resume()
        
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
        // 使用线路中间车站
        let currentLatitude = locations[0].coordinate.latitude
        let currentLongtitude = locations[0].coordinate.longitude
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: currentLatitude, longitude: currentLongtitude), span: currentLocationSpan)
        userPosition = CLLocation(latitude: currentLatitude, longitude: currentLongtitude)
        self.routeMapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
}
