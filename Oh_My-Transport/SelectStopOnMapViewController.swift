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

class SelectStopOnMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    var mainMapView: MKMapView!
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    //定位管理器
    var locationManager:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager.requestWhenInUseAuthorization()

        //使用代码创建
        self.mainMapView = MKMapView(frame:self.view.frame)
        self.view.addSubview(self.mainMapView)
        
        //地图类型设置 - 标准地图
        self.mainMapView.mapType = MKMapType.standard
        
        //创建一个MKCoordinateSpan对象，设置地图的范围（越小越精确）
        let latDelta = 0.012
        let longDelta = 0.012
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        mainMapView.showsUserLocation = true
        mainMapView.showsCompass = true
        mainMapView.showsScale = true

        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard locManager.location != nil else {
                return
            }
        }
        
        //定义地图区域和中心
        //使用自定义位置
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        //重新定向到用户位置
        let userLocation = locationManager.location?.coordinate
        let currentRegion = MKCoordinateRegion(center: userLocation!, span: currentLocationSpan)
        self.mainMapView.setRegion(currentRegion, animated: true)
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        
        
        //大头针对象
        let claytonStation = MKPointAnnotation()    //创建一个大头针对象
        claytonStation.coordinate = CLLocation(latitude: -37.9251671,longitude: 145.120682).coordinate  //设置大头针的显示位置
        claytonStation.title = "Clayton Station"    //设置点击大头针之后显示的标题
        claytonStation.subtitle = "Clayton"    //设置点击大头针之后显示的描述
        self.mainMapView.addAnnotation(claytonStation)  //添加大头针
        
        let westallStation = MKPointAnnotation()    //创建一个大头针对象
        westallStation.coordinate = CLLocation(latitude: -37.93849,longitude: 145.13884).coordinate  //设置大头针的显示位置
        westallStation.title = "Westall Station"    //设置点击大头针之后显示的标题
        westallStation.subtitle = "Clayton South"    //设置点击大头针之后显示的描述
        self.mainMapView.addAnnotation(westallStation)  //添加大头针
        
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        self.mainMapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to access your current location")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
