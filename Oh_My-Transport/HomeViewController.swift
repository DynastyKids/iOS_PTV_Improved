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

class HomeViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    var taskFetchedResultsController: NSFetchedResultsController<Favorite>!
    var filteredTasks: [Favorite] = []
    var searchAllTasks: [Favorite] = []
    var stops:[Stops]=[]
    
    @IBOutlet weak var nearByStops: UITableViewCell!
    @IBOutlet weak var favoriteStops: UITableViewCell!
    @IBOutlet weak var favoriteRoute: UITableViewCell!
    
    
    let hardcodedURL:String = "http://timetableapi.ptv.vic.gov.au"
    let hardcodedDevID:String = "3001122"
    let hardcodedDevKey:String = "3c74a383-c69a-4e8d-b2f8-2e4c598b50b2"
    
    // Testing path
    
    func createResultString(Pattern:String)->String{
        let hardcodedURL:String = "http://timetableapi.ptv.vic.gov.au"
        let hardcodedDevID:String = "3001122"
        let hardcodedDevKey:String = "3c74a383-c69a-4e8d-b2f8-2e4c598b50b2"
        let searchPattern:String = "/v3/search/"+Pattern+"?devid="+hardcodedDevID;
        let signature:String = searchPattern.hmac(algorithm: .SHA1, key: hardcodedDevKey);
        
        let resultString:String = hardcodedURL+searchPattern+"&signature="+signature;
        
        return resultString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView ==
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
    func updateSearchResults(for searchController: UISearchController) {
        if taskFetchedResultsController.fetchedObjects?.isEmpty == false{
            searchAllTasks = taskFetchedResultsController.fetchedObjects!
        }
//        if let searchText = searchController.searchBar.text?.lowercased(), searchText.count > 0{
//            filteredTasks = searchAllTasks.filter({(favorite: Favorite) -> Bool in
//                return (favorite.title?.lowercased().contains(searchText))!
//            })
//        }else{
//            filteredTasks = searchAllTasks;
//        }
//        tableView.reloadData()
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

extension String {
    func hmac(algorithm: CryptoAlgorithm, key: String) -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))
        
        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)
        
        let digest = stringFromResult(result: result, length: digestLen)
        
        result.deallocate(capacity: digestLen)
        
        return digest
    }
    
    private func stringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
        let hash = NSMutableString()
        for i in 0..<length {
            hash.appendFormat("%02x", result[i])
        }
        return String(hash)
    }


    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}
