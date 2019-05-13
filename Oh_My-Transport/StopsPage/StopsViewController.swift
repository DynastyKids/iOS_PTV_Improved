//
//  StopsViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 3/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit

class StopsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var stopNameLabel: UILabel!
    @IBOutlet weak var nextServiceTableView: UITableView!
    @IBOutlet weak var disruptionButton: UIButton!
    @IBOutlet weak var runningMapButton: UIButton!
    
    @IBOutlet weak var showAllTransport: UIBarButtonItem!
    @IBOutlet weak var busOnlyButton: UIBarButtonItem!
    @IBOutlet weak var tramOnlyButton: UIBarButtonItem!
    @IBOutlet weak var trainOnlyButton: UIBarButtonItem!
    @IBOutlet weak var vlineOnlyButton: UIBarButtonItem!
    
    var stopURL: String = ""
    var nextDepartsURL: String = ""
    var routeType: Int = 0;
    
    let hardcodedURL:String = "https://timetableapi.ptv.vic.gov.au"
    let hardcodedDevID:String = "3001122"
    let hardcodedDevKey:String = "3c74a383-c69a-4e8d-b2f8-2e4c598b50b2"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch routeType {  //API PDF Page43
        case 0: //Train (metropolitan)
            view.backgroundColor = UIColor.init(red: 0.066, green: 0.455, blue: 0.796, alpha: 1)
            break
        case 1: //Tram
            view.backgroundColor = UIColor.init(red: 0.4784, green: 0.7372, blue: 0.1882, alpha: 1)
            break
        case 2: //Bus (metropolitan, regional and Skybus, but not V/Line)
            view.backgroundColor = UIColor.init(red: 0.993, green: 0.5098, blue: 0.1372, alpha: 1)
            break
        case 3: //  V/Line train and coach
            view.backgroundColor = UIColor.init(red: 0.5568, green: 0.1333, blue: 0.5765, alpha: 1)
            break
        case 4: //Night Bus (which replaced NightRider)
            view.backgroundColor = UIColor.init(red: 0.993, green: 0.5098, blue: 0.1372, alpha: 1)
            break
        default:
            view.backgroundColor = UIColor.white
        }

        nextServiceTableView.delegate = self
        nextServiceTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        let url = URL(string: stopURL)
        print(stopURL)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                print("Download failed: \(String(describing: error))")
                return
            }
            do {
                // Data recieved.  Decode it from JSON.
                let decoder = JSONDecoder()
                let stopDetail = try decoder.decode(stopResposeById.self, from: data!)
                DispatchQueue.main.async {
                    self.stopNameLabel.text = stopDetail.stop?.stopName
                    self.nextServiceTableView.reloadData()
                }
            } catch {
                print("Error:"+error.localizedDescription)
            }
        }
        task.resume()
        
        
//        let url = URL(string: nextDepartsURL)
//        print(nextDepartsURL)
//        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
//            if let error = error {
//                print("Download failed: \(String(describing: error))")
//                return
//            }
//            do {
//                // Data recieved.  Decode it from JSON.
//                let decoder = JSONDecoder()
//                let stopDetail = try decoder.decode(disruptionByIdResponse.self, from: data!)
//                DispatchQueue.main.async {
//                    //                    self.updateScreen(disruption: disruptionDetail.disruption!)
//                    self.nextServiceTableView.reloadData()
//                }
//            } catch {
//                print("Error:"+error.localizedDescription)
//            }
//        }
//        task.resume()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1    //Section to be fixed
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nextService", for: indexPath) as! upcomingServiceTableViewCell
        return cell
    }

}
