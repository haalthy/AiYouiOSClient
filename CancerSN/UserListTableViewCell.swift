//
//  UserListTableViewCell.swift
//  CancerSN
//
//  Created by lily on 7/22/15.
//  Copyright (c) 2015 lily. All rights reserved.
//

import UIKit

class UserListTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameDisplay: UILabel!
    @IBOutlet weak var userProfileDisplay: UILabel!
    
    @IBOutlet weak var userFollowers: UILabel!
    
    @IBAction func addFollowing(sender: AnyObject) {
        var keychainAccess = KeychainAccess();
        var username = keychainAccess.getPasscode("haalthyUsernameIdentifier")
        var password = keychainAccess.getPasscode("haalthyPasswordIdentifier")
        if((username != nil) && (password != nil)){
            print(keychainAccess.getPasscode("haalthyIdentifier")!)
        }else{
            println("show sign up")
 //           self.performSegueWithIdentifier("signup", sender: nil)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
