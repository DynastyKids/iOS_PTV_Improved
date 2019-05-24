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
 
    Attached to every request made
*/
struct Status: Codable {
    var version: String?    //API Version number
    var health: Int?        //API system health status (0=offline, 1=online) = ['0', '1']}
    private enum CodingKeys: String, CodingKey{
        case version
        case health
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try? container.decode(String.self, forKey: .version)
        self.health = try? container.decode(Int.self, forKey: .health)
    }
}


/*
    Departures
 
    GET /v3/departures/route_type/{route_type}/stop/{stop_id}
*/
struct DeparturesResponse: Codable {
    var departures: [Departure]?
//    var stops: stopGeosearch?                     // Object - decode via dictonary
//    var routes: RouteWithStatus?                  // Object - decode via dictonary
//    var runs: Runs?                               // Object - decode via dictonary
//    var directions: DirectionWithDescription?     // Object - decode via dictonary
//    var disruptions: Disruption?                  // Object - decode via dictonary
    var status: Status?
    private enum CodingKeys: String, CodingKey{
        case departures
        case status
    }
}

struct Departure: Codable{
    var stopsId: Int?
    var routesId: Int?
    var runId: Int?
    var directionId: Int?
    var disruptionIds: [Int]?
    var scheduledDepartureUTC: String?
    var estimatedDepartureUTC: String?
    var atPlatform: Bool?
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
        self.atPlatform = try? container.decode(Bool.self, forKey: .atPlatform)
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
struct DirectionsResponse: Codable{
    var directions: [DirectionWithDescription]?     //Directions of travel of route
    var status: Status?
    private enum CodingKeys: String, CodingKey{
        case directions
        case status
    }
}

struct DirectionWithDescription: Codable {
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
    init(routeDirectionDescription: String?, directionId: Int?, directionName: String?, routeId: Int?, routeType: Int?) {
        self.routeDirectionDescription = routeDirectionDescription
        self.directionId = directionId
        self.directionName = directionName
        self.routeId = routeId
        self.routeType = routeType
    }
}


/*
    Disruptions
 
    GET /v3/disruptions
    GET /v3/disruptions/disruption_id
 */
struct DisruptionsResponse: Codable{
    var disruptions: Disruptions?
    var status: Status?
    private enum CodingKeys: String, CodingKey{
        case disruptions
        case status
    }
}

struct Disruptions: Codable{
    var general: [Disruption]?
    var metroTrain: [Disruption]?
    var metroTram: [Disruption]?
    var metroBus: [Disruption]?
    var vlineTrain: [Disruption]?
    var vlineCoach: [Disruption]?
    var regionalBus: [Disruption]?
    var schoolBus: [Disruption]?
    var telebus: [Disruption]?
    var nightbus: [Disruption]?
    var ferry: [Disruption]?
    var interstate: [Disruption]?
    var skybus: [Disruption]?
    var taxi: [Disruption]?
    
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
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.general = try? container.decode([Disruption].self, forKey: .general)
        self.metroTrain = try? container.decode([Disruption].self, forKey: .metroTrain)
        self.metroTram = try? container.decode([Disruption].self, forKey: .metroTram)
        self.metroBus = try? container.decode([Disruption].self, forKey: .metroBus)
        self.vlineTrain = try? container.decode([Disruption].self, forKey: .vlineTrain)
        self.vlineCoach = try? container.decode([Disruption].self, forKey: .vlineCoach)
        self.regionalBus = try? container.decode([Disruption].self, forKey: .regionalBus)
        self.schoolBus = try? container.decode([Disruption].self, forKey: .schoolBus)
        self.telebus = try? container.decode([Disruption].self, forKey: .telebus)
        self.nightbus = try? container.decode([Disruption].self, forKey: .nightbus)
        self.ferry = try? container.decode([Disruption].self, forKey: .ferry)
        self.interstate = try? container.decode([Disruption].self, forKey: .interstate)
        self.skybus = try? container.decode([Disruption].self, forKey: .skybus)
        self.taxi = try? container.decode([Disruption].self, forKey: .taxi)
    }
}
struct Disruption: Codable{
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
    var routes: [DisruptionRoute]?
    var stops: [DisruptionStop]?
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
        self.routes = try? container.decode([DisruptionRoute].self, forKey: .routes)
        self.stops = try? container.decode([DisruptionStop].self, forKey: .stops)
        self.colour = try? container.decode(String.self, forKey: .colour)
        self.displayOnBoard = try? container.decode(Bool.self, forKey: .displayOnBoard)
        self.displayStatus = try? container.decode(Bool.self, forKey: .displayStatus)
    }
    
    init(disruptionId: Int?,title: String?, url: String?, description: String?, disruptionStatus: String?, disruptionType: String?, publishDate:String?, updateDate: String?, startDate: String?, endDate:String?) {
        self.disruptionId = disruptionId
        self.title = title
        self.url = url
        self.description = description
        self.disruptionStatus = disruptionStatus
        self.disruptionType = disruptionType
        self.publishDate = publishDate
        self.updateDate = updateDate
        self.startDate = startDate
        self.endDate = endDate
        self.routes = nil
        self.stops = nil
        self.colour = nil
        self.displayOnBoard = nil
        self.displayStatus = nil
    }
}
struct DisruptionRoute: Codable{
    var routeType: Int?
    var routeId: Int?
    var routeName: String?
    var routeNumber: String?
    var gtfsId: String?
    var direction: DisruptionDirection?
    private enum routesCodingKeys: String, CodingKey{
        case routeType = "route_type"
        case routeId = "route_id"
        case routeName = "route_name"
        case routeNumber = "route_number"
        case gtfsId = "route_gtfs_id"
        case direction
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.routeType = try? container.decode(Int.self, forKey: .routeType)
        self.routeId = try? container.decode(Int.self, forKey: .routeId)
        self.routeName = try? container.decode(String.self, forKey: .routeName)
        self.routeNumber = try? container.decode(String.self, forKey: .routeNumber)
        self.gtfsId = try? container.decode(String.self, forKey: .gtfsId)
        self.direction = try? container.decode(DisruptionDirection.self, forKey: .direction)
    }
}
struct DisruptionDirection: Codable{
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
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.routeDirectionId = try? container.decode(Int.self, forKey: .routeDirectionId)
        self.directionId = try? container.decode(Int.self, forKey: .directionId)
        self.directionName = try? container.decode(String.self, forKey: .directionName)
        self.serviceTime = try? container.decode(String.self, forKey: .serviceTime)
    }
}
struct DisruptionStop: Codable{
    var stopId: Int?
    var stopName: String?
    private enum CodingKeys: String, CodingKey{
        case stopId = "stop_id"
        case stopName = "stop_name"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stopId = try? container.decode(Int.self, forKey: .stopId)
        self.stopName = try? container.decode(String.self, forKey: .stopName)
    }
}


/*
    Patterns
 
    GET /v3/pattern/run/{run_id}/route_type/{route_type}
 */
struct PatternResponse: Codable {
    var disruptions: [Disruption]?
    var departures: [Departure]?
//    var stops: [StopGeosearch]?
//    var routes: [RouteWithStatus]?
//    var runs: [Run]?
//    var directions: [DirectionWithDescription]?
    var status: Status?
    
    private enum CodingKeys: String, CodingKey{
        case disruptions
        case departures
//        case stops
//        case routes
//        case runs
//        case directions
        case status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.disruptions = try? container.decode([Disruption].self, forKey: .disruptions)
        self.departures = try? container.decode([Departure].self, forKey: .departures)
//        self.stops = try? container.decode([StopGeosearch].self, forKey: .stops)
//        self.routes = try? container.decode([RouteWithStatus].self, forKey: .routes)
//        self.runs = try? container.decode([Run].self, forKey: .runs)
//        self.directions = try? container.decode([DirectionWithDescription].self, forKey: .directions)
        self.status = try? container.decode(Status.self, forKey: .status)
    }
}


/*
    Routes
 
    GET /v3/Routes
    GET /v3/Routes/{Route_id}
 */
struct RouteResponse: Codable{
    var route: RouteWithStatus? //  Train lines, tram routes, bus routes, regional coach routes, Night Bus routes ,
    var status: Status?
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
    init(routeType: Int?, routeId: Int?, routeName: String?, routeNumber: String?, GtfsId:String?) {
        self.routeServiceStatus = nil
        self.routeType = routeType
        self.routeId = routeId
        self.routeName = routeName
        self.routeNumber = routeNumber
        self.GtfsId = GtfsId
    }
}
struct RouteServiceStatus: Codable {
    var description: String?
    var timestamp: String?
    private enum CodingKeys: String, CodingKey{
        case description
        case timestamp
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try? container.decode(String.self, forKey: .description)
        self.timestamp = try? container.decode(String.self, forKey: .timestamp)
    }
}


/*
    Runs
 
    GET /v3/runs/route/{route_id}
    GET /v3/runs/route/{route_id}/route_type/{route_type}
    GET /v3/runs/{run_id}/route_type/{route_type}
 */
struct RunsResponse: Codable {
    var runs: [Run]?
    var status: Status?
    private enum CodingKeys: String, CodingKey{
        case runs
        case status
    }
}
struct Run: Codable {
    var runId: Int?
    var routeId: Int?
    var routeType: Int?
    var finalStopId: Int?
    var destinationName: String?
    var status: String?
    var directionId: Int?
    var runSequence: Int?
    var expressStopCount: Int?
    var vehiclePosition: VehiclePosition?
    var vehicleDescriptor: VechicleDescriptor?
    private enum CodingKeys: String, CodingKey{
        case runId = "run_id"
        case routeId = "route_id"
        case routeType = "route_type"
        case finalStopId = "final_stop_id"
        case destinationName = "destination_name"
        case status
        case directionId = "direction_id"
        case runSequence = "run_sequence"
        case expressStopCount = "express_stop_count"
        case vehiclePosition = "vehicle_position"
        case vehicleDescriptor = "vehicle_descriptor"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.runId = try? container.decode(Int.self, forKey: .runId)
        self.routeId = try? container.decode(Int.self, forKey: .routeId)
        self.routeType = try? container.decode(Int.self, forKey: .routeType)
        self.finalStopId = try? container.decode(Int.self, forKey: .finalStopId)
        self.destinationName = try? container.decode(String.self, forKey: .destinationName)
        self.status = try? container.decode(String.self, forKey: .status)
        self.directionId = try? container.decode(Int.self, forKey: .directionId)
        self.runSequence = try? container.decode(Int.self, forKey: .runSequence)
        self.expressStopCount = try? container.decode(Int.self, forKey: .expressStopCount)
        self.vehiclePosition = try? container.decode(VehiclePosition.self, forKey: .vehiclePosition)
        self.vehicleDescriptor = try? container.decode(VechicleDescriptor.self, forKey: .vehicleDescriptor)
    }
    init(runId: Int?, routeId: Int?, routeType: Int?, finalStopId: Int?, destinationName: String?, status: String?, directionId: Int?, runSequence: Int?, expressStopCount: Int?, vehiclePosition: VehiclePosition?, vehicleDescriptor: VechicleDescriptor?) {
        self.runId = runId
        self.routeId = routeId
        self.routeType = routeType
        self.finalStopId = finalStopId
        self.destinationName = destinationName
        self.status = status
        self.directionId = directionId
        self.runSequence = runSequence
        self.expressStopCount = expressStopCount
        self.vehiclePosition = vehiclePosition
        self.vehicleDescriptor = vehicleDescriptor
    }
}

struct VehiclePosition: Codable {
    var latitude: Double?       //Geographic coordinate of latitude of the vehicle when known. May be null. Only available for some bus runs.
    var longtitude: Double?     //Geographic coordinate of longitude of the vehicle when known. Only available for some bus runs.
    var bearing: Double?        //Compass bearing of the vehicle when known, clockwise from True North, i.e., 0 is North and 90 is East. May be null. Only available for some bus runs.
    private enum CodingKeys: String, CodingKey{
        case latitude
        case longtitude
        case bearing
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.latitude = try? container.decode(Double.self, forKey: .latitude)
        self.longtitude = try? container.decode(Double.self, forKey: .longtitude)
        self.bearing = try? container.decode(Double.self, forKey: .bearing)
    }
}

struct VechicleDescriptor: Codable{
    var operators: String?      //Operator name of the vehicle such as "Metro Trains Melbourne", "Yarra Trams", "Ventura Bus Line", "CDC" or "Sita Bus Lines" . May be null/empty. Only available for train, tram, v/line and some bus runs.
    var id: String?             //Operator identifier of the vehicle such as "26094". May be null/empty. Only available for some tram and bus runs.
    var lowFloor: Bool?         //Indicator if vehicle has a low floor. May be null. Only available for some tram runs.
    var airConditioned: Bool?   //Indicator if vehicle is air conditioned. May be null. Only available for some tram runs.
    var description: String?    //Vehicle description such as "6 Car Comeng", "6 Car Xtrapolis", "3 Car Comeng", "6 Car Siemens", "3 Car Siemens". May be null/empty. Only available for some metropolitan train runs.
    private enum CodingKeys: String, CodingKey{
        case operators = "operator"
        case id
        case lowFloor = "low_floor"
        case airConditioned = "air_conditioned"
        case description
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.operators = try? container.decode(String.self, forKey: .operators)
        self.id = try? container.decode(String.self, forKey: .id)
        self.lowFloor = try? container.decode(Bool.self, forKey: .lowFloor)
        self.airConditioned = try? container.decode(Bool.self, forKey: .airConditioned)
        self.description = try? container.decode(String.self, forKey: .description)
    }
}

/*
    Search
 
    GET /v3/search/{search_term}        View stops, routes and myki ticket outlets that match the search term
 */
struct SearchResult: Codable {
    var stops: [ResultStop]?
    var routes: [ResultRoute]?
    var outlets: [ResultOutlet]?
    var status: Status?
    private enum CodingKeys: String, CodingKey{
        case stops
        case routes
        case outlets
        case status
    }
}

struct ResultStop: Codable {
    var stopDistance: Int?
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
        self.stopDistance = try? container.decode(Int.self, forKey: .stopDistance)
        self.stopSuburb = try? container.decode(String.self, forKey: .stopSuburb)
        self.stopName = try? container.decode(String.self, forKey: .stopName)
        self.stopId = try? container.decode(Int.self, forKey: .stopId)
        self.routeType = try? container.decode(Int.self, forKey: .routeType)
        self.stopLatitude = try? container.decode(Double.self, forKey: .stopLatitude)
        self.stopLongitude = try? container.decode(Double.self, forKey: .stopLongitude)
        self.stopSequence = try? container.decode(Int.self, forKey: .stopSequence)
    }
}

struct ResultRoute: Codable {
    var routeName: String?
    var routeNumber: String?
    var routeType: Int?
    var routeId: Int?
    var routeGtfsId: String?
    var routeServiceStatus: RouteServiceStatus?
    private enum CodingKeys: String, CodingKey{
        case routeName = "route_name"
        case routeNumber = "route_number"
        case routeType = "route_type"
        case routeId = "route_id"
        case routeGtfsId = "route_gtfs_id"
        case routeServiceStatus = "route_service_status"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.routeName = try? container.decode(String.self, forKey: .routeName)
        self.routeNumber = try? container.decode(String.self, forKey: .routeNumber)
        self.routeType = try? container.decode(Int.self, forKey: .routeType)
        self.routeId = try? container.decode(Int.self, forKey: .routeId)
        self.routeGtfsId = try? container.decode(String.self, forKey: .routeGtfsId)
        self.routeServiceStatus = try? container.decode(RouteServiceStatus.self, forKey: .routeServiceStatus)
    }
}

struct ResultOutlet: Codable{
    var outletDistance: Double?
    var outletSlidSpid: String?
    var outletName: String?
    var outeletBusiness: String?
    var outletLatitude: Double?
    var outletLongitude: Double?
    var outletSuburb: String?
    var outletPostcode: Int?
    var outletNotes: String?
    private enum CodingKeys: String, CodingKey{
        case outletDistance = "outlet_distance"
        case outletSlidSpid = "outlet_slid_spid"
        case outletName = "outlet_name"
        case outeletBusiness = "outlet_business"
        case outletLatitude = "outlet_latitude"
        case outletLongitude = "outlet_longitude"
        case outletSuburb = "outlet_suburb"
        case outletPostcode = "outlet_postcode"
        case outletNotes = "outlet_notes"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.outletDistance = try? container.decode(Double.self, forKey: .outletDistance)
        self.outletSlidSpid = try? container.decode(String.self, forKey: .outletSlidSpid)
        self.outletName = try? container.decode(String.self, forKey: .outletName)
        self.outeletBusiness = try? container.decode(String.self, forKey: .outeletBusiness)
        self.outletLatitude = try? container.decode(Double.self, forKey: .outletLatitude)
        self.outletLongitude = try? container.decode(Double.self, forKey: .outletLongitude)
        self.outletSuburb = try? container.decode(String.self, forKey: .outletSuburb)
        self.outletPostcode = try? container.decode(Int.self, forKey: .outletPostcode)
        self.outletNotes = try? container.decode(String.self, forKey: .outletNotes)
    }
}

/*
    Stops
 
    GET /v3/stops/{stop_id}/route_type/{route_type}
    GET /v3/stops/route/{route_id}/route_type/{route_type}
    GET /v3/stops/location/{latitude},{longitude}
*/

struct StopResponseByLocation: Codable {
    var stops: [stopGeosearch]?
//    var disruptions: disruptions?
    var status: Status?
    private enum CodingKeys: String, CodingKey{
        case stops
//        case disruptions: disruptions?
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
    
    init(stopDistance: Double?, stopSuburb: String?, stopName: String?, stopId: Int?, routeType: Int?, stopLatitude: Double?, stopLongitude: Double?, stopSequence: Int?) {
        self.stopDistance = stopDistance
        self.stopSuburb = stopSuburb
        self.stopName = stopName
        self.stopId = stopId
        self.routeType = routeType
        self.stopLatitude = stopLatitude
        self.stopLongitude = stopLongitude
        self.stopSequence = stopSequence
    }
}

struct stopResposeByStopId: Codable{
    var stop: StopDetails?
    var status: Status?
    private enum CodingKeys: String, CodingKey{
        case stop
        case status
    }
}

struct StopDetails: Codable{
    var disruptionIds: [Int]?       // (Array[integer], optional): Disruption information identifier(s) ,
    var stationType: String?        // (string, optional): Type of metropolitan train station (i.e. "Premium", "Host" or "Unstaffed" station); returns null for V/Line
    var stationDescription: String?                 // (string, optional): The definition applicable to the station_type; returns null for V/Line train ,
    var routeType: Int?             // (integer, optional): Transport mode identifier ,
    var stopLocation: StopLocation?                 //(V3.StopLocation, optional): Location details of the stop ,
    var stop_amenities: StopAmenityDetails?         //(V3.StopAmenityDetails, optional): Amenity and facility details at the stop ,
//    var stop_accessibility (V3.StopAccessibility, optional): Facilities relating to the accessibility of the stop ,
//    var stop_staffing (V3.StopStaffing, optional): Staffing details for the stop ,
    var stopId: Int?                // (integer, optional): Stop identifier ,
    var stopName: String?           // (string, optional): Name of stop
    private enum CodingKeys: String, CodingKey{
        case disruptionIds = "disruption_ids"
        case stationType = "station_type"
        case stationDescription = "station_description"
        case routeType = "route_type"
        case stopLocation = "stop_location"
        case stopId = "stop_id"
        case stopName = "stop_name"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.disruptionIds = try? container.decode([Int].self, forKey: .disruptionIds)
        self.stationType = try? container.decode(String.self, forKey: .stationType)
        self.stationDescription = try? container.decode(String.self, forKey: .stationDescription)
        self.routeType = try? container.decode(Int.self, forKey: .routeType)
        self.stopLocation = try? container.decode(StopLocation.self, forKey: .stopLocation)
        self.stopId = try? container.decode(Int.self, forKey: .stopId)
        self.stopName = try? container.decode(String.self, forKey: .stopName)
    }
    
    init(disruptionIds:[Int]?, stationType:String?, stationDescription: String?, routeType: Int?, stopLocation: StopLocation?, stopId: Int?, stopName: String?) {
        self.disruptionIds = disruptionIds
        self.stationType = stationType
        self.stationDescription = stationDescription
        self.routeType = routeType
        self.stopLocation = stopLocation
        self.stopId = stopId
        self.stopName = stopName
    }
}

struct StopAmenityDetails: Codable{
    var toliet: Bool?
    var taxiRank: Bool?
    var carParking: String?
    var cctv: Bool?
    private enum CodingKeys: String, CodingKey{
        case toliet
        case taxiRank = "taxi_rank"
        case carParking = "car_parking"
        case cctv
    }
}

struct StopLocation: Codable{
    var gps: Gps?
    var suburb: String?
    private enum CodingKeys: String, CodingKey{
        case gps
        case suburb
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.gps = try? container.decode(Gps.self, forKey: .gps)
        self.suburb = try? container.decode(String.self, forKey: .suburb)
    }
    
    init(gps: Gps?, suburb: String?) {
        self.gps = gps
        self.suburb = suburb
    }
}

struct Gps: Codable{
    var latitude: Double?
    var longitude: Double?
    private enum CodingKeys: String, CodingKey{
        case latitude
        case longitude
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.latitude = try? container.decode(Double.self, forKey: .latitude)
        self.longitude = try? container.decode(Double.self, forKey: .longitude)
    }
    init(latitude: Double?, longitude: Double?) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct StopsResponseByRouteId: Codable {
    var stops: [stopOnRoute]?
//    var disruptions
    var status: Status?
}

struct stopOnRoute: Codable {
//    var disruptionIds
    var stopSuburb: String?
    var stopName: String?
    var stopId: Int?
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
        self.stopId = try? container.decode(Int.self, forKey: .stopId)
        self.routeType = try? container.decode(Int.self, forKey: .routeType)
        self.stopLatitude = try? container.decode(Double.self, forKey: .stopLatitude)
        self.stopLongtitude = try? container.decode(Double.self, forKey: .stopLongtitude)
        self.stopSequence = try? container.decode(Int.self, forKey: .stopSequence)
    }
}


/*
    Error Handling
 
    // High demand fetching may trigger PTV's firewall
 
    Error: 400 - Invalid Request
    Error: 403 - Access Denied
 */

struct ErrorResponse: Codable {
    var message: String?
    var status: Status?
    private enum CodingKeys: String, CodingKey{
        case message
        case status
    }
}
