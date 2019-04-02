//
//  AuthManager.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 3/26/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


import SwiftyJSON
import Alamofire
import SDWebImage
/**
Authenticate

- sendLoginView request                     x
- receive response                          x
-if error then stop and display message     x
- request token                             x
-if error then stop and display message     x
- auth user on AVOSCloud                    x
- if existing user OK
- request WX user info
- update AVOSC user info
- store renew token and openid

END : CurrentUser set with full data
*/

class AuthManager {
    // MARK: - WeiXin API Public Methods
    
    class func loginWithMethod(_ method:AVOSCloudSNSType, completion:@escaping (_ success:Bool, _ error:NSError?)->()) {
        AVOSCloudSNS.logout(method)
        AVOSCloudSNS.login(callback: { (object, error) -> Void in
            if let error = error {
                completion(false, error as NSError?)
            } else if let dict = object  as? [AnyHashable: Any] {
                switch method {
                case AVOSCloudSNSType.snsWeiXin:
                    self.handleWechatAuth(dict, completion: completion)
                case AVOSCloudSNSType.snsSinaWeibo:
                    self.handleWeiboAuth(dict, completion: completion)
                default:
                    completion(false, nil)
                }
            }
            },toPlatform: method)
    }
    
    fileprivate class func handleWechatAuth(_ authData: [AnyHashable: Any], completion: @escaping (_ success:Bool, _ error:NSError?)->()) {
        UserDefaults.populateWithWechatData(authData)
        
        User.login(withAuthData: authData, platform: AVOSCloudSNSPlatformWeiXin, block: { (user, error) -> Void in
            if error != nil {
                completion(false, error as NSError?)
                return
            }
            
            guard let user = user as? User else {
                completion(false, nil)
                return
            }
            
            if user.openId != nil {
                completion(true, nil)
                return
            }
            
            WeixinApi.getUserInformations(forAccessToken: UserDefaults.getAccessToken()!, openid: UserDefaults.getOpenId()!, withCallback: { (dict: JSON?, err: NSError?) -> Void in
                if error != nil {
                    completion(false, error as NSError?)
                    return
                }
                
                guard let dict = dict else {
                    completion(false, nil)
                    return
                }
                
                user.openId = UserDefaults.getOpenId()
                user.populateWithWechatData(dict)
                user.saveInBackground({ (success, error) -> Void in
                    if !success {
                        completion(false, error as NSError?)
                        return
                    }
                    
                    guard let url = user.headImgUrl else {
                        user.saveInBackground({ (success, error) -> Void in
                            if error != nil {
                                completion(false, error as NSError?)
                                return
                            }
                            completion(true, nil)
                        })
                        return
                    }
                    
                    SDWebImageManager.shared().downloadImage(with: NSURL(string: url) as URL!, options: SDWebImageOptions.cacheMemoryOnly, progress: { (receive, total) in
                        
                        }, completed: { (image, error, cacheType, finish, requestUrl) in
                            if error != nil{
                                 completion(false, error as NSError?)
                            }else {
                                _ = Photo(image: image!, completion: { (photo) -> () in
                                    user.avatar = photo
                                    photo.saveInBackground({ (success, error) -> Void in
                                        user.saveInBackground({ (success, error) -> Void in
                                            if error != nil {
                                                completion(false, error as NSError?)
                                                return
                                            }
                                            completion(true, nil)
                                        })
                                    })
                                })
                            }
                    })
                })
            })
        })
    }

    fileprivate class func handleWeiboAuth(_ authData: [AnyHashable: Any], completion: @escaping (_ success:Bool, _ error:NSError?)->()) {
        UserDefaults.populateWithWeiboData(authData)
        User.login(withAuthData: authData, platform: AVOSCloudSNSPlatformWeiBo, block: { (user, error) -> Void in
            if error != nil {
                completion(false, error as NSError?)
                return
            }
             guard let user = user as? User else {
                completion(false, nil)
                return
            }
            
            if user.openId != nil {
                completion(true, nil)
                return
            }

            user.openId = UserDefaults.getOpenId()
            user.populateWithWeiboData(authData)

            guard let url = user.headImgUrl else {
                user.saveInBackground({ (success, error) -> Void in
                    if error != nil {
                        completion(false, error as NSError?)
                        return
                    }
                    completion(true, nil)
                })
                return
            }
            
            SDWebImageManager.shared().downloadImage(with: URL(string: url), options: SDWebImageOptions.cacheMemoryOnly, progress: { (receive, total) in
                
                }, completed: { (image, error, cacheType, finished, requestUrl) in
                    if error != nil{
                        completion(false, error as NSError?)
                        return
                    }
                    _ = Photo(image: image!, completion: { (photo) -> () in
                        user.avatar = photo
                        photo.saveInBackground({ (success, error) -> Void in
                            user.saveInBackground({ (success, error) -> Void in
                                if error != nil {
                                    completion(false, error as NSError?)
                                    return
                                }
                                completion(true, nil)
                            })
                        })
                    })
            })

        })
    }
}
