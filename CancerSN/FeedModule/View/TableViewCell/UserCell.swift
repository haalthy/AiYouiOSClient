//
//  UserCell.swift
//  CancerSN
//
//  Created by lay on 16/2/18.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var portraitImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.initContentView()
    }
    
    // MARK: - 初始化相关view
    
    func initContentView() {
    
        
        self.portraitImage.layer.cornerRadius = self.portraitImage.frame.width / 2
        self.portraitImage.clipsToBounds = true
        
        self.addBtn.layer.cornerRadius = 4.0
        self.addBtn.layer.borderColor = RGB(222, 228, 229).CGColor
        self.addBtn.layer.borderWidth = 2.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
