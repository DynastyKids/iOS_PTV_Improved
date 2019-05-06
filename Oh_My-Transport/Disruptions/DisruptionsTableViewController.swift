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



class DisruptionsTableViewController: UITableViewController {
    
    let hardcodedURL:String = "https://timetableapi.ptv.vic.gov.au"
    let hardcodedDevID:String = "3001122"
    let hardcodedDevKey:String = "3c74a383-c69a-4e8d-b2f8-2e4c598b50b2"
    
    let CELL_DISRUPTION = "disruptions"
    
    let disruptionNumbers: Int = 1;
    
    //Decodable只能解析，不能被编码

//    func swift4JSONParser() {
//        // 数据获取 Data Fetching
//        let urlStr: String = disruptionAll()
//        guard let fileURL = Bundle.main.url(forResource: urlStr, withExtension: nil),
//            let data = try? Data.init(contentsOf: fileURL) else{
//                fatalError("JSON File Fetch Failed")
//        }
//
//        // 利用JSONDecoder来解析JSON Data，解析成[Disruptions].self数组类型
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .iso8601
//        guard let disruptions = try? decoder.decode([disruptions].self, from: data) else{
//            fatalError("JSON Decode Failed")
//        }
//        print(disruptions)
//    }
//
    struct disruptioninfo: Decodable{
        var disruption_id: Int?
        var title: String?
        var url: String?
        var description: String
        var disruption_status: String?
        var disruption_type: String?
        var published_on: String?
        var last_updated: String?
        var from_date: String?
        var to_date: String?
        struct routes: Decodable{
            var route_type: Int16?
            var route_id: Int16?
            var route_name: String?
            var route_number: String?
            var route_gtfs_id: String?
            struct direction: Decodable{
                var route_direction_id: Int16?
                var direction_id: Int16?
                var direction_name: String?
                var service_time: String?
            }
        }
        struct stops:Decodable{
            var stop_id: Int16?
            var stop_name: String?
        }
        var colour: String?
        var display_on_board: Bool?
        var display_status: Bool?
    }
    struct disruptions: Decodable {
        var general: [disruptioninfo]
        var metro_train:[disruptioninfo]
        var metro_tram:[disruptioninfo]
        var metro_bus:[disruptioninfo]
        var regional_train: [disruptioninfo]
        var regional_coach: [disruptioninfo]
        var regional_bus:[disruptioninfo]
        var school_bus: [disruptioninfo]
        var telebus: [disruptioninfo]
        var nightbus: [disruptioninfo]
        var ferry: [disruptioninfo]
        var interstate: [disruptioninfo]
        var skybus: [disruptioninfo]
        var taxi:[disruptioninfo]
    }
    struct status: Decodable {
        var version: String
        var health: Int16
    }
    struct disruptionResults:Decodable {
        var disruptions: disruptions
        var status: [status]
        
    }
    
    func getDisruptionData(){
        if let url = URL(string: disruptionAll()) {
            let task = URLSession.shared.dataTask(with: url) { (data, response , error) in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let data = data, let disruption = try? decoder.decode(disruptions.self, from: data) {
                    for service in disruption.metro_train {
                        print(service)
                    }
                }else {
                    print(error)
                }
            }
            task.resume()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        getDisruptionData()
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//         #warning Incomplete implementation, return the number of rows
//        Return by json data count
        return disruptionNumbers
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_DISRUPTION, for: indexPath)

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
