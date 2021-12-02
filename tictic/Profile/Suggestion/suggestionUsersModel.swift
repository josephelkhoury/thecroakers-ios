//
//  suggestionUsersModel.swift
//  MusicTok
//
//  Created by Mac on 01/06/2021.
//  Copyright © 2021 Mac. All rights reserved.
//

import Foundation

struct suggestionUsersModel : Codable {
    let id : String?
    let first_name : String?
    let last_name : String?
    let gender : String?
    let bio : String?
    let website : String?
    let dob : String?
    let social_id : String?
    let email : String?
    let phone : String?
    let password : String?
    let profile_pic : String?
    let role : String?
    let username : String?
    let social : String?
    let device_token : String?
    let token : String?
    let active : String?
    let lat : String?
    let long : String?
    let online : String?
    let verified : String?
    let auth_token : String?
    let version : String?
    let device : String?
    let ip : String?
    let city : String?
    let country : String?
    let city_id : String?
    let state_id : String?
    let country_id : String?
    let wallet : String?
    let paypal : String?
    let fb_id : String?
    let created : String?
    let followers_count : Int?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case first_name = "first_name"
        case last_name = "last_name"
        case gender = "gender"
        case bio = "bio"
        case website = "website"
        case dob = "dob"
        case social_id = "social_id"
        case email = "email"
        case phone = "phone"
        case password = "password"
        case profile_pic = "profile_pic"
        case role = "role"
        case username = "username"
        case social = "social"
        case device_token = "device_token"
        case token = "token"
        case active = "active"
        case lat = "lat"
        case long = "long"
        case online = "online"
        case verified = "verified"
        case auth_token = "auth_token"
        case version = "version"
        case device = "device"
        case ip = "ip"
        case city = "city"
        case country = "country"
        case city_id = "city_id"
        case state_id = "state_id"
        case country_id = "country_id"
        case wallet = "wallet"
        case paypal = "paypal"
        case fb_id = "fb_id"
        case created = "created"
        case followers_count = "followers_count"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        first_name = try values.decodeIfPresent(String.self, forKey: .first_name)
        last_name = try values.decodeIfPresent(String.self, forKey: .last_name)
        gender = try values.decodeIfPresent(String.self, forKey: .gender)
        bio = try values.decodeIfPresent(String.self, forKey: .bio)
        website = try values.decodeIfPresent(String.self, forKey: .website)
        dob = try values.decodeIfPresent(String.self, forKey: .dob)
        social_id = try values.decodeIfPresent(String.self, forKey: .social_id)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        phone = try values.decodeIfPresent(String.self, forKey: .phone)
        password = try values.decodeIfPresent(String.self, forKey: .password)
        profile_pic = try values.decodeIfPresent(String.self, forKey: .profile_pic)
        role = try values.decodeIfPresent(String.self, forKey: .role)
        username = try values.decodeIfPresent(String.self, forKey: .username)
        social = try values.decodeIfPresent(String.self, forKey: .social)
        device_token = try values.decodeIfPresent(String.self, forKey: .device_token)
        token = try values.decodeIfPresent(String.self, forKey: .token)
        active = try values.decodeIfPresent(String.self, forKey: .active)
        lat = try values.decodeIfPresent(String.self, forKey: .lat)
        long = try values.decodeIfPresent(String.self, forKey: .long)
        online = try values.decodeIfPresent(String.self, forKey: .online)
        verified = try values.decodeIfPresent(String.self, forKey: .verified)
        auth_token = try values.decodeIfPresent(String.self, forKey: .auth_token)
        version = try values.decodeIfPresent(String.self, forKey: .version)
        device = try values.decodeIfPresent(String.self, forKey: .device)
        ip = try values.decodeIfPresent(String.self, forKey: .ip)
        city = try values.decodeIfPresent(String.self, forKey: .city)
        country = try values.decodeIfPresent(String.self, forKey: .country)
        city_id = try values.decodeIfPresent(String.self, forKey: .city_id)
        state_id = try values.decodeIfPresent(String.self, forKey: .state_id)
        country_id = try values.decodeIfPresent(String.self, forKey: .country_id)
        wallet = try values.decodeIfPresent(String.self, forKey: .wallet)
        paypal = try values.decodeIfPresent(String.self, forKey: .paypal)
        fb_id = try values.decodeIfPresent(String.self, forKey: .fb_id)
        created = try values.decodeIfPresent(String.self, forKey: .created)
        followers_count = try values.decodeIfPresent(Int.self, forKey: .followers_count)
    }

}
