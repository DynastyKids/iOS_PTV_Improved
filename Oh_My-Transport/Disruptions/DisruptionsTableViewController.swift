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

// Struct has been moved to PTVdataStruct.swift

class DisruptionsTableViewController: UITableViewController {
    
    var disruptions: [disruption] = []
    
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
                let disruptionData = try decoder.decode(disruptionsResponse.self, from: data!)
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
//                print(disruptionData.disruptions?.metroTrain?.count)
                
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
