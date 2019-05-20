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
    
    var vehiclePos: [VehiclePosition] = []
//    var routesInfo:
    // MARK: - Receiving data from whole array carrying all necessary data
    var disruptiondata: [Disruption] = []
    var departsData: [Departure] = []
    
    var stopName: [String] = []
    
    @IBOutlet weak var routeMapView: MKMapView!
    @IBOutlet weak var routeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters


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
                for each in self.departsData{
                    _ = URLSession.shared.dataTask(with: URL(string: showStopsInfo(stopId: each.stopsId!, routeType: self.myRouteType))!){(data, response, error) in
                    if error != nil{
                        print("Pattern fetch failed")
                        return
                    }
                    do{
                        let stopInfoData = try JSONDecoder().decode(stopResposeById.self, from: data!)
                        self.stopName.append((stopInfoData.stop?.stopName)!)
                        
                        DispatchQueue.main.async {
                            self.locationManager.startUpdatingLocation()
                            self.routeTableView.reloadData()
                        }
                    } catch {
                        print("Error:\(error)")
                    }
                    }.resume()
                }
            } catch {
                print("Error:\(error)")
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
        return departsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "routeDisruption", for: indexPath) as! RoutesDisruptionsTableViewCell
            cell.disruptionInfoLabel.text = "\(disruptiondata.count) Disruptions in effect, Tap to see details"
            print("Disruptions: \(disruptiondata.count)")
            return cell
        }
        // Section 1
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeStops", for: indexPath) as! RoutesStopTableViewCell
        // Fetch all pettern stops 在地图中创建大头钉，用户点击Cell后跳转到对应车站
        let departuredata = departsData[indexPath.row]
        let cellStopId = departuredata.stopsId
//        let cellRouteId = departuredata.routesId
//        let cellRunId = departuredata.runId
//        let cellDirectionId = departuredata.directionId
        let cellDepartureTime = departuredata.estimatedDepartureUTC ?? departuredata.scheduledDepartureUTC
        let cellFlag = departuredata.flags
        
        // Fetching Stop name
        cell.routeStopNameLabel.text = stopName[indexPath.row]
        cell.routeStopTimeLabel.text = iso8601DateConvert(iso8601Date: cellDepartureTime ?? "nil")
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Functions for MapView
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        // 先尝试Fetch车辆位置，不可用后使用用户中心
        var myLatitude = locations[0].coordinate.latitude
        var myLongtitude = locations[0].coordinate.longitude
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongtitude), span: currentLocationSpan)
        self.routeMapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    // MARK: - ISO8601 date conversion
    func iso8601DateConvert(iso8601Date: String) -> String{
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
        mydateformat.dateFormat = "hh:mm a"
        return mydateformat.string(from: date!)
    }
}
