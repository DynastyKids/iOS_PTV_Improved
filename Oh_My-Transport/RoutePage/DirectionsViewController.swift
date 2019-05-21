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
    var direction: DirectionWithDescription!
    var disruptiondata: [Disruption] = []
    
    var routeName: String = ""
    
    var routeType: Int = 2
    var directionId: [Int] = []
    
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
        
        // Check route disruptions
        _ = URLSession.shared.dataTask(with: URL(string: disruptionByRoute(routeId: routeId))!){(data, response, error) in
            if error != nil{
                print("Route disruptions information fetch failed")
            }
            do{
                let disruptionsData = try JSONDecoder().decode(DisruptionsResponse.self, from: data!)
                if (disruptionsData.disruptions?.general?.count)! > 0 {self.disruptiondata += disruptionsData.disruptions!.general!}
                if (disruptionsData.disruptions?.metroTrain?.count)! > 0 { self.disruptiondata += disruptionsData.disruptions!.metroTrain!}
                if (disruptionsData.disruptions?.metroTram?.count)! > 0 {self.disruptiondata += disruptionsData.disruptions!.metroTram!}
                if (disruptionsData.disruptions?.metroBus?.count)! > 0 {self.disruptiondata += disruptionsData.disruptions!.metroBus!}
                if (disruptionsData.disruptions?.regionalBus?.count)! > 0 {self.disruptiondata += disruptionsData.disruptions!.regionalBus!}
                if (disruptionsData.disruptions?.vlineTrain?.count)! > 0 {self.disruptiondata += disruptionsData.disruptions!.vlineTrain!}
                if (disruptionsData.disruptions?.vlineCoach?.count)! > 0 {self.disruptiondata += disruptionsData.disruptions!.vlineCoach!}
                if (disruptionsData.disruptions?.schoolBus?.count)! > 0 {self.disruptiondata += disruptionsData.disruptions!.schoolBus!}
                if (disruptionsData.disruptions?.telebus?.count)! > 0 {self.disruptiondata += disruptionsData.disruptions!.telebus!}
                if (disruptionsData.disruptions?.nightbus?.count)! > 0 {self.disruptiondata += disruptionsData.disruptions!.nightbus!}
                if (disruptionsData.disruptions?.ferry?.count)! > 0 {self.disruptiondata += disruptionsData.disruptions!.ferry!}
                if (disruptionsData.disruptions?.interstate?.count)! > 0 {self.disruptiondata += disruptionsData.disruptions!.interstate!}
                if (disruptionsData.disruptions?.skybus?.count)! > 0 {self.disruptiondata += disruptionsData.disruptions!.skybus!}
                if (disruptionsData.disruptions?.taxi?.count)! > 0 {self.disruptiondata += disruptionsData.disruptions!.taxi!}
            } catch {
                print("Error:\(error)")
            }
        }.resume()
        
        //Check Route directions
        _ = URLSession.shared.dataTask(with: URL(string: showDirectionsOnRoute(routeId: routeId))!){ (data, response, error) in
            if error != nil {
                print("Route directions fetch failed")
                return
            }
            do{
                let directionData = try JSONDecoder().decode(DirectionsResponse.self, from: data!)
                self.directions = directionData.directions!
                
                DispatchQueue.main.async {
                    self.navigationItem.title = self.routeName
                    self.directionsTableView.reloadData()
                }
            }
            catch{
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
                let decoder = JSONDecoder()
                let disruptionData = try decoder.decode(DisruptionsResponse.self, from: data!)
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

        // Do any additional setup after loading the view.
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
        cell.nearStopLabel.text = "Your Nearest Stop"
        
        // fetching all stops on this direction
        let directionId = directionInfo.directionId
        
        
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
        let myLatitude = locations[0].coordinate.latitude
        let myLongtitude = locations[0].coordinate.longitude
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongtitude), span: currentLocationSpan)
        self.routeMapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
}
