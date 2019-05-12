//
//  SelectStopOnMapViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 3/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

struct findStopByGPSRoot: Codable {
    var stops: StopGeosearch?
//    var disruptions: disruptions?
    var status: findStopByGPSstatus?
    
    private enum CodingKeys: String, CodingKey{
        case stops
        case status
    }
}

struct StopGeosearch: Codable{
    var stopDistance: Double?
    var stopSuburb: String?
    var stopName: String?
    var stopId: Int?
    var routeType: Int?
    var stopLatitude: Double?
    var stopLongitude: Double?
    var stopSequence: Int?
    
    private enum CodingKeys: String, CodingKey{
        case stopDistance = "stop_distance"
        case stopSuburb = "stop_suburb"
        case stopName = "stop_name"
        case stopId = "stop_id"
        case routeType = "route_type"
        case stopLatitude = "stop_latitude"
        case stopLongitude = "stop_longitude"
        case stopSequence = "stop_sequence"
    }
}

struct findStopByGPSstatus: Codable {
    var version: String?
    var health: Int?
    private enum CodingKeys: String, CodingKey{
        case version
        case health
    }
}

final class BusStopAnnotation: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String?){
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
//        添加车站图标
        super.init()
    }
}

class SelectStopOnMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let hardcodedURL:String = "https://timetableapi.ptv.vic.gov.au"
    let hardcodedDevID:String = "3001122"
    let hardcodedDevKey:String = "3c74a383-c69a-4e8d-b2f8-2e4c598b50b2"
    
    @IBOutlet weak var mainMapView: MKMapView!

    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard locationManager.location != nil else {
                return
            }
        }
        
        self.mainMapView = MKMapView(frame:self.view.frame)
        self.view.addSubview(self.mainMapView)
        mainMapView.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        //大头针对象 - 添加车站用
        let claytonStation = MKPointAnnotation()    //创建一个大头针对象
        claytonStation.coordinate = CLLocation(latitude: -37.9251671,longitude: 145.120682).coordinate  //设置大头针的显示位置
        claytonStation.title = "Clayton Station"    //设置点击大头针之后显示的标题
        claytonStation.subtitle = "Clayton"    //设置点击大头针之后显示的描述
        self.mainMapView.addAnnotation(claytonStation)  //添加大头针
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK:- CLLocationManager Delegates
    //创建一个MKCoordinateSpan对象，设置地图的范围（越小越精确）
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.012, longitudeDelta: 0.012)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: currentLocationSpan)
        self.mainMapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    fileprivate func extractedFunc(_ request: String) -> String {
        let signature: String = request.hmac(algorithm: CryptoAlgorithm.SHA1, key: hardcodedDevKey)
        let requestAddress: String = hardcodedURL+request+"&signature="+signature
        
        return requestAddress
    }
    func findStopByMap(latitude: Double, longitude: Double) -> String {
        let request: String = "/v3/stops/location/"+String(latitude)+","+String(longitude)+"?max_results=100&devid="+hardcodedDevID
        return extractedFunc(request)
    }
    
    func findStopWithZoom(latitude: Double, longitude: Double, stopQuantity: Int, distance: Double) -> String{
        let request: String = "/v3/stops/location/"+String(latitude)+","+String(longitude)+"?max_results="+String(stopQuantity)+"&max_distance"+String(distance)+"&devid="+hardcodedDevID
        return extractedFunc(request)
    }
    
//    func StopsAnnotationView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if let BusStopAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as?
//            MKMarkerAnnotationView{
//            BusStopAnnotation.animatesWhenAdded = true
//            BusStopAnnotation.titleVisibility = .adaptive
//            BusStopAnnotation.subtitleVisibility = .adaptive
//
//            return BusStopAnnotation
//        }
//    }
}
