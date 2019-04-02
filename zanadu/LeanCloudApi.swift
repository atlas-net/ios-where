//
//  Data.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 3/26/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//




class LeanCloudApi {
    
    class func snsAuthenticationForWeixinAuthBlock(_ openid: String, accessToken: String, expiresIn: String, block:@escaping (AVUser?, Error?)->()) {
        let expires = Int(expiresIn)!
        let data: [AnyHashable: Any] = ["openid": openid, "access_token": accessToken, "expires_in": expires]
        User.login(withAuthData: data, platform: "weixin", block: block)
    }
}
