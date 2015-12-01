//
//  FeedEntryViewController.swift
//  CancerSN
//
//  Created by lily on 11/29/15.
//  Copyright © 2015 lily. All rights reserved.
//

import UIKit

class FeedEntryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let storyboard = UIStoryboard(name: "Feed", bundle: nil)
        let controller = storyboard.instantiateInitialViewController()!
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
