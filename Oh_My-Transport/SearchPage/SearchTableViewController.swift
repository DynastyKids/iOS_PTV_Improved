//
//  SearchTableViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 24/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class SearchTableViewController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    
    var indicator = UIActivityIndicatorView()
    var searchRoute: [ResultRoute] = []
    var searchOutlets: [ResultOutlet] = []
    var searchStops: [ResultStop] = []
    
    // MARK: - Location Data Property
    let locationManager = CLLocationManager()
    var nslock = NSLock()
    var currentLocation:CLLocation!
    
    // MARK: - Core Data Property
    var stopFetchedResultsController: NSFetchedResultsController<FavStop>!
    var routeFetchedResultsController: NSFetchedResultsController<FavRoute>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get user location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // MARK: - Search Bar creation
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Type a stop / station / route to start"
        searchController.searchBar.keyboardType = UIKeyboardType.asciiCapable
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
        indicator.style = UIActivityIndicatorView.Style.gray
        indicator.center = self.tableView.center
        self.view.addSubview(indicator)
    }
    
    // MARK: - Search Bar source
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, searchText.count > 0 else {
            displayMessage(title: "Oops!", message: "Search terms cannot be empty")
            return;
        }
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.white
        var replacedText = searchText.replacingOccurrences(of: "%", with: "%25")    // Replacing chars in string
        replacedText = replacedText.replacingOccurrences(of: " ", with: "%20")
        replacedText = replacedText.replacingOccurrences(of: "/", with: "%2f")
        for each in replacedText.data(using: .ascii, allowLossyConversion: true)!{ // Converting string to ascii
            // Reference: https://stackoverflow.com/questions/29835242/whats-the-simplest-way-to-convert-from-a-single-character-string-to-an-ascii-va
            if (each<37 || (each>37&&each<48) || (each>58&&each<64) || (each>90&&each<97) || each>122){
                displayMessage(title: "Oops!", message: "There has invalid characters in your searchbox")
                indicator.stopAnimating()
                return;
            }
        }
        self.searchStops.removeAll()    // Remove all existing data in array
        self.searchRoute.removeAll()
        self.searchOutlets.removeAll()
        let requestUrl: String = showSearchResults(searchTerm: replacedText, latitude: locationManager.location?.coordinate.latitude ?? -37.8171571, longitude: locationManager.location?.coordinate.longitude ?? 144.9663325)
        
        _ = URLSession.shared.dataTask(with: URL(string: requestUrl)!){ (data, response, error) in
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.indicator.hidesWhenStopped = true
            }
            if error != nil {
                print("Error:\(String(describing: error))")
                return
            }
            do{
                let results = try JSONDecoder().decode(SearchResult.self, from: data!)
                if results.message != nil {     // Error message response
                    self.displayMessage(title: "Oops!", message: "There has invalid characters in your searchbox")
                    return;
                }
                if results.stops?.count ?? 0 > 0 {   // Fill stops array when > 0
                    self.searchStops = results.stops!
                }
                if results.routes?.count ?? 0 > 0 {  // Fill routes when array >0
                    for each in results.routes!{
                        if ((each.routeType == 2 && (each.routeNumber?.contains("combined") == true)) || each.routeType == 3) {
                            continue    // exclude repeat results
                        }
                        self.searchRoute.append(each)
                    }
                }
                if results.outlets?.count ?? 0 > 0 { // Fill nearest myki Outlets
                    self.searchOutlets = results.outlets!
                }
                
                if results.stops?.count ?? 0 > 0 {   // Bubble sort for route, ordered by Metro - Tram - Buses - Night Bus
                    for sequence in 0 ..< self.searchRoute.count {
                        for eachRoutes in 0 ..< ((self.searchRoute.count)-1-sequence) {
                            if (self.searchRoute[eachRoutes].routeType)! > (self.searchRoute[eachRoutes+1].routeType)! {
                                let temp = self.searchRoute[eachRoutes+1]
                                self.searchRoute[eachRoutes+1] = self.searchRoute[eachRoutes]
                                self.searchRoute[eachRoutes] = temp
                            }
                        }
                    }
                }
                if (results.stops?.count)!>0{       // Bubble sort for stop distance
                    for sequence in 0 ..< self.searchStops.count {
                        for eachStops in 0 ..< self.searchStops.count-1-sequence{
                            let userlocation = CLLocation(latitude: self.locationManager.location?.coordinate.latitude ?? -37.8171571, longitude: self.locationManager.location?.coordinate.longitude ?? 144.9663325)
                            let distance0 = userlocation.distance(from: CLLocation(latitude: self.searchStops[eachStops].stopLatitude!, longitude: self.searchStops[eachStops].stopLongitude!))
                            let distance1 = userlocation.distance(from: CLLocation(latitude: self.searchStops[eachStops+1].stopLatitude!, longitude: self.searchStops[eachStops+1].stopLongitude!))
                            if (distance0 > distance1){
                                let temp = self.searchStops[eachStops+1]
                                self.searchStops[eachStops+1] = self.searchStops[eachStops]
                                self.searchStops[eachStops] = temp
                            }
                        }
                    }
                }
                if (results.outlets?.count)! > 0{       // Bubble sort for outlet distance
                    for sequence in 0 ..< self.searchOutlets.count{
                        for eachOutlet in 0 ..< self.searchOutlets.count-1-sequence{
                            let userlocation = CLLocation(latitude: self.locationManager.location?.coordinate.latitude ?? -37.8171571, longitude: self.locationManager.location?.coordinate.longitude ?? 144.9663325)
                            let distance0 = userlocation.distance(from: CLLocation(latitude: self.searchOutlets[eachOutlet].outletLatitude!, longitude: self.searchOutlets[eachOutlet].outletLongitude!))
                            let distance1 = userlocation.distance(from: CLLocation(latitude: self.searchOutlets[eachOutlet+1].outletLatitude!, longitude: self.searchOutlets[eachOutlet+1].outletLongitude!))
                            if (distance0 > distance1){
                                let temp = self.searchOutlets[eachOutlet+1]
                                self.searchOutlets[eachOutlet+1] = self.searchOutlets[eachOutlet]
                                self.searchOutlets[eachOutlet] = temp
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch{
                print("Search Result Fetch Error:\(error)")
            }
        }.resume()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return searchRoute.count
        }
        if section == 1{
            return searchStops.count
        }
        if section == 2{
            return searchOutlets.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { // Inflating with route results
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchRoutes", for: indexPath) as! SearchRouteTableViewCell
            cell.routeInfoLabel.text = searchRoute[indexPath.row].routeName
            cell.routeNameLabel.backgroundColor = changeColorByRouteType(routeType: searchRoute[indexPath.row].routeType!)
            if (searchRoute[indexPath.row].routeType == 0 || searchRoute[indexPath.row].routeType == 3 || searchRoute[indexPath.row].routeNumber == nil) {
                let str: String = self.searchRoute[indexPath.row].routeGtfsId!
                let start = str.index(str.startIndex, offsetBy: 2)
                cell.routeNameLabel.text = String(str[start...])
            }else{
                cell.routeNameLabel.text = searchRoute[indexPath.row].routeNumber
            }
            switch searchRoute[indexPath.row].routeType{    //Showing icons
            case 0:
                cell.routeTypeIcon.image = UIImage(named: "trainIcon_PTVColour")
            case 1:
                cell.routeTypeIcon.image = UIImage(named: "tramIcon_PTVColour")
            case 2:
                cell.routeTypeIcon.image = UIImage(named: "busIcon_PTVColour")
            case 3:
                cell.routeTypeIcon.image = UIImage(named: "vlineIcon_PTVColour")
            case 4:
                cell.routeTypeIcon.image = UIImage(named: "nightbusIcon_PTVColour")
            default:
                break
            }
            return cell
        }
        if indexPath.section == 1{  // Inflating with stop Results
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchStops", for: indexPath) as! SearchStopsTableViewCell
            if searchStops[indexPath.row].routeType! == 4{
                cell.stopNameLabel.text = "\(searchStops[indexPath.row].stopName!) (Night Bus)"
            } else {
                cell.stopNameLabel.text = searchStops[indexPath.row].stopName
            }
            cell.stopNameLabel.backgroundColor = changeColorByRouteType(routeType: searchStops[indexPath.row].routeType!)
            cell.stopSuburbLabel.text = searchStops[indexPath.row].stopSuburb
            if searchStops[indexPath.row].stopDistance != nil{
                if Double(searchStops[indexPath.row].stopDistance!) >= 1000 {
                    cell.stopDistanceLabel.text = "\(String(format:"%.2f",Double(searchStops[indexPath.row].stopDistance!/1000)))km away"
                }
                cell.stopDistanceLabel.text = "\(Int(searchStops[indexPath.row].stopDistance!))m away"
            } else {    // Using provided location to calculate
                if (searchStops[indexPath.row].stopLatitude != nil && searchStops[indexPath.row].stopLongitude != nil){
                    let userlocation = CLLocation(latitude: locationManager.location?.coordinate.latitude ?? -37.8171571, longitude: locationManager.location?.coordinate.longitude ?? 144.9663325)
                    let distance = userlocation.distance(from: CLLocation(latitude: searchStops[indexPath.row].stopLatitude!, longitude: searchStops[indexPath.row].stopLongitude!))
                    if Double(distance) >= 1000{
                        cell.stopDistanceLabel.text = "\(String(format:"%.2f",Double(distance/1000)))km away"
                    } else{
                        cell.stopDistanceLabel.text = "\(Int(distance))m away"
                    }
                }else {
                    cell.stopDistanceLabel.text = ""
                }
            }
            switch searchStops[indexPath.row].routeType{    // Showing icons
            case 0:
                cell.stopIcon.image = UIImage(named: "trainIcon_PTVColour")
            case 1:
                cell.stopIcon.image = UIImage(named: "tramIcon_PTVColour")
            case 2:
                cell.stopIcon.image = UIImage(named: "busIcon_PTVColour")
            case 3:
                cell.stopIcon.image = UIImage(named: "vlineIcon_PTVColour")
            case 4:
                cell.stopIcon.image = UIImage(named: "nightbusIcon_PTVColour")
            default:
                break
            }
            return cell
        }
        if indexPath.section == 2 { //Inflating with Myki Outlets
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchOutlets", for: indexPath) as! SearchOutletsTableViewCell
            cell.businessNameLabel.text = searchOutlets[indexPath.row].outeletBusiness
            cell.businessAddressLabel.text = "\(searchOutlets[indexPath.row].outletName!), \(searchOutlets[indexPath.row].outletSuburb!)"
            cell.businessSuburbLabel.text = searchOutlets[indexPath.row].outletSuburb
            if (searchOutlets[indexPath.row].outletLatitude != nil && searchOutlets[indexPath.row].outletLongitude != nil){
                let userlocation = CLLocation(latitude: locationManager.location?.coordinate.latitude ?? -37.8171571, longitude: locationManager.location?.coordinate.longitude ?? 144.9663325)
                let distance = userlocation.distance(from: CLLocation(latitude: searchOutlets[indexPath.row].outletLatitude!, longitude: searchOutlets[indexPath.row].outletLongitude!))
                if Double(distance) >= 1000{
                    cell.businessDistanceLabel.text = "\(String(format:"%.2f",Double(distance/1000)))km away"
                } else{
                    cell.businessDistanceLabel.text = "\(Int(distance))m away"
                }
            } else {
                cell.businessDistanceLabel.text = ""
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Nothing", for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionName: String
        switch section {
        case 0:
            sectionName = NSLocalizedString("Routes:", comment: "Routes Result")
            if searchRoute.count == 0 {
                sectionName = NSLocalizedString("", comment: "")
            }
        case 1:
            sectionName = NSLocalizedString("Stops:", comment: "Stops Result")
            if searchStops.count == 0 {
                sectionName = NSLocalizedString("", comment: "")
            }
        case 2:
            sectionName = NSLocalizedString("MyKi Outlets:", comment: "MyKi Outlet Result")
            if searchOutlets.count == 0{
                sectionName = NSLocalizedString("", comment: "")
            }
        default:
            sectionName = ""
        }
        return sectionName
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination. Pass the selected object to the new view controller.
        if segue.identifier == "searchToRoute"{
            let page2:DirectionsViewController = segue.destination as! DirectionsViewController
            page2.routeId = searchRoute[(tableView.indexPathForSelectedRow?.row)!].routeId!
            page2.routeType = searchRoute[(tableView.indexPathForSelectedRow?.row)!].routeType!
            page2.managedContext = routeFetchedResultsController.managedObjectContext
        }
        if segue.identifier == "searchToStop" {
            let page2:StopPageTableViewController = segue.destination as! StopPageTableViewController
            page2.stopId = searchStops[(tableView.indexPathForSelectedRow?.row)!].stopId!
            page2.routeType = searchStops[((tableView.indexPathForSelectedRow?.row)!)].routeType!
            page2.managedContext = stopFetchedResultsController.managedObjectContext
        }
        if segue.identifier == "showOutlet"{
            let page2:MyKiOutletViewController = segue.destination as! MyKiOutletViewController
            page2.outlet = searchOutlets[(tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
        let stopsFetchedRequest: NSFetchRequest<FavStop> = FavStop.fetchRequest()
        let stopSortDescriptors = NSSortDescriptor(key: "stopId", ascending: true)
        stopsFetchedRequest.sortDescriptors = [stopSortDescriptors]
        stopFetchedResultsController = NSFetchedResultsController(fetchRequest: stopsFetchedRequest, managedObjectContext: CoreDataStack().managedContext, sectionNameKeyPath: nil, cacheName: nil)
        stopFetchedResultsController.delegate = self
        
        let routesFetchedRequest: NSFetchRequest<FavRoute> = FavRoute.fetchRequest()
        let routeSortDescriptoprs = NSSortDescriptor(key: "routeId", ascending: true)
        routesFetchedRequest.sortDescriptors = [routeSortDescriptoprs]
        routeFetchedResultsController = NSFetchedResultsController(fetchRequest: routesFetchedRequest, managedObjectContext: CoreDataStack().managedContext, sectionNameKeyPath: nil, cacheName: nil)
        routeFetchedResultsController.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle:
            UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
        return
    }
}
extension SearchTableViewController: NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    }
}
