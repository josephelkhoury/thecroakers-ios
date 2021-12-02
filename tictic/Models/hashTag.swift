//
//  hashTag.swift
//  MusicTok
//
//  Created by Mac on 04/02/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import Foundation

// MARK: - Hashtag
class Hashtag: Codable {
    var code: Int
    var msg: [hashtagMsg]

    init(code: Int, msg: [hashtagMsg]) {
        self.code = code
        self.msg = msg
    }
}

// MARK: - Msg
class hashtagMsg: Codable {
    var hashtag: HashtagClass

    enum CodingKeys: String, CodingKey {
        case hashtag = "Hashtag"
    }

    init(hashtag: HashtagClass) {
        self.hashtag = hashtag
    }
}

// MARK: - HashtagClass
class HashtagClass: Codable {
    var id, name: String
    var videosCount: Int
    var views: String?
    var favourite: Int

    enum CodingKeys: String, CodingKey {
        case id, name
        case videosCount = "videos_count"
        case views, favourite
    }

    init(id: String, name: String, videosCount: Int, views: String?, favourite: Int) {
        self.id = id
        self.name = name
        self.videosCount = videosCount
        self.views = views
        self.favourite = favourite
    }
}

