//
//  Auth.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 3/26/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON




typealias APICallback = ((JSON?, NSError?) -> ())

/// Have to redefine Weixin Objective C enum because not compatible with Swift
enum WXScene: Int32 {
    case wxSceneSession = 0
    case wxSceneTimeline = 1
}

class WeixinApi : NSObject {
    
    var authCallBack: APICallback?
    
    /**
    Singleton
    */
    class var instance: WeixinApi {
        struct Singleton {
            static let instance = WeixinApi()
        }
        return Singleton.instance
    }
    
    // MARK: - WeiXin API Methods
    
    /**
    Display Weixin auth interface
    */
//    class func requestAuth() {
//        if !WXApi.isWXAppInstalled() {
//            instance.authCallBack!(nil, NSError(domain: "cn.zanadu.zanadu", code: -1, userInfo: ["Description": "Weixin app not installed"]))
//        }
//        let REQ = SendAuthReq()
//        REQ.scope = "snsapi_userinfo"
//        let state = arc4random().description
//        print("req rand state: \(state)", terminator: "")
//        REQ.state = state
//        print("return: \(WXApi.sendReq(REQ))", terminator: "")
//    }
//    
    class func requestAccessTokenForCode(_ code: String) {
        sendRequest(to: Config.Weixin.TokenForCodeUrl, withParameters: ["appid": Config.Weixin.WXAppID, "secret": Config.Weixin.WXAppSecret, "code": code, "grant_type": "authorization_code"], andCallback: instance.authCallBack!)
    }
    
    class func requestAccessTokenForRefreshToken(_ refreshToken: String) {
        sendRequest(to: Config.Weixin.TokenForRefreshUrl, withParameters: ["appid": Config.Weixin.WXAppID, "refresh_token": refreshToken, "grant_type": "refresh_token"]) { (dict, error) -> () in
            
        }
    }
    
    class func checkAccessToken(_ accessToken: String, openid: String) {
        sendRequest(to: Config.Weixin.CheckTokenUrl, withParameters: ["openid": openid, "access_token": accessToken]) { (dict, error) -> () in
            
        }
    }
    
    class func getUserInformations(forAccessToken accessToken: String, openid: String, withCallback callback: @escaping APICallback) {
        sendRequest(to: Config.Weixin.UserInfoUrl, withParameters: ["openid": openid, "access_token": accessToken], andCallback: callback)
    }
    
    fileprivate class func sendRequest(to target:String, withParameters parameters: [String: String], andCallback callback: @escaping APICallback) {
        Alamofire.request(Config.Weixin.BaseUrl + target, parameters: parameters)
            .responseJSON { response -> Void in
                switch response.result {
                case .failure(let error):
                    callback(nil, NSError(domain: "network", code: -1, userInfo: [NSLocalizedDescriptionKey: "\(error)"]))
                case .success(let value):
                    let json = JSON(value)
                    callback(json, nil)
                }
        }
    }
    
    func shareToWechat(_ title: String, description: String, url: String? = nil,image: UIImage?, sharingMethod method: WXScene) {
        let message: WXMediaMessage = WXMediaMessage()
        message.title = title.characters.count >= Config.Weixin.WXMaxTitleSize ? title.substring(to: title.characters.index(title.startIndex, offsetBy: Config.Weixin.WXMaxTitleSize - 1)) : title
        message.description = description.characters.count >= Config.Weixin.WXMaxDescriptionSize ? description.substring(to: description.characters.index(description.startIndex, offsetBy: Config.Weixin.WXMaxDescriptionSize - 1)) : description
        message.setThumbImage(image)
        
        let object: WXWebpageObject = WXWebpageObject()
        object.webpageUrl = url != nil ? url : Config.Weixin.appUrl
        
        message.mediaObject = object
        
        let req:SendMessageToWXReq = SendMessageToWXReq()
        
        req.bText = false
        req.message = message
        req.scene = method.rawValue
        print("sharing return: \(WXApi.send(req))", terminator: "")
    }
    
    func shareRecommendation(_ recommendation: Recommendation, withImage image: UIImage, andSharingMethod method: WXScene) {
        guard let shortId = recommendation.shortId,
              let title = recommendation.title else {
            return
        }
        
        let urlString = Config.AppConf.SharingUrl + "/" + shortId
        
        let newImage = image.scaleToSize(CGSize(width: 100, height: 100))
        
        let description: String
        if let text = recommendation.text , text != "" {
            description = text
        } else {
            description = Config.Weixin.sharingRecommendationDescription
        }
        
        WeixinApi.instance.shareToWechat(title, description: description, url: urlString, image:newImage, sharingMethod: method)

        // leancloud AVAnalytics
        AVAnalytics.event( "share", label:"分享到好友")
    }
}

extension WeixinApi: WXApiDelegate {
    func onReq(_ req: BaseReq!) {
        print("onReq : ", terminator: "")
        print(req.description, terminator: "")
    }
    
    func onResp(_ resp: BaseResp!) {
        print("onResp : ", terminator: "")
        print(resp.description, terminator: "")
        
        // Authentication request response received
        //  0 == ERR_OK // -4 == ERR_AUTH_DENIED // -2 == ERR_AUTH_CANCEL
        guard let authResp = resp as? SendAuthResp else {
            if let shareResp = resp as? SendMessageToWXResp , shareResp.errCode < 0 {
                log.error("sharing error : \(shareResp.errCode) - \(shareResp.errStr)")
            }
            return
        }
        
        if authResp.errCode != 0 {
            authCallBack!(nil, NSError(domain: "cn.zanadu.zanadu", code: -2, userInfo: ["Description": "Weixin auth canceled"]))
        }
        
        if let authCode = authResp.code {
            WeixinApi.requestAccessTokenForCode(authCode)
        }
    }
}
