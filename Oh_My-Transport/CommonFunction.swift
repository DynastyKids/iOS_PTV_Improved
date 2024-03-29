//
//  CommonFunction.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 21/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

private let HARDCODEDURL: String = "https://timetableapi.ptv.vic.gov.au"

private var PrimaryDevId: String = "3001122"
private var PrimaryDevKey: String = "3c74a383-c69a-4e8d-b2f8-2e4c598b50b2"

// Countdown Conversion
public func Iso8601Countdown(iso8601Date: String, status: Bool?) -> String {
    if iso8601Date == "nil"{
        fatalError()
    }
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    let date:Date = formatter.date(from: iso8601Date)!
    let differences = Calendar.current.dateComponents([.minute], from: NSDate.init(timeIntervalSinceNow: 0) as Date, to: date)
    let minutes = differences.minute ?? 0
    
    if minutes < -10 {
        let mydateformat = DateFormatter()
        mydateformat.dateFormat = "hh:mm a"
        return mydateformat.string(from: date)
    }
    if minutes < -1{
        return "\(minutes*(-1))m ago"
    }
    if minutes == -1{
        return "1m ago"
    }
    if minutes == 0{
        return "Now"
    }
    if minutes == 1{
        return "1 min"
    }
    if minutes <= 90{
        return "\(minutes) mins"
    }
    if minutes > 2880{
        return "\(minutes/1440) days"
    }
    if minutes > 1440{
        return "1 day"
    }
    if minutes > 90 && minutes <= 1440{
        let mydateformat = DateFormatter()
        mydateformat.dateFormat = "hh:mm a"
        if status == true{
            return "Scheduled"
        }
        return mydateformat.string(from: date)
    }
    return ""
}

public func Iso8601toDate(iso8601Date: String) -> Date {
    if iso8601Date == "nil"{
        fatalError()
    }
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    let date:Date = formatter.date(from: iso8601Date)!
    return date
}

public func Iso8601toString(iso8601Date: String, withTime: Bool?, withDate: Bool?) -> String{
    if iso8601Date == "nil" || iso8601Date == ""{
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
    mydateformat.dateFormat = "EEE dd MMM yyyy  hh:mm a"
    if withTime == false {
        mydateformat.dateFormat = "EEE dd MMM yyyy"
    }
    if withDate == false{
        mydateformat.dateFormat = "hh:mm a"
    }
    return mydateformat.string(from: date!)
}

public func Iso8601toStatus(iso8601DateSchedule: String, iso8601DateActual: String) -> Int {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    let scheduleDate:Date = formatter.date(from: iso8601DateSchedule)!
    let actualDate:Date = formatter.date(from: iso8601DateActual)!
    let differences = Calendar.current.dateComponents([.minute], from: scheduleDate, to: actualDate)
    let minutes = differences.minute ?? 0
    
    return minutes
}


//  MARK: - PTV's different color type

public func changeColorByRouteType(routeType: Int) -> UIColor {
    // Changeing color after stop info loaded, set the background color theme as transport types
    switch routeType {  // Transport type category on API PDF Page43
    case 0: //Train (metropolitan)
        return UIColor.init(red: 0.066, green: 0.455, blue: 0.796, alpha: 1)
    case 1: //Tram
        return UIColor.init(red: 0.4784, green: 0.7372, blue: 0.1882, alpha: 1)
    case 2: //Bus (metropolitan, regional and Skybus, but not V/Line)
        return UIColor.init(red: 0.993, green: 0.5098, blue: 0.1372, alpha: 1)
    case 3: //  V/Line train and coach
        return UIColor.init(red: 0.5568, green: 0.1333, blue: 0.5765, alpha: 1)
    case 4: //Night Bus (which replaced NightRider)
        return UIColor.init(red: 0.993, green: 0.5098, blue: 0.1372, alpha: 1)
    default:
        return UIColor.white
    }
}



//  MARK: - Generate PTV Request Address

/*
 All data from Public Transport Victoria - V3 API
 
 Created by Public Transport Victoria
 See more at http://ptv.vic.gov.au/digital
 */

public func extractedFunc(_ request: String) -> String {
    let signature: String = request.hmac(algorithm: CryptoAlgorithm.SHA1, key: PrimaryDevKey)
    let requestAddress: String = HARDCODEDURL+request+"&signature="+signature
    
    print("Request: \(requestAddress)")
    return requestAddress
}

// Departures
public func showRouteDepartureOnStop(routeType: Int, stopId: Int, routeId: Int) -> String{       // View departures for a specific route from a stop
    let request: String = "/v3/departures/route_type/\(routeType)/stop/\(stopId)/route/\(routeId)?expand=all&devid="+PrimaryDevId
    return extractedFunc(request)
}
public func showRouteDepartureOnStop(routeType: Int, stopId: Int, routeId: Int, directionId: Int) -> String{      // View departures for a specific route from a stop (With Direction condition)
    let request: String = "/v3/departures/route_type/\(routeType)/stop/\(stopId)/route/\(routeId)?direction_id=\(directionId)&expand=all&devid="+PrimaryDevId
    return extractedFunc(request)
}
public func nextDepartureURL(routeType: Int, stopId: Int) -> String{            // View departures for all routes from a stop
    let request: String = "/v3/departures/route_type/\(routeType)/stop/\(stopId)?max_results=200&expand=all&devid="+PrimaryDevId
    return extractedFunc(request)
}

// Disruptions
public func disruptionAll() -> String{      // View all disruptions for all route types
    let request: String = "/v3/disruptions?devid="+PrimaryDevId
    return extractedFunc(request)
}

public func disruptionByRoute(routeId: Int) -> String {     // View all disruptions for a particular route
    let request: String = "/v3/disruptions/route/\(routeId)?devid="+PrimaryDevId
    return extractedFunc(request)
}

public func disruptionByStop(stopID: Int) -> String{        // View all disruptions for a particular stop
    let request: String = "/v3/disruptions/stop/"+String(stopID)+"?devid="+PrimaryDevId
    return extractedFunc(request)
}

public func disruptionById(disruptionId: Int) -> String{    // View a specific disruption
    let request: String = "/v3/disruptions/"+String(disruptionId)+"?devid="+PrimaryDevId
    return extractedFunc(request)
}

// Directions
public func showDirectionsOnRoute(routeId: Int) -> String{  // View directions that a route travels in
    let request: String = "/v3/directions/route/\(routeId)?devid="+PrimaryDevId
    return extractedFunc(request)
}

// Patterns
public func showPatternonRoute(runId: Int, routeType:Int) -> String{    // View the stopping pattern for a specific trip/service run
    let request: String = "/v3/pattern/run/\(runId)/route_type/\(routeType)?expand=all&devid="+PrimaryDevId
    return extractedFunc(request)
}

// Routes
public func showRouteInfo(routeId: Int) -> String{                      // View route name and number for specific route ID
    let request: String = "/v3/routes/\(routeId)?devid="+PrimaryDevId
    return extractedFunc(request)
}

//Runs
public func showRouteRuns(routeId: Int) -> String{      //View all trip/service runs for a specific route ID and route type
    let request: String = "/v3/runs/route/\(routeId)?devid="+PrimaryDevId
    return extractedFunc(request)
}

public func showRoutesRun(routeId: Int, routeType: Int) -> String{      //View all trip/service runs for a specific route ID and route type
    let request: String = "/v3/runs/route/\(routeId)/route_type/\(routeType)?devid="+PrimaryDevId
    return extractedFunc(request)
}

public func showRunInfo(runId: Int, routeType: Int) -> String{          // View the trip/service run for a specific run ID and route type
    let request: String = "/v3/runs/\(runId)/route_type/\(routeType)?devid="+PrimaryDevId
    return extractedFunc(request)
}

// Search
public func showSearchResults(searchTerm: String) -> String{            // View stops, routes and myki ticket outlets that match the search term
    let request: String = "/v3/search/\(searchTerm)?devid="+PrimaryDevId
    return extractedFunc(request)
}
public func showSearchResults(searchTerm: String, latitude: Double, longitude: Double) -> String{   // View stops, routes and myki ticket outlets that match the search term
    let request: String = "/v3/search/\(searchTerm)?latitude=\(latitude)&longitude=\(longitude)&devid="+PrimaryDevId
    return extractedFunc(request)
}

// Stops
public func showStopsInfo(stopId: Int, routeType: Int) -> String{       // View facilities at a specific stop (Metro and V/Line stations only)
    let request: String = "/v3/stops/\(stopId)/route_type/\(routeType)?stop_location=true&devid="+PrimaryDevId
    return extractedFunc(request)
}

public func showRoutesStop(routeId: Int, routeType: Int) -> String{     // View all stops on a specific route
    let request: String = "/v3/stops/route/\(routeId)/route_type/\(routeType)?devid="+PrimaryDevId
    return extractedFunc(request)
}

public func nearByStops(latitude: Double, longtitude: Double) -> String{    // View all stops near a specific location
    let request: String = "/v3/stops/location/\(latitude),\(longtitude)?max_results=3&max_distance=1500&devid="+PrimaryDevId
    return extractedFunc(request)
}

public func nearByStopsOnSelect(latitude: Double, longtitude: Double) -> String{    // View all stops near a specific location
    let request: String = "/v3/stops/location/\(latitude),\(longtitude)?max_results=750&max_distance=10000&devid="+PrimaryDevId
    return extractedFunc(request)
}

public func nearByTrainStopsOnSelect(latitude: Double, longtitude: Double) -> String{    // View metro and vline stops only at large scale
    let request: String = "/v3/stops/location/\(latitude),\(longtitude)?route_types=0&route_types=3&max_results=750&max_distance=9999999&devid="+PrimaryDevId
    return extractedFunc(request)
}

public func nearByVlineStopsOnSelect(latitude: Double, longtitude: Double) -> String{    // View vline stops only at large scale
    let request: String = "/v3/stops/location/\(latitude),\(longtitude)?route_types=3&max_results=750&max_distance=9999999&devid="+PrimaryDevId
    return extractedFunc(request)
}

enum CryptoAlgorithm {
    case MD5, SHA1
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:      result = kCCHmacAlgMD5
        case .SHA1:     result = kCCHmacAlgSHA1
        }
        return CCHmacAlgorithm(result)
    }
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:      result = CC_MD5_DIGEST_LENGTH
        case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
        }
        return Int(result)
    }
}
