//
//  CommentModel.swift
//  CancerSN
//
//  Created by lay on 16/2/16.
//  Copyright © 2016年 lily. All rights reserved.
//

import UIKit

@objc(CommentModel)

class CommentModel: D3Model {

    var commentID: Int = 0
    var postID: Int = 0
    var insertUsername: String!
    var body: String!
    var countBookmarks: Int = 0
    var dateInserted: Int64 = 0
    var isActive: Int = 0
    var imageURL: String!
}
