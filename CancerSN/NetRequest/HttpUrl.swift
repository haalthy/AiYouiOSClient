//
//  HttpUrl.swift
//  CancerSN
//
//  Created by lay on 15/12/16.
//  Copyright © 2015年 lily. All rights reserved.
//

import Foundation

//restful service URL setting

//let haalthyServiceRestfulURL : String = "http://54.223.70.160:8080/haalthyservice/"
let haalthyServiceRestfulURL : String = "http://192.168.11.119:8080/haalthyservice/"

let haalthyServiceSolrURL : String = "http://54.223.70.160:8983/solr/aiyoupost/"
let queryPostBodyURL = haalthyServiceSolrURL + "select?wt=jason&indent=true&q=body%3A"

// MARK: - 智囊圈模块

let getSuggestUserByTagsURL = haalthyServiceRestfulURL + "open/user/suggestedusers"

// 获取所有tag
let getTagListURL = haalthyServiceRestfulURL + "open/tag/list"

// 用户未登录时，获取首页列表接口
let getBroadcastsByTagsURL = haalthyServiceRestfulURL + "open/post/tags"


let addNewUserURL = haalthyServiceRestfulURL + "open/user/add"
let getOauthTokenURL = haalthyServiceRestfulURL + "oauth/token"
let addFollowingURL = haalthyServiceRestfulURL + "security/user/follow/add/"
let getUserFavTagsURL = haalthyServiceRestfulURL + "security/user/tags"
let updateFavTagsURL = haalthyServiceRestfulURL + "security/user/tag/update"
let addCommentsURL = haalthyServiceRestfulURL + "security/comment/add"
let getCommentListByPostURL  = haalthyServiceRestfulURL + "open/comment/post/"
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
let refreshNewFollowCountURL = haalthyServiceRestfulURL + "security/user/newfollow/refresh"
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


