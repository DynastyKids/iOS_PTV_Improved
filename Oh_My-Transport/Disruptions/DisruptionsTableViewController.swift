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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Loading disruption data from PTV
        let url = URL(string: disruptionAll());
        
        let task = URLSession.shared.dataTask(with: url!){(data, response, error) in
            if let error = error{
                print("fetching error: \(String(describing: error))")
                return
            }
            do{
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let disruptionData = try decoder.decode(DisruptionsResponse.self, from: data!)
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
            page2.fetchAddress = disruptionById(disruptionId: (disruptions[tableView.indexPathForSelectedRow!.row]).disruptionId!)
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
