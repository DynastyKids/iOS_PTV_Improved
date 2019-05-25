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
    
    var disruptions: [Disruption] = []
    var routeType: [Int] = []
    var totalDisruptionItems: Int = 0
    var metroTrainDisruptionItems: Int = 0
    var metroTramDisruptionItems: Int = 0
    var metroBusDisruptionItems: Int = 0
    var vlineDisruptionItems: Int = 0
    
    var url = URL(string: disruptionAll())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Loading disruption data from PTV
        
        let task = URLSession.shared.dataTask(with: url!){(data, response, error) in
            if let error = error{
                print("fetching error: \(String(describing: error))")
                return
            }
            do{
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let disruptionData = try decoder.decode(DisruptionsResponse.self, from: data!)
                if (disruptionData.disruptions?.metroTrain?.count ?? 0 > 0){
                    self.disruptions = (disruptionData.disruptions?.metroTrain)!
                    for _ in 0 ..< (disruptionData.disruptions?.metroTrain?.count)! {
                        self.routeType.append(0)
                    }
                }
                if (disruptionData.disruptions?.metroTram?.count ?? 0 > 0){
                    self.disruptions += (disruptionData.disruptions?.metroTram)!
                    for _ in 0 ..< (disruptionData.disruptions?.metroTram?.count)! {
                        self.routeType.append(1)
                    }
                }
                if (disruptionData.disruptions?.metroBus?.count ?? 0 > 0){
                    self.disruptions += (disruptionData.disruptions?.metroBus)!
                    for _ in 0 ..< (disruptionData.disruptions?.metroBus?.count)! {
                        self.routeType.append(2)
                    }
                }
                if (disruptionData.disruptions?.vlineTrain?.count ?? 0 > 0){
                    self.disruptions += (disruptionData.disruptions?.vlineTrain)!
                    for _ in 0 ..< (disruptionData.disruptions?.vlineTrain?.count)! {
                        self.routeType.append(3)
                    }
                }
                if (disruptionData.disruptions?.vlineCoach?.count ?? 0 > 0){
                    self.disruptions += (disruptionData.disruptions?.vlineCoach)!
                    for _ in 0 ..< (disruptionData.disruptions?.vlineCoach?.count)! {
                        self.routeType.append(3)
                    }
                }
                if (disruptionData.disruptions?.regionalBus?.count ?? 0 > 0){
                    self.disruptions += (disruptionData.disruptions?.regionalBus)!
                    for _ in 0 ..< (disruptionData.disruptions?.regionalBus?.count)! {
                        self.routeType.append(2)
                    }
                }
                if (disruptionData.disruptions?.schoolBus?.count ?? 0 > 0){
                    self.disruptions += (disruptionData.disruptions?.schoolBus)!
                    for _ in 0 ..< (disruptionData.disruptions?.schoolBus?.count)! {
                        self.routeType.append(2)
                    }
                }
                if (disruptionData.disruptions?.telebus?.count ?? 0 > 0){
                    self.disruptions += (disruptionData.disruptions?.telebus)!
                    for _ in 0 ..< (disruptionData.disruptions?.telebus?.count)! {
                        self.routeType.append(2)
                    }
                }
                if (disruptionData.disruptions?.nightbus?.count ?? 0 > 0){
                    self.disruptions += (disruptionData.disruptions?.nightbus)!
                    for _ in 0 ..< (disruptionData.disruptions?.nightbus?.count)! {
                        self.routeType.append(2)
                    }
                }
                if (disruptionData.disruptions?.interstate?.count ?? 0 > 0){
                    self.disruptions += (disruptionData.disruptions?.interstate)!
                    for _ in 0 ..< (disruptionData.disruptions?.interstate?.count)! {
                        self.routeType.append(3)
                    }
                }
                if (disruptionData.disruptions?.skybus?.count ?? 0 > 0){
                    self.disruptions += (disruptionData.disruptions?.skybus)!
                    for _ in 0 ..< (disruptionData.disruptions?.skybus?.count)! {
                        self.routeType.append(2)
                    }
                }
                if (disruptionData.disruptions?.ferry?.count ?? 0 > 0){
                    self.disruptions += (disruptionData.disruptions?.ferry)!
                }
                if (disruptionData.disruptions?.taxi?.count ?? 0 > 0){
                    self.disruptions += (disruptionData.disruptions?.taxi)!
                }
                DispatchQueue.main.async {
                    self.totalDisruptionItems = self.disruptions.count
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
        cell.disruptionPublishDateLabel.text = "Last Update: " + Iso8601toString(iso8601Date: disruption.updateDate ?? "nil", withTime: true, withDate: true)
        
        switch routeType[indexPath.row] {
        case 0:
            cell.disruptionColourLabel.backgroundColor = changeColorByRouteType(routeType: 0)
            cell.disruptionColourLabel.textColor = changeColorByRouteType(routeType: 0)
        case 1:
            cell.disruptionColourLabel.backgroundColor = changeColorByRouteType(routeType: 1)
            cell.disruptionColourLabel.textColor = changeColorByRouteType(routeType: 1)
        case 2:
            cell.disruptionColourLabel.backgroundColor = changeColorByRouteType(routeType: 2)
            cell.disruptionColourLabel.textColor = changeColorByRouteType(routeType: 2)
        case 3:
            cell.disruptionColourLabel.backgroundColor = changeColorByRouteType(routeType: 3)
            cell.disruptionColourLabel.textColor = changeColorByRouteType(routeType: 3)
        default:
            cell.disruptionColourLabel.backgroundColor = UIColor.white
            cell.disruptionColourLabel.textColor = UIColor.white
        }
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
            page2.fetchAddress = disruptionById(disruptionId: (disruptions[tableView.indexPathForSelectedRow!.row]).disruptionId!)
            page2.routeType = routeType[tableView.indexPathForSelectedRow!.row]
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
