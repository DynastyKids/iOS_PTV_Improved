//
//  MyKiOutletViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 25/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MyKiOutletViewController: UIViewController, CLLocationManagerDelegate {

    var outlet: ResultOutlet?
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    @IBOutlet weak var outletMapView: MKMapView!
    @IBOutlet weak var navigateButton: UIButton!
    
    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var businessAddressLabel: UILabel!
    @IBOutlet weak var businessAddressButton: UIButton!     // Preserved for URI Jump to Googlemap / Apple Map
    @IBOutlet weak var businessDistanceLabel: UILabel!
    @IBOutlet weak var businessHoursLabel: UILabel!         // If no business hours information, it will be empty
    @IBOutlet weak var businessMondayLabel: UILabel!
    @IBOutlet weak var businessTuesdayLabel: UILabel!
    @IBOutlet weak var businessWednesdayLabel: UILabel!
    @IBOutlet weak var businessThursdayLabel: UILabel!
    @IBOutlet weak var businessFridayLabel: UILabel!
    @IBOutlet weak var businessSaturdayLabel: UILabel!
    @IBOutlet weak var businessSundayLabel: UILabel!
    
    @IBOutlet weak var outletNotesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initalize the mapKit
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard locationManager.location != nil else {
                return
            }
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        // Showing business informaiton
        businessNameLabel.text = outlet?.outeletBusiness
        if outlet?.outletName != nil{
            businessAddressLabel.text = "\((outlet?.outletName) ?? ""), \((outlet?.outletSuburb) ?? ""), VIC \((outlet?.outletPostcode)!)"
        }
//        businessAddressButton
        let userlocation = CLLocation(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!)
        let distance = userlocation.distance(from: CLLocation(latitude: outlet!.outletLatitude!, longitude: outlet!.outletLongitude!))
        if Double(distance) >= 1000{
            businessDistanceLabel.text = "Distance: \(String(format:"%.2f",Double(distance/1000))) km"
        } else{
            businessDistanceLabel.text = "Distance: \(Int(distance)) m"
        }
        if outlet?.outletNotes != nil {
            outletNotesLabel.text = outlet?.outletNotes!
        } else{
            outletNotesLabel.text = ""
        }
        if (outlet?.outletBusinessHourMon == nil && outlet?.outletBusinessHourTue == nil && outlet?.outletBusinessHourWed == nil && outlet?.outletBusinessHourThur == nil && outlet?.outletBusinessHourFri == nil && outlet?.outletBusinessHourSat == nil && outlet?.outletBusinessHourSun == nil ) {
            businessHoursLabel.text = ""
            businessMondayLabel.text = ""
            businessTuesdayLabel.text = ""
            businessWednesdayLabel.text = ""
            businessThursdayLabel.text = ""
            businessFridayLabel.text = ""
            businessSaturdayLabel.text = ""
            businessSundayLabel.text = ""
        } else {
            if outlet?.outletBusinessHourMon != nil {
                businessMondayLabel.text = "Monday :\((outlet?.outletBusinessHourMon!)!)"
            } else {
                businessMondayLabel.text = "Unknown"
            }
            if outlet?.outletBusinessHourTue != nil {
                businessTuesdayLabel.text = "Tuesday: \((outlet?.outletBusinessHourTue!)!)"
            } else{
                businessTuesdayLabel.text = "Unknown"
            }
            if outlet?.outletBusinessHourWed != nil {
                businessWednesdayLabel.text = "Wednesday: \((outlet?.outletBusinessHourWed!)!)"
            } else{
                businessWednesdayLabel.text = "Unknown"
            }
            if outlet?.outletBusinessHourThur != nil {
                businessThursdayLabel.text = "Thursday: \((outlet?.outletBusinessHourThur!)!)"
            } else{
                businessThursdayLabel.text = "Unknown"
            }
            if outlet?.outletBusinessHourFri != nil {
                businessFridayLabel.text = "Friday: \((outlet?.outletBusinessHourFri!)!)"
            } else{
                businessFridayLabel.text = "Unknown"
            }
            if outlet?.outletBusinessHourSat != nil {
                businessSaturdayLabel.text = "Saturday: \((outlet?.outletBusinessHourSat!)!)"
            } else{
                businessSaturdayLabel.text = "Unknown"
            }
            if outlet?.outletBusinessHourSun != nil{
                businessSundayLabel.text = "Sunday: \((outlet?.outletBusinessHourSun!)!)"
            } else{
                businessSundayLabel.text = "Unknown"
            }
        }
        
        // Initalize mapkit
        outletMapView.showsUserLocation = true
        
        if(outlet?.outletLatitude != nil && outlet?.outletLongitude != nil){
            let outletAnnotation = MKPointAnnotation()
            outletAnnotation.coordinate = CLLocation(latitude: (outlet?.outletLatitude)!,longitude: (outlet?.outletLongitude)!).coordinate
            outletAnnotation.title = outlet?.outeletBusiness
            outletAnnotation.subtitle = outlet?.outletSuburb
            self.outletMapView.addAnnotation(outletAnnotation)
            navigateButton.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: outlet?.outletLatitude ?? locations[0].coordinate.latitude, longitude: outlet?.outletLongitude ?? locations[0].coordinate.longitude), span: currentLocationSpan)
        self.outletMapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func navigateMeButton(_ sender: Any) {    // Reference: https://www.youtube.com/watch?v=INfCmCxLC0o
        let locationDistance = CLLocationCoordinate2DMake(CLLocationDegrees((outlet?.outletLatitude)!), CLLocationDegrees((outlet?.outletLongitude)!))
        let regionSpan = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (outlet?.outletLatitude)!, longitude: (outlet?.outletLongitude)!), latitudinalMeters: CLLocationDistance(1000), longitudinalMeters: CLLocationDistance(1000))
        
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        let placeMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (outlet?.outletLatitude)!, longitude: (outlet?.outletLongitude)!))
        let mapItem = MKMapItem(placemark: placeMark)
        
        mapItem.name = outlet?.outeletBusiness
        mapItem.openInMaps(launchOptions: options)
    }
    
}
