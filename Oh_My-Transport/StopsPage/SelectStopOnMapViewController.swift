//
//  SelectStopOnMapViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 3/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class SelectStopOnMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mainMapView: MKMapView!

    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var mapCenterLatitude: Float = 0
    var mapCenterLongitude: Float = 0
    var latitudeDelta: Float = 0
    var longitudeDelta: Float = 0
    var resultStops: [StopGeosearch] = []
    
    var senderStopId: Int = 0
    var senderRouteType: Int = 0
    var lastSelectStopId: Int = 0
    
    var stopsAnnotationView: MKPinAnnotationView?
    
    var stopFetchedResultsController: NSFetchedResultsController<FavStop>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard locationManager.location != nil else {
                return
            }
        }
        
        self.view.addSubview(self.mainMapView)
        mainMapView.showsUserLocation = true
        mainMapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        mapCenterLatitude = Float((locationManager.location?.coordinate.latitude)!)
        mapCenterLongitude = Float((locationManager.location?.coordinate.longitude)!)
        updateSearchResults()
    }
    
    //MARK: - CLLocationManager Delegates
    //Create a MKCoordinateSpan target for setting scan range
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: currentLocationSpan)
        self.mainMapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()     // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("latitudeDelta:%f,,longitudeDelta:%f",mapView.region.span.latitudeDelta,mapView.region.span.longitudeDelta)
        print("Latitude:\(mapView.centerCoordinate.latitude), Longitude:\(mapView.centerCoordinate.longitude)")
        mapCenterLatitude = Float(mapView.centerCoordinate.latitude)
        mapCenterLongitude = Float(mapView.centerCoordinate.longitude)
        print(mapView.region.span)
        updateSearchResults()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotation = view.annotation
        guard annotation?.title != nil, annotation?.subtitle != nil else {
            return
        }
        var subtitleTextElement: [String] = []
        let subtitleText = String(((annotation?.subtitle)!)!).components(separatedBy: ",")
        for eachSubtitle in subtitleText{
            let elements = eachSubtitle.components(separatedBy: ":")
            for each in elements{
                subtitleTextElement.append(each)
            }
            senderStopId = Int(subtitleTextElement[1])!
            for each in resultStops{
                if senderStopId == each.stopId{
                    print("Routetype:\(each.routeType!),\(senderRouteType)")
                    senderRouteType = each.routeType!
                }
            }
            print("senderStopId:\(senderStopId),lastSelectId:\(lastSelectStopId)")
            if senderStopId == Int(subtitleTextElement[1]) {
                self.performSegue(withIdentifier: "showStopsFromMap", sender: nil)
                break
            }
        }
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
            annotationView?.image = UIImage(named: "busStop")
        }
        
        return annotationView
    }
    
    func updateSearchResults(){
        mainMapView.removeAnnotations(mainMapView.annotations)
        let url = URL(string: nearByStopsOnSelect(latitude: Double(mapCenterLatitude), longtitude: Double(mapCenterLongitude)))
        _ = URLSession.shared.dataTask(with: url!){ (data, response, error) in
            if error != nil {
                print("Nearby Stops fetch failed:\(error!)")
                return
            }
            do{
                let mapStop = try JSONDecoder().decode(StopResponseByLocation.self, from: data!)
                guard (mapStop.stops?.count)!>0 else{
                    return
                }
                self.resultStops = mapStop.stops!
                DispatchQueue.main.async {
                    for each in self.resultStops{           // Setting up new annotation
                        let newStop = customPointAnnotation()
                        newStop.coordinate = CLLocation(latitude: each.stopLatitude!,longitude: each.stopLongitude!).coordinate
                        newStop.title = each.stopName
                        newStop.subtitle = "Stop Id:\(each.stopId!), Suburb:\(each.stopSuburb!)"
                        newStop.routeType = each.routeType
                        self.mainMapView.addAnnotation(newStop)
                    }
                }
            } catch {
                print("Error:\(error)")
            }
            
            }.resume()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStopsFromMap" {
            let page2:StopPageTableViewController = segue.destination as! StopPageTableViewController
            page2.routeType = senderRouteType
            page2.stopId = senderStopId
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let stopsFetchedRequest: NSFetchRequest<FavStop> = FavStop.fetchRequest()
        let stopSortDescriptors = NSSortDescriptor(key: "stopId", ascending: true)
        stopsFetchedRequest.sortDescriptors = [stopSortDescriptors]
        stopFetchedResultsController = NSFetchedResultsController(fetchRequest: stopsFetchedRequest, managedObjectContext: CoreDataStack().managedContext, sectionNameKeyPath: nil, cacheName: nil)
        stopFetchedResultsController.delegate = self
    }
}

extension SelectStopOnMapViewController: NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    }
}

class customPointAnnotation: MKPointAnnotation{
    var routeType:Int?
}
