//
//  TagModel.swift
//  CancerSN
//
//  Created by lay on 16/1/18.
//  Copyright © 2016年 lily. All rights reserved.
//

import Foundation

@objc(TagModel)

class TagModel: D3Model {

    var typeRank: Int = 0
    var typeName: String!
    var tags: Array<SubTagModel>!
}