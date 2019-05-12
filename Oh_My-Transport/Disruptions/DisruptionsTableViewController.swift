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
struct disruptionRoot: Codable{
    var disruptions: disruptionOverview?
    var status: disruptionOverviewStatus?
    private enum CodingKeys: String, CodingKey{
        case disruptions
        case status
    }
}

struct disruptionOverview: Codable{
    var general: [disruptionInfo]?
    var metroTrain: [disruptionInfo]?
    var metroTram: [disruptionInfo]?
    var metroBus: [disruptionInfo]?
    var vlineTrain: [disruptionInfo]?
    var vlineCoach: [disruptionInfo]?
    var regionalBus: [disruptionInfo]?
    var schoolBus: [disruptionInfo]?
    var telebus: [disruptionInfo]?
    var nightbus: [disruptionInfo]?
    var ferry: [disruptionInfo]?
    var interstate: [disruptionInfo]?
    var skybus: [disruptionInfo]?
    var taxi: [disruptionInfo]?
    
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

struct disruptionInfo: Codable{
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
    var routes: [disruptionRoutes]?
    var stops: [disruptionStops]?
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
        self.routes = try? container.decode([disruptionRoutes].self, forKey: .routes)
        self.stops = try? container.decode([disruptionStops].self, forKey: .stops)
        self.colour = try? container.decode(String.self, forKey: .colour)
        self.displayOnBoard = try? container.decode(Bool.self, forKey: .displayOnBoard)
        self.displayStatus = try? container.decode(Bool.self, forKey: .displayStatus)
    }
}
struct disruptionRoutes: Codable{
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
struct disruptionStops: Codable{
    var stopId: Int?
    var stopName: String?
    private enum CodingKeys: String, CodingKey{
        case stopId = "stop_id"
        case stopName = "stop_name"
    }
}

struct disruptionOverviewStatus: Codable {
    var version: String?
    var health: Int?
    private enum CodingKeys: String, CodingKey{
        case version
        case health
    }
}

class DisruptionsTableViewController: UITableViewController {
    
    var disruptions: [disruptionInfo] = []
    
    let hardcodedURL:String = "https://timetableapi.ptv.vic.gov.au"
    let hardcodedDevID:String = "3001122"
    let hardcodedDevKey:String = "3c74a383-c69a-4e8d-b2f8-2e4c598b50b2"

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Loading disruption data from PTV
        let url = URL(string: disruptionAll());
        
        print(url);
        let task = URLSession.shared.dataTask(with: url!){(data, response, error) in
            print(url);
            if let error = error{
                print("fetching error: \(String(describing: error))")
                return
            }
            do{
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let disruptionData = try decoder.decode(disruptionRoot.self, from: data!)
                self.disruptions = (disruptionData.disruptions?.metroTrain)!
                self.disruptions += (disruptionData.disruptions?.metroTram)!
                self.disruptions += (disruptionData.disruptions?.metroBus)!
                self.disruptions += (disruptionData.disruptions?.vlineTrain)!
                self.disruptions += (disruptionData.disruptions?.vlineCoach)!
                self.disruptions += (disruptionData.disruptions?.regionalBus)!
                self.disruptions += (disruptionData.disruptions?.schoolBus)!
                self.disruptions += (disruptionData.disruptions?.telebus)!
                self.disruptions += (disruptionData.disruptions?.nightbus)!
                self.disruptions += (disruptionData.disruptions?.interstate)!
                self.disruptions += (disruptionData.disruptions?.skybus)!
                self.disruptions += (disruptionData.disruptions?.ferry)!
                self.disruptions += (disruptionData.disruptions?.taxi)!
                print(disruptionData.disruptions?.metroTrain?.count)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch{
                print(error)
            }
        }
        task.resume()
        // End of loading
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return disruptions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "disruptions", for: indexPath) as! disruptionTableViewCell
        let disruption = disruptions[indexPath.row]
        cell.disruptionTitleLabel.text = disruption.title
        cell.disruptionPublishDateLabel.text = "Last Update: " + iso8601DateConvert(iso8601Date: disruption.updateDate ?? "nil", withTime: true)
        
        return cell
    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDisruptionDetail"{
            let page2:DisruptionDetailViewController = segue.destination as! DisruptionDetailViewController
            page2.webkitAddress = disruptionById(disruptionId: (disruptions[tableView.indexPathForSelectedRow!.row]).disruptionId!)
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    fileprivate func extractedFunc(_ request: String) -> String {
        let signature: String = request.hmac(algorithm: CryptoAlgorithm.SHA1, key: hardcodedDevKey)
        let requestAddress: String = hardcodedURL+request+"&signature="+signature

        return requestAddress
    }
    
    func disruptionAll() -> String{
        let request: String = "/v3/disruptions?devid="+hardcodedDevID
        return extractedFunc(request)
    }
    func disruptionByRoute(routeID: Int) -> String{
        let request: String = "/v3/disruptions/route/"+String(routeID)+"?devid="+hardcodedDevID
        return extractedFunc(request)
    }
    func disruptionByStop(stopID: Int) -> String{
        let request: String = "/v3/disruptions/stop/"+String(stopID)+"?devid="+hardcodedDevID
        return extractedFunc(request)
    }
    func disruptionById(disruptionId: Int) -> String{
        let request: String = "/v3/disruptions/"+String(disruptionId)+"?devid="+hardcodedDevID
        return extractedFunc(request)
    }
    
    func iso8601DateConvert(iso8601Date: String, withTime: Bool?) -> String{
        if iso8601Date == "nil"{
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
        if withTime == false {
            mydateformat.dateFormat = "EEE dd MMM yyyy"
        }else{
            mydateformat.dateFormat = "EEE dd MMM yyyy  hh:mm a"
        }
        return mydateformat.string(from: date!)
    }
}
