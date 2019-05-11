//
//  DisruptionDetailViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 3/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit
import Foundation

struct disruptionDetailroot: Codable{
    var disruption: disruptionbyIdDetail?
    var disruptionByIdstatus: disruptionByIdstatus?
    
    private enum CodingKeys: String, CodingKey{
        case disruption
        case disruptionByIdstatus = "status"
    }
}

struct disruptionbyIdDetail: Codable {
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
    var routes: disryptionByIdroutes?
    var stops: disruptionByIdStops?
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
        self.disruptionId = try container.decode(Int.self, forKey: .disruptionId)
        self.title = try container.decode(String.self, forKey: .title)
        self.url = try container.decode(String.self, forKey: .url)
        self.description = try container.decode(String.self, forKey: .description)
        self.disruptionStatus = try container.decode(String.self, forKey: .disruptionStatus)
        self.disruptionType = try container.decode(String.self, forKey: .disruptionType)
        self.publishDate = try container.decode(String.self, forKey: .publishDate)
        self.updateDate = try container.decode(String.self, forKey: .updateDate)
        self.startDate = try container.decode(String.self, forKey: .startDate)
        self.endDate = try container.decode(String.self, forKey: .endDate)
        self.routes = try? container.decode(disryptionByIdroutes.self, forKey: .routes)
        self.stops = try? container.decode(disruptionByIdStops.self, forKey: .stops)
        self.colour = try container.decode(String.self, forKey: .colour)
        self.displayOnBoard = try container.decode(Bool.self, forKey: .displayOnBoard)
        self.displayStatus = try container.decode(Bool.self, forKey: .displayStatus)
    }
}

struct direction: Codable{
    var route_direction_id: Int?
    var direction_id: Int?
    var direction_name: String?
    var service_time: String?
    private enum CodingKeys: String, CodingKey{
        case route_direction_id
        case direction_id
        case direction_name
        case service_time
    }
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.route_direction_id = try container.decode(Int.self, forKey: .route_direction_id)
//        self.direction_id = try container.decode(Int.self, forKey: .direction_id)
//        self.direction_name = try container.decode(String.self, forKey: .direction_name)
//        self.service_time = try container.decode(String.self, forKey: .service_time)
//    }
}

struct disryptionByIdroutes: Codable{
    var routeType: Int?
    var routeId: Int?
    var routeName: String?
    var routeNumber: String?
    var gtfsId: String?
    var direction: direction?
    private enum CodingKeys: String, CodingKey{
        case routeType = "route_type"
        case routeId = "route_id"
        case routeName = "route_name"
        case routeNumber = "route_number"
        case gtfsId = "route_gtfs_id"
        case direction
    }
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.routeType = try container.decode(Int.self, forKey: .routeType)
//        self.routeId = try container.decode(Int.self, forKey: .routeId)
//        self.routeName = try container.decode(String.self, forKey: .routeName)
//        self.routeNumber = try container.decode(String.self, forKey: .routeNumber)
//        self.gtfsId = try container.decode(String.self, forKey: .gtfsId)
//    }
}

struct disruptionByIdStops: Codable{
    var stopId: Int?
    var stopName: String?
    private enum CodingKeys: String, CodingKey{
        case stopId = "stop_id"
        case stopName = "stop_name"
    }
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.stopId = try container.decode(Int.self, forKey: .stopId)
//        self.stopName = try container.decode(String.self, forKey: .stopName)
//    }
}

struct disruptionByIdstatus: Codable {
    var version: String?
    var health: Int?
    private enum CodingKeys: String, CodingKey{
        case version
        case health
    }
}

class DisruptionDetailViewController: UIViewController {
    
    @IBOutlet weak var disruptionTitleLabel: UILabel!
    @IBOutlet weak var disruptionPublishDateLabel: UILabel!
    @IBOutlet weak var disruptionStartDateLabel: UILabel!
    @IBOutlet weak var disruptionEndDateLabel: UILabel!
    @IBOutlet weak var disruptionDetailLabel: UILabel!

    var webkitAddress: String = "http://timetableapi.ptv.vic.gov.au/v3/disruptions/172753?devid=3001136&signature=0d109322726f7d0cdf172d376f062ba3fccf0353"
    
    
    
    @IBAction func viewInWebKit(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: webkitAddress)!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        Do any additional setup after loading the view.
        
        //Disruption sample detail page
        // http://timetableapi.ptv.vic.gov.au/v3/disruptions/172753?devid=3001136&signature=0d109322726f7d0cdf172d376f062ba3fccf0353
        
        let url = URL(string: "http://timetableapi.ptv.vic.gov.au/v3/disruptions/172753?devid=3001136&signature=0d109322726f7d0cdf172d376f062ba3fccf0353")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                print("Download failed: \(String(describing: error))")
                return
            }
            do {
                // Data recieved.  Decode it from JSON.
                let decoder = JSONDecoder()
                let disruptionDetail = try decoder.decode(disruptionDetailroot.self, from: data!)
                
                
                print(disruptionDetail.disruption?.disruptionId)
                print(disruptionDetail.disruption?.title)
                print(disruptionDetail.disruption?.description)
                self.disruptionTitleLabel.text = disruptionDetail.disruption?.title
                self.disruptionPublishDateLabel.text = "Publish Date: " +  (disruptionDetail.disruption?.publishDate)!
                self.disruptionStartDateLabel.text = "Effect From: " + (disruptionDetail.disruption?.startDate)!
                self.disruptionEndDateLabel.text = "Effect Until: " + (disruptionDetail.disruption?.endDate)!
                self.disruptionDetailLabel.text = disruptionDetail.disruption?.description
                self.webkitAddress = (disruptionDetail.disruption?.url)!
            } catch {
                print("Error:"+error.localizedDescription)
            }
        }
        task.resume()
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
