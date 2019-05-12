//
//  HomeViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 3/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit
import CommonCrypto
import Foundation
import CoreData

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var stopFetchedResultsController: NSFetchedResultsController<FavStop>!
    var routeFetchedResultsController: NSFetchedResultsController<FavRoute>!
    var filteredRoutes: [FavRoute] = []
    var filteredStops: [FavStop] = []
    var searchAllRoutes: [FavRoute] = []
    var searchAllStops: [FavStop] = []
    
    @IBOutlet weak var stopsTableView: UITableView!
    
    
    let hardcodedURL:String = "http://timetableapi.ptv.vic.gov.au"
    let hardcodedDevID:String = "3001122"
    let hardcodedDevKey:String = "3c74a383-c69a-4e8d-b2f8-2e4c598b50b2"
    
    // Testing path
    func createResultString(Pattern:String)->String{
        let hardcodedURL:String = "http://timetableapi.ptv.vic.gov.au"
        let hardcodedDevID:String = "3001122"
        let hardcodedDevKey:String = "3c74a383-c69a-4e8d-b2f8-2e4c598b50b2"
        let searchPattern:String = "/v3/search/"+Pattern+"?devid="+hardcodedDevID;
        let signature:String = searchPattern.hmac(algorithm: CryptoAlgorithm.SHA1, key: hardcodedDevKey);
        
        let resultString:String = hardcodedURL+searchPattern+"&signature="+signature;
        
        return resultString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return 2
        } else if section == 2 {
            return filteredStops.count
        } else {
            return filteredRoutes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        // Configure the cell...
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionName: String
        switch section {
        case 0:
            sectionName = NSLocalizedString("Nearby Stops:", comment: "Nearby stops")
        case 1:
            sectionName = NSLocalizedString("My Favorite Stops:", comment: "Favorite stops:")
        case 2:
            sectionName = NSLocalizedString("My favorite Routes:", comment: "favorite Route")
        default:
            sectionName = ""
        }
        return sectionName
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Search Function
//    func updateSearchResults(for searchController: UISearchController) {
//        if taskFetchedResultsController.fetchedObjects?.isEmpty == false{
//            searchAllTasks = taskFetchedResultsController.fetchedObjects!
//        }
//        if let searchText = searchController.searchBar.text?.lowercased(), searchText.count > 0{
//            filteredTasks = searchAllTasks.filter({(favorite: Favorite) -> Bool in
//                return (favorite.title?.lowercased().contains(searchText))!
//            })
//        }else{
//            filteredTasks = searchAllTasks;
//        }
//        tableView.reloadData()
//    }
    
    
}

struct homeDeparturesResponse: Codable {
    var departures: [homeDepartures]
    var status: homeStatus
    
    private enum CodingKeys: String, CodingKey{
        case departures
        case status
    }
}

struct homeDepartures: Codable{
    var stopsId: Int?
    var routesId: Int?
    var runId: Int?
    var directionId: Int?
    var disruptionIds: [Int]?
    var scheduledDepartureUTC: String?
    var estimatedDepartureUTC: String?
    var atPlatform: Bool
    var platformNumber: String?
    var flags: String?
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
        self.atPlatform = try container.decode(Bool.self, forKey: .atPlatform)
        self.platformNumber = try? container.decode(String.self, forKey: .platformNumber)
        self.flags = try? container.decode(String.self, forKey: .flags)
        self.departureSequence = try? container.decode(Int.self, forKey: .departureSequence)
    }
}

struct homeStatus: Codable {
    var version: String
    var health: Int
    
    private enum CodingKeys: String, CodingKey{
        case version
        case health
    }
}

enum CryptoAlgorithm {
    case MD5, SHA1
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:      result = kCCHmacAlgMD5
        case .SHA1:     result = kCCHmacAlgSHA1
        }
        return CCHmacAlgorithm(result)
    }
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:      result = CC_MD5_DIGEST_LENGTH
        case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
        }
        return Int(result)
    }
}


//// Database Controller Delegate - all-in-one
//extension TaskListTableViewController: NSFetchedResultsControllerDelegate{
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            if let indexPath = newIndexPath{
//                tableView.insertRows(at: [indexPath], with: .automatic)
//            }
//        case .delete:
//            if let indexPath = indexPath{
//                tableView.deleteRows(at: [indexPath], with: .automatic)
//            }
//        case .update:
//            if let indexPath = indexPath, let _ = tableView.cellForRow(at: indexPath){
//                _ = taskFetchedResultsController.object(at: indexPath)
//            }
//        default:
//            break
//        }
//    }
//}
