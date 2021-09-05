//
//  JourneyPlannerViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 11/6/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit
import WebKit

class JourneyPlannerViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    let journeyPlannerURL = URL(string: "https://www.ptv.vic.gov.au/journey")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: journeyPlannerURL!))
        
    }
}
