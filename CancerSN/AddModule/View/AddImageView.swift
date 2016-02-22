//
//  AddImageView.swift
//  CancerSN
//
//  Created by hui luo on 22/2/2016.
//  Copyright © 2016 lily. All rights reserved.
//

import UIKit

class AddImageView: UIView {
    
    let defaultAddImageBtn = UIButton()

    init(frame: CGRect, imageLength: CGFloat, target: UIViewController, action: Selector) {
        
        super.init(frame: frame)
        
        defaultAddImageBtn.frame = CGRect(x: 0, y: 0, width: imageLength, height: imageLength)
        let defaultAddImageView = UIImageView(frame: CGRECT(0, 0, imageLength, imageLength))
        defaultAddImageView.image = UIImage(named: "btn_addImage")
        defaultAddImageBtn.addSubview(defaultAddImageView)
        defaultAddImageBtn.addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(defaultAddImageBtn)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}