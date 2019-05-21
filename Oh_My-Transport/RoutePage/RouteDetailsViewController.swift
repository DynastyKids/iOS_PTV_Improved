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
    var stopInfo: [StopDetails] = []
    
    var navigationTitle: String = ""
    
    @IBOutlet weak var routeMapView: MKMapView!
    @IBOutlet weak var routeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navigationTitle
        routeTableView.delegate = self
        routeTableView.dataSource = self
        

        print("Route type:\(myRouteType); Run Id:\(myRunId); RouteId:\(myRouteId)")
        
        // Load the MapView
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard locationManager.location != nil else {
                return
            }
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer  // Less battery required
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
                    var count = 0
                    for each in patternData.departures!{
                        let stopInfoURL = URL(string: showStopsInfo(stopId: each.stopsId!, routeType: self.myRouteType))
                        _ = URLSession.shared.dataTask(with: stopInfoURL!){(data, response, error) in
                            if error != nil{
                                print("Pattern fetch failed")
                                return
                            }
                            do{
                                let stopData = try JSONDecoder().decode(stopResposeByStopId.self, from: data!)
                                self.stopInfo.append(stopData.stop!)
                                // Showing All Stops Annotation on Map View
                                let latitude:Double = (stopData.stop?.stopLocation?.gps?.latitude)!
                                let longitude:Double = (stopData.stop?.stopLocation?.gps?.longitude)!
                                let stopPatterns = MKPointAnnotation()
                                stopPatterns.title = stopData.stop!.stopName
                                stopPatterns.subtitle = "Stop ID:\(stopData.stop!.stopId!)"
                                stopPatterns.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                self.routeMapView.addAnnotation(stopPatterns)
                                
                                DispatchQueue.main.async {
                                    print("Reload table view")
                                    self.routeTableView.reloadData()
                                }
                            }catch{
                                print(error)
                            }
                            }.resume()
                        count += 1
                    }
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
            page2.stopURL = showStopsInfo(stopId: stopInfo[routeTableView.indexPathForSelectedRow!.row].stopId! , routeType: myRouteType)
            page2.routeType = myRouteType
            page2.stopId = stopInfo[routeTableView.indexPathForSelectedRow!.row].stopId!
            page2.stopSuburb = stopInfo[routeTableView.indexPathForSelectedRow!.row].stopLocation!.suburb ?? ""
            page2.stopName = stopInfo[routeTableView.indexPathForSelectedRow!.row].stopName!
            page2.managedContext = CoreDataStack().managedContext
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
        return stopInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Section 0
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "routeDisruption", for: indexPath) as! RoutesDisruptionsTableViewCell
            cell.disruptionInfoLabel.text = "\(disruptiondata.count) Disruptions in effect"
            print("Disruptions: \(disruptiondata.count)")
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeStops", for: indexPath) as! RoutesStopTableViewCell
        let departuredata = departsData[indexPath.row]
        let cellStopId = departuredata.stopsId
//        let cellRouteId = departuredata.routesId
//        let cellRunId = departuredata.runId
//        let cellDirectionId = departuredata.directionId
        let cellDepartureTime = departuredata.estimatedDepartureUTC ?? departuredata.scheduledDepartureUTC ?? nil!
//        let cellFlag = departuredata.flags
        
        // Fetching Stop name
        for each in stopInfo {
            if (each.stopId == cellStopId){
                cell.routeStopNameLabel.text = each.stopName    // Due to retrieve data unordered, match data to be present
            }
        }
        cell.routeStopTimeLabel.text = Iso8601toString(iso8601Date: cellDepartureTime, withTime: true, withDate: false)
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
