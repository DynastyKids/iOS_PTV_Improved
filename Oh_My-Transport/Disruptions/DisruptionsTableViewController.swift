//
//  DisruptionsTableViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 3/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit
import Foundation
import CommonCrypto

//Decodable只能解析，不能被编码
struct DisruptionInfo: Codable{
    var disruptionID: Int?
    var title: String?
    var url: String?
    var description: String
    var disruptionStatus: String?
    var disruptionType: String?
    var publishDate: Date?
    var updateDate: Date?
    var startDate: Date?
    var endDate: Date?
    struct Routes: Decodable{
        var route_type: Int16?
        var route_id: Int16?
        var route_name: String?
        var route_number: String?
        var route_gtfs_id: String?
        struct Direction: Decodable{
            var route_direction_id: Int16?
            var direction_id: Int16?
            var direction_name: String?
            var service_time: String?
            
            private enum directionCodingKeys: String, CodingKey{
                case route_direction_id
                case direction_id
                case direction_name
                case service_time
            }
        }
        
        private enum routesCodingKeys: String, CodingKey{
            case route_type
            case route_id
            case route_name
            case route_number
            case route_gtfs_id
            case Direction
        }
    }
    struct Stops:Codable{
        var stopId: Int16?
        var stopName: String?
        
        private enum stopsCodingKeys: String, CodingKey{
            case stopId = "stop_id"
            case stopName = "stop_name"
        }
        
    }
    var colour: String?
    var displayOnBoard: Bool?
    var displayStatus: Bool?
    
    private enum disruptionsCodingKeys: String, CodingKey{
        case disruptionID = "disruption_id"
        case title
        case url
        case description
        case disruptionStatus = "disruption_status"
        case disruptionType = "disruption_type"
        case publishDate = "published_on"
        case updateDate = "last_updated"
        case startDate = "from_date"
        case endDate = "to_date"
        case Routes
        case colour
        case displayOnBoard = "display_on_board"
        case displayStatus = "display_status"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: disruptionsCodingKeys.self)
        self.disruptionID = try container.decode(Int.self, forKey: .disruptionID)
        self.title = try container.decode(String.self, forKey: .title)
        self.url = try container.decode(String.self, forKey: .url)
        self.description = try container.decode(String.self, forKey: .description)
        self.disruptionStatus = try container.decode(String.self, forKey: .disruptionStatus)
        self.disruptionType = try container.decode(String.self, forKey: .disruptionType)
        self.publishDate = try container.decode(Date.self, forKey: .publishDate)
        self.updateDate = try container.decode(Date.self, forKey: .updateDate)
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.endDate = try container.decode(Date.self, forKey: .endDate)
        self.colour = try container.decode(String.self, forKey: .colour)
        self.displayOnBoard = try container.decode(Bool.self, forKey: .displayOnBoard)
        self.displayStatus = try container.decode(Bool.self, forKey: .displayStatus)
    }
}

struct Disruptions: Codable {
    var general: [DisruptionInfo]?
    var MetroTrains: [DisruptionInfo]?
    var YarraTram: [DisruptionInfo]?
    var MetroBus: [DisruptionInfo]?
    var VlineTrain: [DisruptionInfo]?
    var VlineCoach: [DisruptionInfo]?
    var RegionalBus: [DisruptionInfo]?
    var schoolBus: [DisruptionInfo]?
    var telebus: [DisruptionInfo]?
    var nightbus: [DisruptionInfo]?
    var ferry: [DisruptionInfo]?
    var interstate: [DisruptionInfo]?
    var skybus: [DisruptionInfo]?
    var taxi: [DisruptionInfo]?
    
    private enum CodingKeys: String, CodingKey{
        case general
        case MetroTrains = "metro_train"
        case YarraTram = "metro_tram"
        case MetroBus = "metro_bus"
        case VlineTrain = "regional_train"
        case VlineCoach = "regional_coach"
        case RegionalBus = "regional_bus"
        case schoolBus = "school_bus"
        case telebus
        case nightbus
        case ferry
        case interstate
        case skybus
        case taxi
    }
}

struct Status: Codable {
    var version: String
    var health: Int16
    
    private enum CodingKeys: String, CodingKey{
        case version
        case health
    }
}
struct Root: Codable {
    var disruptions: Disruptions
    var status: Status
    
    private enum CodingKeys: String, CodingKey{
        case disruptions
        case status
    }
}

class DisruptionsTableViewController: UITableViewController {
    
    let config = URLSessionConfiguration.background(withIdentifier: "edu.Monash.wgon0001.Oh-My-Transport")
//    lazy var session = {
//        return URLSession(configuration: <#T##URLSessionConfiguration#>)
//    }
    
    var disruptions: [DisruptionInfo] = []
    
    let hardcodedURL:String = "https://timetableapi.ptv.vic.gov.au"
    let hardcodedDevID:String = "3001122"
    let hardcodedDevKey:String = "3c74a383-c69a-4e8d-b2f8-2e4c598b50b2"
    
    let CELL_DISRUPTION = "disruptions"
    
    func getDisruptions(){
        let url = URL(string: disruptionAll())
        let task = URLSession.shared.dataTask(with: url!){(data, response, error) in
            if let error = error{
                print("fetching error: \(String(describing: error))")
                return
            }
            do{
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601

                let showdata = try decoder.decode(Disruptions.self, from: data!)
                print(showdata.MetroTrains?.count)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch{
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
//    func getDisruptionData(){
//        if let url = URL(string: disruptionAll()) {
//            let task = URLSession.shared.dataTask(with: url) { (data, response , error) in
//                let jsonDecoder = JSONDecoder()
//                jsonDecoder.dateDecodingStrategy = .iso8601
//                let formatter = DateFormatter()
//                formatter.calendar = Calendar(identifier: .iso8601)
//                formatter.locale = Locale(identifier: "en_US_POSIX")
//                formatter.timeZone = TimeZone(secondsFromGMT: 0)
//
//
//                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
//                if let data = data, let disruptions = try? jsonDecoder.decode(Disruptions.self, from: data) {
//                    print(data)
//                    for service in disruptions.MetroTrains! {
//                        print(service)
//                    }
//                }else {
//                    print(error)
//                }
//            }
//            task.resume()
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        getDisruptions()
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_DISRUPTION, for: indexPath) as! disruptionTableViewCell

//        let disruption = disruptions[indexPath.row]
        
//        cell.disruptionTitleLabel.text = disruption.title
//        cell.disruptionPublishDateLabel.text = disruption.publishDate?.toString(dateFormat: "dd-MMM-yyyy")
        
        return cell
    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    fileprivate func extractedFunc(_ request: String) -> String {
        let signature: String = request.hmac(algorithm: CryptoAlgorithm.SHA1, key: hardcodedDevKey)
        let requestAddress: String = hardcodedURL+request+"&signature="+signature
        
        print(requestAddress)
        return requestAddress
    }
    
    func disruptionAll()->String{
        let request: String = "/v3/disruptions?devid="+hardcodedDevID
        return extractedFunc(request)
    }
    func disruptionByRoute(routeID: Int16)->String{
        let request: String = "/v3/disruptions/route/"+String(routeID)+"?devid="+hardcodedDevID
        return extractedFunc(request)
    }
    func disruptionByStop(stopID: Int16)->String{
        let request: String = "/v3/disruptions/stop/"+String(stopID)+"?devid="+hardcodedDevID
        return extractedFunc(request)
    }
}
extension Date{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
