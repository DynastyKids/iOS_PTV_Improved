//
//  RouteDetailsViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 19/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class RouteDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, CLLocationManagerDelegate {
    // MARK: Core Location Properties
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var routeType: Int = 0
    var runId: Int = 0          // Required value from last segue
    var routeId: Int = 0        // Required value from last segue
    var senderStopId: Int = 0
    var stopLongitude: Double?     // Optional value from last segue
    var stopLatitude: Double?      // Optional value from last segue

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
    
    var stopFetchedResultsController: NSFetchedResultsController<FavStop>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navigationTitle
        routeTableView.delegate = self
        routeTableView.dataSource = self
        
        // Load the MapView
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse || CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard locationManager.location != nil else {
                return
            }
        }
        routeMapView.delegate = self
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
                if patternData.message != nil {
                    self.displayMessage(title: "Oops!", message: "There has some error happens on server, try again later")
                    return;
                }
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
                        if "\(key)" == "stop_id" && (value is NSNull) == false{
                            self.dictonaryStopId.append(Int("\(value)")!)
                        } else if "\(key)" == "stop_name" && (value is NSNull) == false{
                            self.dictonaryStopName.append("\(value)")
                        } else if "\(key)" == "stop_suburb" && (value is NSNull) == false{
                            self.dictonaryStopSuburb.append("\(value)")
                        } else if "\(key)" == "stop_latitude" && (value is NSNull) == false{
                            self.dictonaryStopLatitude.append(Double("\(value)")!)
                        } else if "\(key)" == "stop_longitude" && (value is NSNull) == false{
                            self.dictonaryStopLongitude.append(Double("\(value)")!)
                        } else if "\(key)" == "route_type" && (value is NSNull) == false{
                            self.dictonaryRouteType.append(Int("\(value)")!)
                        }
                    }
                }
                var serviceDestination: String = ""
                let runsInfo = routePatternDictonary.value(forKey: "runs") as! NSDictionary
                for (_, values) in runsInfo{
                    let routeInfoDetails: NSDictionary = values as! NSDictionary
                    for (key, value) in routeInfoDetails{
                        if "\(key)" == "destination_name" && (value is NSNull) == false{
                            serviceDestination = "\(value)"
                        }
                    }
                }
                if serviceDestination.count > 15 {
                    let directionInfo = routePatternDictonary.value(forKey: "directions") as! NSDictionary
                    for(_,values) in directionInfo{
                        let directionInfoDetails: NSDictionary = values as! NSDictionary
                        for(key, value) in directionInfoDetails{
                            if "\(key)" == "direction_name" && (value is NSNull) == false{
                                serviceDestination = "\(value)"
                            }
                        }
                    }
                }
                var count = 0
                for _ in self.dictonaryStopId{    // Adding stop annotation
                    let stopPatterns = customPointAnnotation()
                    stopPatterns.title = self.dictonaryStopName[count]
                    stopPatterns.subtitle = "Stop Id:\(self.dictonaryStopId[count]), Suburb:\(self.dictonaryStopSuburb[count])"
                    stopPatterns.coordinate = CLLocationCoordinate2D(latitude: self.dictonaryStopLatitude[count], longitude: self.dictonaryStopLongitude[count])
                    stopPatterns.routeType = self.dictonaryRouteType[count]
                    self.routeMapView.addAnnotation(stopPatterns)
                    count += 1
                }
                DispatchQueue.main.async {
                    self.routeTableView.reloadData()
                    if serviceDestination != "" {
                        self.navigationItem.title = "\(serviceDestination) Service"
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
            page2.routeType = routeType
            page2.stopId = departsData[routeTableView.indexPathForSelectedRow!.row].stopsId!
            page2.managedContext = CoreDataStack().managedContext
        }
        if segue.identifier == "showStopFromPatternMap"{
            let page2:StopPageTableViewController = segue.destination as! StopPageTableViewController
            page2.routeType = routeType
            page2.stopId = senderStopId
            page2.managedContext = CoreDataStack().managedContext
        }
        if segue.identifier == "showRouteDisruption"{
            let page2:DisruptionsTableViewController = segue.destination as! DisruptionsTableViewController
            page2.url = URL(string: disruptionByRoute(routeId: routeId))
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            return cell
        }
        if indexPath.section == 1 {     // Section 1 (Stops)
            let cell = tableView.dequeueReusableCell(withIdentifier: "routeStops", for: indexPath) as! RoutesStopTableViewCell
            let cellDepartureTime = departsData[indexPath.row].estimatedDepartureUTC ?? departsData[indexPath.row].scheduledDepartureUTC
            
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
            var flagText: String = ""
            // Manage Flag
            if (departsData[indexPath.row].flags?.contains("RR"))!{
                flagText += "* Reservations Required "
            }
            if (departsData[indexPath.row].flags?.contains("GC"))!{
                flagText += "* Guaranteed Connection "
            }
            if (departsData[indexPath.row].flags?.contains("DOO"))!{
                flagText += "* Drop-off Only "
            }
            if (departsData[indexPath.row].flags?.contains("PUO"))!{
                flagText += "* Pick-up Only "
            }
            if ((departsData[indexPath.row].flags?.contains("MO"))! || (departsData[indexPath.row].flags?.contains("TU"))! || (departsData[indexPath.row].flags?.contains("WE"))! || (departsData[indexPath.row].flags?.contains("TH"))! || (departsData[indexPath.row].flags?.contains("FR"))!){
                flagText += "*"
                if (departsData[indexPath.row].flags?.contains("MO"))!{
                    flagText += " Mondays"
                    if ((departsData[indexPath.row].flags?.contains("TU"))! || (departsData[indexPath.row].flags?.contains("WE"))! || (departsData[indexPath.row].flags?.contains("TH"))! || (departsData[indexPath.row].flags?.contains("FR"))!){
                        flagText += ","
                    }
                }
                if (departsData[indexPath.row].flags?.contains("TU"))!{
                    flagText += " Tuesdays"
                    if ((departsData[indexPath.row].flags?.contains("WE"))! || (departsData[indexPath.row].flags?.contains("TH"))! || (departsData[indexPath.row].flags?.contains("FR"))!){
                        flagText += ","
                    }
                }
                if (departsData[indexPath.row].flags?.contains("WE"))!{
                    flagText += " Wednesday"
                    if ((departsData[indexPath.row].flags?.contains("TH"))! || (departsData[indexPath.row].flags?.contains("FR"))!){
                        flagText += ","
                    }
                }
                if (departsData[indexPath.row].flags?.contains("TH"))!{
                    flagText += " Thursday"
                    if (departsData[indexPath.row].flags?.contains("FR"))!{
                        flagText += ","
                    }
                }
                if (departsData[indexPath.row].flags?.contains("FR"))!{
                    flagText += " Friday"
                }
                flagText += " Only "
                
            }
            if (departsData[indexPath.row].flags?.contains("SS"))!{
                flagText += "* SchoolDay Only "
            }
            cell.routeAdditionInfoLabel.text = flagText
            cell.routeStopTimeLabel.text = Iso8601toString(iso8601Date: cellDepartureTime!, withTime: true, withDate: false)
            cell.routeStatusLabel.text = "Scheduled"
            cell.routeStatusLabel.textColor = UIColor.gray
            if departsData[indexPath.row].estimatedDepartureUTC != nil {
                let minutes = Iso8601toStatus(iso8601DateSchedule: departsData[indexPath.row].scheduledDepartureUTC!, iso8601DateActual: departsData[indexPath.row].estimatedDepartureUTC!)
                if minutes > 1 {
                    cell.routeStatusLabel.text = "Late \(minutes) mins"
                    cell.routeStatusLabel.textColor = UIColor.red
                } else if minutes == 1{
                    cell.routeStatusLabel.text = "Late 1 min"
                    cell.routeStatusLabel.textColor = UIColor.orange
                } else if minutes == 0 {
                    cell.routeStatusLabel.text = "On Time"
                    cell.routeStatusLabel.textColor = UIColor.green
                } else if minutes == -1{
                    cell.routeStatusLabel.text = "Early 1 min"
                    cell.routeStatusLabel.textColor = UIColor.green
                } else if minutes < -1 {
                    cell.routeStatusLabel.text = "Early \((minutes * -1)) mins"
                    cell.routeStatusLabel.textColor = UIColor.brown
                }
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "doesNotExist", for: indexPath) as! RoutesStopTableViewCell
        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
        let stopsFetchedRequest: NSFetchRequest<FavStop> = FavStop.fetchRequest()
        let stopSortDescriptors = NSSortDescriptor(key: "stopId", ascending: true)
        stopsFetchedRequest.sortDescriptors = [stopSortDescriptors]
        stopFetchedResultsController = NSFetchedResultsController(fetchRequest: stopsFetchedRequest, managedObjectContext: CoreDataStack().managedContext, sectionNameKeyPath: nil, cacheName: nil)
        stopFetchedResultsController.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle:
            UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
        return
    }
    
    // MARK: - Functions for MapView
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let myLatitude = stopLatitude ?? locations[0].coordinate.latitude
        let myLongtitude = stopLongitude ?? locations[0].coordinate.longitude
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongtitude), span: currentLocationSpan)
        self.routeMapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        displayMessage(title: "Oops~", message: "Unable to access your location, please make sure you have correct setting")
        print("Unable to access location:\(error)")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is customPointAnnotation){
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "stops")
        if annotationView == nil{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "stops")
        }
        let customAnnotation = annotation as! customPointAnnotation
        if customAnnotation.routeType == 0 {
            annotationView?.image = UIImage(named: "trainStation")
        } else if customAnnotation.routeType == 1 {
            annotationView?.image = UIImage(named: "tramStop")
        } else if customAnnotation.routeType == 2 {
            annotationView?.image = UIImage(named: "busStop")
        } else if customAnnotation.routeType == 3 {
            annotationView?.image = UIImage(named: "vlineStation")
        } else if customAnnotation.routeType == 4 {
            annotationView?.image = UIImage(named: "nightbusStop")
        }
        annotationView?.canShowCallout = true
        let button = UIButton(type: .infoLight)
        annotationView?.rightCalloutAccessoryView = button
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation
        
        guard annotation?.title != nil, annotation?.subtitle != nil else {
            return
        }
        if annotation?.title != "My Location" {
            var subtitleTextElement: [String] = []
            let subtitleText = String(((annotation?.subtitle)!)!).components(separatedBy: ",")
            for eachSubtitle in subtitleText{
                let elements = eachSubtitle.components(separatedBy: ":")
                for each in elements{
                    subtitleTextElement.append(each)
                }
                senderStopId = Int(subtitleTextElement[1])!
                if senderStopId == Int(subtitleTextElement[1]) {
                    break
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
         self.performSegue(withIdentifier: "showStopFromPatternMap", sender: nil)
    }
}
extension RouteDetailsViewController: NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    }
}
