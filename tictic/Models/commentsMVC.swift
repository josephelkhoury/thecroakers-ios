//
//  commentsMVC.swift
//  TIK TIK
//
//  Created by Mac on 15/09/2020.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
struct commentNew {
    let id:String
    let userName:String
    let userID:String
    let comment:String
    let imgName:String
    let time:String
    var like:String
    var like_count:String
    let vidID:String
    let commentID:String
    let repliesCount:String
    var repliesArr:[commentNew]?
    var expanded:Bool
}
