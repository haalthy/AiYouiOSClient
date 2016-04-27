//
//  HttpUrl.swift
//  CancerSN
//
//  Created by lay on 15/12/16.
//  Copyright © 2015年 lily. All rights reserved.
//

import Foundation

//restful service URL setting

let haalthyServiceRestfulURL : String = "http://content.haalthy.com/"

// MARK: - 智囊圈模块

let getSuggestUserByTagsURL = haalthyServiceRestfulURL + "open/user/suggestedusers"

// 获取所有tag
let getTagListURL = haalthyServiceRestfulURL + "open/tag/list"

// 用户未登录时，获取首页列表接口
let getBroadcastsByTagsURL = haalthyServiceRestfulURL + "open/post/tags"

// 获得内容详情接口
let getPostDetailURL = haalthyServiceRestfulURL + "open/post/getpost"

// 获取详情评论列表接口
let getCommentListByPostURL  = haalthyServiceRestfulURL + "open/comment/post/"

// 发送评论接口
let addCommentsURL = haalthyServiceRestfulURL + "security/comment/add"

// 搜索用户接口
let searchUserURL = haalthyServiceRestfulURL + "open/search/user"

// 搜索临床数据接口
let searchClinicURL = haalthyServiceRestfulURL + "open/search/clinictrail"

// 搜索治疗方案接口
let searchTreatmentURL = haalthyServiceRestfulURL + "open/search/treatment"

// MARK: - 我的奇迹模块

// 获取关注列表接口
let userFollowURL = haalthyServiceRestfulURL + "security/user/followusers"

// 获取@我的列表接口
let userMentionedURL = haalthyServiceRestfulURL + "security/post/mentionedpost/list"

// 获取未读新关注个数接口
let getNewFollowCountURL = haalthyServiceRestfulURL + "security/user/newfollow/count"

// 重置未读新关注个数为0接口
let refreshNewFollowCountURL = haalthyServiceRestfulURL + "security/user/newfollow/refresh"

// 获取未读被@我的个数接口
let getNewMentionedCountURL = haalthyServiceRestfulURL + "security/post/mentionedpost/unreadcount"

// 重置未读被@我的个数为0接口
let refreshNewMentionedCountURL = haalthyServiceRestfulURL + "security/post/mentionedpost/markasread"

// 获取未读新评论个数接口
let getNewCommentCountURL = haalthyServiceRestfulURL + "security/comment/unreadcommentscount"

// 重置未读新评论接口为0接口
let refreshNewCommentURL = haalthyServiceRestfulURL + "security/comment/readallcomments"

// 更新pushId

let pushIdURL = haalthyServiceRestfulURL + "open/push/jpushlogin"

let addNewUserURL = haalthyServiceRestfulURL + "open/user/add"
let getOauthTokenURL = haalthyServiceRestfulURL + "oauth/token"
let addFollowingURL = haalthyServiceRestfulURL + "security/user/follow/add/"
let getUserFavTagsURL = haalthyServiceRestfulURL + "security/user/tags"
let updateFavTagsURL = haalthyServiceRestfulURL + "security/user/tag/update"
let getPostByIdURL = haalthyServiceRestfulURL + "open/post/"
let addPostURL = haalthyServiceRestfulURL + "security/post/add"
let getFeedsURL = haalthyServiceRestfulURL + "security/post/posts"
let getTreatmentsURL = haalthyServiceRestfulURL + "open/patient/treatments/"
let getTreatmentformatURL = haalthyServiceRestfulURL + "open/patient/treatmentformat"
let addTreatmentURL = haalthyServiceRestfulURL + "security/patient/treatment/add"
let getPatientStatusFormatURL = haalthyServiceRestfulURL + "open/patient/patientstatusformat"
let getClinicReportFormatURL = haalthyServiceRestfulURL + "open/patient/clinicreportformat"
let addPatientStatusURL = haalthyServiceRestfulURL + "security/patient/patientStatus/add"
let getMyProfileURL = haalthyServiceRestfulURL + "security/user/"
let getSuggestUserByProfileURL:String = haalthyServiceRestfulURL + "security/user/suggestedusers"
let getUserDetailURL:String = haalthyServiceRestfulURL + "security/user/detail"
let getPostsByUsernameURL:String = haalthyServiceRestfulURL + "security/post/posts"
let resetPasswordURL:String = haalthyServiceRestfulURL + "security/user/resetpassword"
let resetPasswordWithCodeURL:String = haalthyServiceRestfulURL + "open/user/resetpasswordwithauthcode"
let getFollowingUserURL:String = haalthyServiceRestfulURL + "security/user/followingusers"
let getFollowerUserURL:String = haalthyServiceRestfulURL + "security/user/followerusers"
let getCommentsByUsernameURL:String = haalthyServiceRestfulURL + "security/post/comments"
let updateUserURL: String = haalthyServiceRestfulURL + "security/user/update"
let deleteFromSuggestedUserURL: String = haalthyServiceRestfulURL + "security/user/deletesuggesteduser"
let getUpdatedPostCountURL: String = haalthyServiceRestfulURL + "security/post/postcount"
let getBroadcastsByTagsCountURL = haalthyServiceRestfulURL + "open/post/tags/count"
let updateTreatmentURL = haalthyServiceRestfulURL + "security/patient/treatment/update"
let deleteTreatmentURL = haalthyServiceRestfulURL + "security/patient/treatment/delete"
let increaseNewFollowCountURL = haalthyServiceRestfulURL + "security/user/newfollow/increase"
let selectNewFollowCountURL = haalthyServiceRestfulURL + "security/user/newfollow/count"
let isFollowingUserURL = haalthyServiceRestfulURL + "security/user/follow/isfollowing"
let getUnreadMentionedPostCountURL = haalthyServiceRestfulURL + "security/post/mentionedpost/unreadcount"
let getMentionedPostListURL = haalthyServiceRestfulURL + "security/post/mentionedpost/list"
let markMentionedPostAsReadURL = haalthyServiceRestfulURL + "security/post/mentionedpost/markasread"
let getUsernameURL = haalthyServiceRestfulURL + "security/user/getusername"
let getUsersByDisplaynameURL = haalthyServiceRestfulURL + "security/user/getusersbydisplayname"
let getEmailAuthCodeURL = haalthyServiceRestfulURL + "open/authcode/emailsend"
let getPhoneAuthCodeURL = haalthyServiceRestfulURL + "open/authcode/smssend"
let checkEmailAuthCodeURL = haalthyServiceRestfulURL + "open/authcode/emailcheck"
let checkPhoneAuthCodeURL = haalthyServiceRestfulURL + "open/authcode/smscheck"
let getTopTagListURL = haalthyServiceRestfulURL + "open/tag/toplist"
let getPostsByUsername = haalthyServiceRestfulURL + "security/post/posts/username"
let getClinicTrailListURL = haalthyServiceRestfulURL + "open/clinictrail/list"
let addPostImageURL = haalthyServiceRestfulURL + "security/post/appendimage"
let addPatientImageURL =  haalthyServiceRestfulURL + "security/patient/appendimage"

let getCinicTrialDrugType = haalthyServiceRestfulURL + "open/clinictrail/drugtype"

let getCinicTrialSubGroup = haalthyServiceRestfulURL + "open/clinictrail/subgroup"

let getPatientStatusByID = haalthyServiceRestfulURL + "open/patient/patientstatus"

