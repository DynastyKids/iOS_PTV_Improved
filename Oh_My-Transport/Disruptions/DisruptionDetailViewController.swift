//
//  DisruptionDetailViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 3/5/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit
//import WebKit

class DisruptionDetailViewController: UIViewController {
    
    @IBOutlet weak var disruptionTitleLabel: UILabel!
    @IBOutlet weak var disruptionPublishDateLabel: UILabel!
    @IBOutlet weak var disruptionStartDateLabel: UILabel!
    @IBOutlet weak var disruptionEndDateLabel: UILabel!
    @IBOutlet weak var disruptionDetailLabel: UILabel!

    

//    var webView: WKWebView!
//
    @IBAction func viewInWebKit(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://ptv.vic.gov.au/live-travel-updates/article/cranbourne-and-pakenham-lines-service-alterations-from-9-20am-to-7-15pm-on-sunday-12-may-2019")!)
//        webkitview.isHidden = false
//        doneButton.isEnabled = true
    }
//
//    @IBAction func dismissWebKit(_ sender: Any) {
//        doneButton.isEnabled = false
//        webkitview.isHidden = true
//    }
    
//    override func loadView() {
//        //创建网页加载的偏好设置
//        let prefrences = WKPreferences()
//        prefrences.javaScriptEnabled = false
//
//        //配置网页视图
//        let webConfiguration = WKWebViewConfiguration()
//        webConfiguration.preferences = prefrences
//
//        webView = WKWebView(frame: .zero, configuration: webConfiguration)
//        webView.navigationDelegate = self as? WKNavigationDelegate;
//        view = webView
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        // Do any additional setup after loading the view.
        let myURL = URL(string: "http://ptv.vic.gov.au/live-travel-updates/article/frankston-line-buses-replacing-trains-from-8-10pm-to-last-train-on-tuesday-14-may-2019")
//        let myRequest = URLRequest(url: myURL!)
//        webView.load(myRequest)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//// MARK: WKNavigationDelegate
//extension UIViewController: WKNavigationDelegate {
//    //视图开始载入的时候显示网络活动指示器
//    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//    }
//
//    //载入结束后，关闭网络活动指示器
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }
//
//    //阻止链接被点击
//    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
//        if navigationAction.navigationType == .linkActivated {
//            decisionHandler(.cancel)
//
//            let alertController = UIAlertController(title: "Action not allowed", message: "Tapping on links is not allowed. Sorry!", preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            present(alertController, animated: true, completion: nil)
//            return
//        }
//        decisionHandler(.allow)
//    }
//}
