//
//  HelpPageViewController.swift
//  Oh_My-Transport
//
//  Created by OriWuKids on 22/6/19.
//  Copyright © 2019 wgon0001. All rights reserved.
//

import UIKit

class HelpPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    lazy var subViewControllers:[UIViewController] = {
        return [
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HelpPage1") as! HelpViewController,
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HelpPage2") as! HelpViewController,
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HelpPage3") as! HelpViewController,
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HelpPage4") as! HelpViewController,
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HelpPage5") as! HelpViewController,
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HelpPage6") as! HelpViewController
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self

        setViewControllers([subViewControllers[0]], direction: .forward, animated: true, completion: nil)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return subViewControllers.count
    }

    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex: Int = subViewControllers.index(of: viewController) ?? 0
        if currentIndex <= 0 {
            return nil
        } else {
            self.navigationItem.title = "Help Page (\(currentIndex)/\(subViewControllers.count))"
        }
        return subViewControllers[currentIndex-1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex: Int = subViewControllers.index(of: viewController) ?? 0
        if currentIndex >= subViewControllers.count-1 {
            return nil
        } else {
            self.navigationItem.title = "Help Page (\(currentIndex+2)/\(subViewControllers.count))"
        }
        return subViewControllers[currentIndex+1]
    }

}
