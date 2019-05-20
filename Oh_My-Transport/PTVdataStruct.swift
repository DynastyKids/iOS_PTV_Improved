//
//  PTV Data Struct.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 12/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//
import Foundation

/*
 Status
*/
struct status: Codable {
    var version: String     //API Version number
    var health: Int         //API system health status (0=offline, 1=online) = ['0', '1']}
    
    private enum CodingKeys: String, CodingKey{
        case version
        case health
    }
}


/*
    Departures
 
    GET /v3/departures/route_type/{route_type}/stop/{stop_id}
*/
struct departuresResponse: Codable {
    var departures: [departure]
    var status: status
    
    private enum CodingKeys: String, CodingKey{
        case departures
        case status
    }
}

struct departure: Codable{
    var stopsId: Int?
    var routesId: Int?
    var runId: Int?
    var directionId: Int?
    var disruptionIds: [Int]?
    var scheduledDepartureUTC: String?
    var estimatedDepartureUTC: String?
    var atPlatform: Bool
    var platformNumber: String?
    var flags: String?      //    flag indicating special condition for run (e.g. RR Reservations Required, GC Guaranteed Connection, DOO Drop Off Only, PUO Pick Up Only, MO Mondays only, TU Tuesdays only, WE Wednesdays only, TH Thursdays only, FR Fridays only, SS School days only; ignore E flag) ,
    var departureSequence: Int?
    
    private enum CodingKeys: String, CodingKey{
        case stopsId = "stop_id"
        case routesId = "route_id"
        case runId = "run_id"
        case directionId = "direction_id"
        case disruptionIds = "disruption_ids"
        case scheduledDepartureUTC = "scheduled_departure_utc"
        case estimatedDepartureUTC = "estimated_departure_utc"
        case atPlatform = "at_platform"
        case platformNumber = "platform_number"
        case flags
        case departureSequence = "departure_sequence"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stopsId = try? container.decode(Int.self, forKey: .stopsId)
        self.routesId = try? container.decode(Int.self, forKey: .routesId)
        self.runId = try? container.decode(Int.self, forKey: .runId)
        self.directionId = try? container.decode(Int.self, forKey: .directionId)
        self.disruptionIds = try? container.decode([Int].self, forKey: .disruptionIds)
        self.scheduledDepartureUTC = try? container.decode(String.self, forKey: .scheduledDepartureUTC)
        self.estimatedDepartureUTC = try? container.decode(String.self, forKey: .estimatedDepartureUTC)
        self.atPlatform = try container.decode(Bool.self, forKey: .atPlatform)
        self.platformNumber = try? container.decode(String.self, forKey: .platformNumber)
        self.flags = try? container.decode(String.self, forKey: .flags)
        self.departureSequence = try? container.decode(Int.self, forKey: .departureSequence)
    }
}
/*
    Directions
 
    GET /v3/directions/route/{route_id}
    GET /v3/directions/{direction_id}/route_type/{route_type}
 */
struct directionsResponse: Codable{
    var directions: [directionWithDescription]?     //Directions of travel of route
    var status: status?
    private enum CodingKeys: String, CodingKey{
        case directions
        case status
    }
}

struct directionWithDescription: Codable {
    var routeDirectionDescription: String?
    var directionId: Int?           // Direction of travel identifier
    var directionName: String?      // Name of direction of travel
    var routeId: Int?               // Route identifier
    var routeType: Int?             // Transport mode identifier
    private enum CodingKeys: String, CodingKey{
        case routeDirectionDescription = "route_direction_description"
        case directionId = "direction_id"
        case directionName = "direction_name"
        case routeId = "route_id"
        case routeType = "route_type"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.directionId = try? container.decode(Int.self, forKey: .directionId)
        self.directionName = try? container.decode(String.self, forKey: .directionName)
        self.routeId = try? container.decode(Int.self, forKey: .routeId)
        self.routeType = try? container.decode(Int.self, forKey: .routeType)
    }
}

/*
    Disruptions
 
    GET /v3/disruptions
    GET /v3/disruptions/disruption_id
 */
struct disruptionsResponse: Codable{
    var disruptions: disruptions?
    var status: status?
    private enum CodingKeys: String, CodingKey{
        case disruptions
        case status
    }
}

struct disruptions: Codable{
    var general: [disruption]?
    var metroTrain: [disruption]?
    var metroTram: [disruption]?
    var metroBus: [disruption]?
    var vlineTrain: [disruption]?
    var vlineCoach: [disruption]?
    var regionalBus: [disruption]?
    var schoolBus: [disruption]?
    var telebus: [disruption]?
    var nightbus: [disruption]?
    var ferry: [disruption]?
    var interstate: [disruption]?
    var skybus: [disruption]?
    var taxi: [disruption]?
    
    private enum CodingKeys: String, CodingKey{
        case general
        case metroTrain = "metro_train"
        case metroTram = "metro_tram"
        case metroBus = "metro_bus"
        case vlineTrain = "regional_train"
        case vlineCoach = "regional_coach"
        case regionalBus = "regional_bus"
        case schoolBus = "school_bus"
        case telebus
        case nightbus = "night_bus"
        case ferry
        case interstate = "interstate_train"
        case skybus
        case taxi
    }
}
struct disruption: Codable{
    var disruptionId: Int?
    var title: String?
    var url: String?
    var description: String?
    var disruptionStatus: String?
    var disruptionType: String?
    var publishDate: String?
    var updateDate: String?
    var startDate: String?
    var endDate: String?
    var routes: [disruptionRoute]?
    var stops: [disruptionStop]?
    var colour: String?
    var displayOnBoard: Bool?
    var displayStatus: Bool?
    
    private enum CodingKeys: String, CodingKey{
        case disruptionId = "disruption_id"
        case title
        case url
        case description
        case disruptionStatus = "disruption_status"
        case disruptionType = "disruption_type"
        case publishDate = "published_on"
        case updateDate = "last_updated"
        case startDate = "from_date"
        case endDate = "to_date"
        case routes
        case stops
        case colour
        case displayOnBoard = "display_on_board"
        case displayStatus = "display_status"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.disruptionId = try? container.decode(Int.self, forKey: .disruptionId)
        self.title = try? container.decode(String.self, forKey: .title)
        self.url = try? container.decode(String.self, forKey: .url)
        self.description = try? container.decode(String.self, forKey: .description)
        self.disruptionStatus = try? container.decode(String.self, forKey: .disruptionStatus)
        self.disruptionType = try? container.decode(String.self, forKey: .disruptionType)
        self.publishDate = try? container.decode(String.self, forKey: .publishDate)
        self.updateDate = try? container.decode(String.self, forKey: .updateDate)
        self.startDate = try? container.decode(String.self, forKey: .startDate)
        self.endDate = try? container.decode(String.self, forKey: .endDate)
        self.routes = try? container.decode([disruptionRoute].self, forKey: .routes)
        self.stops = try? container.decode([disruptionStop].self, forKey: .stops)
        self.colour = try? container.decode(String.self, forKey: .colour)
        self.displayOnBoard = try? container.decode(Bool.self, forKey: .displayOnBoard)
        self.displayStatus = try? container.decode(Bool.self, forKey: .displayStatus)
    }
}
struct disruptionRoute: Codable{
    var routeType: Int?
    var routeId: Int?
    var routeName: String?
    var routeNumber: String?
    var gtfsId: String?
    var direction: disruptionDirection?
    private enum routesCodingKeys: String, CodingKey{
        case routeType = "route_type"
        case routeId = "route_id"
        case routeName = "route_name"
        case routeNumber = "route_number"
        case gtfsId = "route_gtfs_id"
        case direction
    }
}
struct disruptionDirection: Codable{
    var routeDirectionId: Int?
    var directionId: Int?
    var directionName: String?
    var serviceTime: String?
    private enum directionCodingKeys: String, CodingKey{
        case routeDirectionId = "route_direction_id"
        case directionId = "direction_id"
        case directionName = "direction_name"
        case serviceTime = "service_time"
    }
}
struct disruptionStop: Codable{
    var stopId: Int?
    var stopName: String?
    private enum CodingKeys: String, CodingKey{
        case stopId = "stop_id"
        case stopName = "stop_name"
    }
}


/*
    Patterns
 
    GET /v3/pattern/run/{run_id}/route_type/{route_type}
 */
struct stoppingPattern: Codable {
    var disruptions: [disruption]?
    var departures: patternDepartures?
//    var stops:
//    var routes:
//    var directions:
    var status: status
    
    private enum CodingKeys: String, CodingKey{
        case disruptions
        case departures
//        case stops
//        case routes
//        case directions
        case status
    }
}

struct patternDepartures: Codable {
    var stopId: Int?
    var routeId: Int?
    var runId: Int?
    var directionId: Int?
    var disruptionIds: [Int]?
    var scheduledDepartureUTC: String?
    var estimatedDepartureUTC: String?
    var atPlatform: Bool?
    var platormNumber: String?
    var flags: String?
    var departureSequence: Int?
    private enum CodingKeys: String, CodingKey{
        case stopId = "stop_id"
        case routeId = "route_id"
        case runId = "run_id"
        case directionId = "direction_id"
        case disruptionIds = "disruption_ids"
        case scheduledDepartureUTC = "scheduled_departure_utc"
        case estimatedDepartureUTC = "estimated_departure_utc"
        case atPlatform = "at_platform"
        case platormNumber = "platform_number"
        case flags
        case departureSequence = "departure_sequence"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stopId = try? container.decode(Int.self, forKey: .stopId)
        self.routeId = try? container.decode(Int.self, forKey: .routeId)
        self.runId = try? container.decode(Int.self, forKey: .runId)
        self.directionId = try? container.decode(Int.self, forKey: .directionId)
        self.disruptionIds = try? container.decode([Int].self, forKey: .disruptionIds)
        self.scheduledDepartureUTC = try? container.decode(String.self, forKey: .scheduledDepartureUTC)
        self.estimatedDepartureUTC = try? container.decode(String.self, forKey: .estimatedDepartureUTC)
        self.atPlatform = try? container.decode(Bool.self, forKey: .atPlatform)
        self.platormNumber = try? container.decode(String.self, forKey: .platormNumber)
        self.flags = try? container.decode(String.self, forKey: .flags)
        self.departureSequence = try? container.decode(Int.self, forKey: .departureSequence)
    }
}


/*
    Routes
 
    GET /v3/Routes
    GET /v3/Routes/{Route_id}
 */
struct routeResponse: Codable{
    var route: RouteWithStatus? //  Train lines, tram routes, bus routes, regional coach routes, Night Bus routes ,
    var status: status?
    private enum CodingKeys: String, CodingKey{
        case route
        case status
    }
}
struct RouteWithStatus: Codable {
    var routeServiceStatus: RouteServiceStatus?
    var routeType: Int? //Transport mode identifier ,
    var routeId: Int? //Route identifier ,
    var routeName: String? // Name of route ,
    var routeNumber: String? //Route number presented to public (nb. not route_id)
    var GtfsId: String? // GTFS Identifer of the route
    private enum CodingKeys: String, CodingKey{
        case routeServiceStatus = "route_service_status"
        case routeType = "route_type"
        case routeId = "route_id"
        case routeName = "route_name"
        case routeNumber = "route_number"
        case GtfsId = "route_gtfs_id"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.routeServiceStatus = try? container.decode(RouteServiceStatus.self, forKey: .routeServiceStatus)
        self.routeType = try? container.decode(Int.self, forKey: .routeType)
        self.routeId = try? container.decode(Int.self, forKey: .routeId)
        self.routeName = try? container.decode(String.self, forKey: .routeName)
        self.routeNumber = try? container.decode(String.self, forKey: .routeNumber)
        self.GtfsId = try? container.decode(String.self, forKey: .GtfsId)
    }
}
struct RouteServiceStatus: Codable {
    var description: String?
    var timestamp: String?
    private enum CodingKeys: String, CodingKey{
        case description
        case timestamp
    }
}


/*
    Stops

    GET /v3/stops/location/{latitude},{longitude}
*/
struct stopResponseByLocation: Codable {
    var stops: [stopGeosearch]?
    //    var disruptions: disruptions?
    var status: status?
    
    private enum CodingKeys: String, CodingKey{
        case stops
        case status
    }
}

struct stopGeosearch: Codable{
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stopDistance = try? container.decode(Double.self, forKey: .stopDistance)
        self.stopSuburb = try? container.decode(String.self, forKey: .stopSuburb)
        self.stopName = try? container.decode(String.self, forKey: .stopName)
        self.stopId = try? container.decode(Int.self, forKey: .stopId)
        self.routeType = try? container.decode(Int.self, forKey: .routeType)
        self.stopLatitude = try? container.decode(Double.self, forKey: .stopLatitude)
        self.stopLongitude = try? container.decode(Double.self, forKey: .stopLongitude)
        self.stopSequence = try? container.decode(Int.self, forKey: .stopSequence)
    }
}

struct stopResposeById: Codable{
    var stop: StopDetails?
    var status: status?
    private enum CodingKeys: String, CodingKey{
        case stop
        case status
    }
}

struct StopDetails: Codable{
    var disruptionIds: [Int]?  // (Array[integer], optional): Disruption information identifier(s) ,
    var stationType: String?   // (string, optional): Type of metropolitan train station (i.e. "Premium", "Host" or "Unstaffed" station); returns null for V/Line train ,
    var stationDescription: String?    // (string, optional): The definition applicable to the station_type; returns null for V/Line train ,
    var routeType: Int?    // (integer, optional): Transport mode identifier ,
//    var stop_location (V3.StopLocation, optional): Location details of the stop ,
//    var stop_amenities (V3.StopAmenityDetails, optional): Amenity and facility details at the stop ,
//    var stop_accessibility (V3.StopAccessibility, optional): Facilities relating to the accessibility of the stop ,
//    var stop_staffing (V3.StopStaffing, optional): Staffing details for the stop ,
    var stopId: Int?   // (integer, optional): Stop identifier ,
    var stopName: String?  // (string, optional): Name of stop
    
    private enum CodingKeys: String, CodingKey{
        case disruptionIds = "disruption_ids"
        case stationType = "station_type"
        case stationDescription = "station_description"
        case routeType = "route_type"
        case stopId = "stop_id"
        case stopName = "stop_name"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.disruptionIds = try? container.decode([Int].self, forKey: .disruptionIds)
        self.stationType = try? container.decode(String.self, forKey: .stationType)
        self.stationDescription = try? container.decode(String.self, forKey: .stationDescription)
        self.routeType = try? container.decode(Int.self, forKey: .routeType)
        self.stopId = try? container.decode(Int.self, forKey: .stopId)
        self.stopName = try? container.decode(String.self, forKey: .stopName)
    }
}

/*
 Stops on specific route response
 */

struct stopsOnRouteResponse {
    var stops: [stopOnRoute]?
//    var disruptions
    var status: status?
}

struct stopOnRoute: Codable {
//    var disruptionIds
    var stopSuburb: String?
    var stopName: String?
    var stopId: String?
    var routeType: Int?
    var stopLatitude: Double?
    var stopLongtitude: Double?
    var stopSequence: Int?
    
    private enum CodingKeys: String, CodingKey{
        case stopSuburb = "stop_suburb"
        case stopName = "stop_name"
        case stopId = "stop_id"
        case routeType = "route_type"
        case stopLatitude = "stop_latitude"
        case stopLongtitude = "stop_longitude"
        case stopSequence = "stop_sequence"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stopSuburb = try? container.decode(String.self, forKey: .stopSuburb)
        self.stopName = try? container.decode(String.self, forKey: .stopName)
        self.stopId = try? container.decode(String.self, forKey: .stopId)
        self.routeType = try? container.decode(Int.self, forKey: .routeType)
        self.stopLatitude = try? container.decode(Double.self, forKey: .stopLatitude)
        self.stopLongtitude = try? container.decode(Double.self, forKey: .stopLongtitude)
        self.stopSequence = try? container.decode(Int.self, forKey: .stopSequence)
    }
}
