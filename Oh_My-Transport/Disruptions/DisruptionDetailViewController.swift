//
//  DisruptionDetailViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 3/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit
import Foundation

struct disruptionByIdResponse: Codable{
    var disruption: Disruption?
    var status: Status?
    
    private enum CodingKeys: String, CodingKey{
        case disruption
        case status
    }
}

class DisruptionDetailViewController: UIViewController {
    
    @IBOutlet weak var disruptionTitleLabel: UILabel!
    @IBOutlet weak var disruptionPublishDateLabel: UILabel!
    @IBOutlet weak var disruptionStartDateLabel: UILabel!
    @IBOutlet weak var disruptionEndDateLabel: UILabel!
    @IBOutlet weak var disruptionDetailLabel: UILabel!

    var fetchAddress: String = ""
    var routeType: Int = 0
    
    @IBAction func viewInWebKit(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: fetchAddress)!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        Do any additional setup after loading the view.
        
        //Disruption sample detail page
        let url = URL(string: fetchAddress)
        print(fetchAddress)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                print("Download failed: \(String(describing: error))")
                return
            }
            do {
                // Data recieved.  Decode it from JSON.
                let decoder = JSONDecoder()
                let disruptionDetail = try decoder.decode(disruptionByIdResponse.self, from: data!)
                DispatchQueue.main.async {
                    self.updateScreen(disruption: disruptionDetail.disruption!)
                }
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
    
    func updateScreen(disruption:Disruption){
        self.disruptionTitleLabel.text = disruption.title
        self.disruptionTitleLabel.textColor = changeColorByRouteType(routeType: routeType)
        self.disruptionPublishDateLabel.text = "Publish Date: \(Iso8601toString(iso8601Date: disruption.publishDate ?? "Nil", withTime: false, withDate: true))"
        self.disruptionStartDateLabel.text = "Effect From: \(Iso8601toString(iso8601Date: disruption.startDate ?? "Nil", withTime: false, withDate: true))"
        if disruption.endDate == nil{
            self.disruptionEndDateLabel.text = ""
        }else{
            self.disruptionEndDateLabel.text = "Effect Until: \(Iso8601toString(iso8601Date: disruption.endDate ?? "Nil", withTime: false, withDate: true))"
        }
        self.disruptionDetailLabel.text = disruption.description
        self.fetchAddress = (disruption.url)!
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
