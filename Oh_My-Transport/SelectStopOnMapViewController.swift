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

class SelectStopOnMapViewController: UIViewController {

    var mainMapView: MKMapView!
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    //定位管理器
    let locationManager:CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager.requestWhenInUseAuthorization()
        
        
        //使用代码创建
        self.mainMapView = MKMapView(frame:self.view.frame)
        self.view.addSubview(self.mainMapView)
        
        //地图类型设置 - 标准地图
        self.mainMapView.mapType = MKMapType.standard
        
        //创建一个MKCoordinateSpan对象，设置地图的范围（越小越精确）
        let latDelta = 0.05
        let longDelta = 0.05
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        //定义地图区域和中心
        //使用自定义位置
        let center:CLLocation = CLLocation(latitude: -37.814, longitude: 144.96332)
        
        //使用当前位置
//        let center:CLLocation = locationManager.location!.coordinate
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard let currentLocation = locManager.location else {
                return
            }
            let center:CLLocation = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        }
        let currentRegion:MKCoordinateRegion = MKCoordinateRegion(center: center.coordinate, span: currentLocationSpan)
        
        //设置显示区域
        self.mainMapView.setRegion(currentRegion, animated: true)
        
        //创建一个大头针对象
//        let objectAnnotation = MKPointAnnotation()
        //设置大头针的显示位置
//        objectAnnotation.coordinate = CLLocation(latitude: 32.029171,longitude: 118.788231).coordinate
        //设置点击大头针之后显示的标题
//        objectAnnotation.title = "南京夫子庙"
        //设置点击大头针之后显示的描述
//        objectAnnotation.subtitle = "南京市秦淮区秦淮河北岸中华路"
        //添加大头针
//        self.mainMapView.addAnnotation(objectAnnotation)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
