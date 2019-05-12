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
    var disruption: disruption?
    var status: status?
    
    private enum CodingKeys: String, CodingKey{
        case disruption
        case status
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
}

struct disruptionByIdStops: Codable{
    var stopId: Int?
    var stopName: String?
    private enum CodingKeys: String, CodingKey{
        case stopId = "stop_id"
        case stopName = "stop_name"
    }
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

    var webkitAddress: String = ""
    
    @IBAction func viewInWebKit(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: webkitAddress)!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        Do any additional setup after loading the view.
        
        //Disruption sample detail page
        let url = URL(string: webkitAddress)
        print(webkitAddress)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                print("Download failed: \(String(describing: error))")
                return
            }
            do {
                // Data recieved.  Decode it from JSON.
                let decoder = JSONDecoder()
                let disruptionDetail = try decoder.decode(disruptionDetailroot.self, from: data!)
//                print(disruptionDetail.disruption?.disruptionId)
//                print(disruptionDetail.disruption?.title)
//                print(disruptionDetail.disruption?.description)
                self.updateScreen(disruption: disruptionDetail.disruption!)
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
    
    func updateScreen(disruption:disruption){
        self.disruptionTitleLabel.text = disruption.title
        self.disruptionPublishDateLabel.text = "Publish Date: " +  iso8601DateConvert(iso8601Date: disruption.publishDate ?? "Nil", withTime: false)
        self.disruptionStartDateLabel.text = "Effect From: " + iso8601DateConvert(iso8601Date: disruption.startDate ?? "Nil", withTime: true)
        if disruption.endDate == nil{
            self.disruptionEndDateLabel.text = ""
        }else{
            self.disruptionEndDateLabel.text = "Effect Until: " + iso8601DateConvert(iso8601Date: disruption.endDate ?? "Nil", withTime: true)
        }
        self.disruptionDetailLabel.text = disruption.description
        self.webkitAddress = (disruption.url)!
    }
    
    func iso8601DateConvert(iso8601Date: String, withTime: Bool?) -> String{
        if iso8601Date == "Nil"{
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
