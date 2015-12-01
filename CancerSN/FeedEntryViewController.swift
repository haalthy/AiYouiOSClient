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

        var storyboard = UIStoryboard(name: "Feed", bundle: nil)
        var controller = storyboard.instantiateInitialViewController()!
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
