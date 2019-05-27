//
//  DatabaseProtocol.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 28/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import Foundation

protocol DatabaseListener: AnyObject {
    func onRouteListChange(routeList: [FavRoute])
    func onStopListChange(stopList: [FavStop])
}

protocol DatabaseProtocol: AnyObject{
    func addStop(stopData: FavStopData) -> FavStop
    func addRoute(routeData: FavRouteData) -> FavRoute
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
