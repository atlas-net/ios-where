//
//  Config.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 3/26/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import Foundation
import UIKit

typealias JSONDictionary = [String: AnyObject]

#if DEVELOPMENT
    let DEVELOPMENT = true
#else
    let DEVELOPMENT = false
#endif


/**
 Source of the data
 
 - Where:      Where internal API
 - Baidu:      Baidu POI API
 - Foursquare: Foursquare Venue API
 */
enum SearchDataSource {
    case `where`
    case baidu
    case foursquare
}

/**
 Type of search data
 
 - Photo:  Search around photo location
 - User:   Search around User location
 - Global: Global search (location independant)
 */
enum SearchDataType {
    case photo
    case user
    case global
}

/**
Config class contains constants for :

- Weixin SDK
- AVOSCloud SDK
- App data
- App conf
- Colors
*/
class Config {
    
//    #if DEBUG
//        let DefaultDebugLevel = DDLogLevel.All
//    #else
//        let DefaultDebugLevel = DDLogLevel.Warning
//    #endif
    
    
    struct App {
        static let Name = "Where"
        static let BundleId = Bundle.main.bundleIdentifier ?? "cn.zanadu.where"
        static let IconName = "AppIcon60x60"
    }
    
    /**
     Demo account used by Apple Validation Team
     */
    struct Demo {
        static let number = "18511134590"
        static let code = "49913"
    }
    
    /**
    Weixin constants
    */
    struct Weixin {
        static let WXAppID = "wx0f9942aafa48977b"
        static let WXAppSecret = "cf13c0666a5be9e9641852edd563644b"

        static let WXMaxTitleSize = 512
        static let WXMaxDescriptionSize = 300
        
        static let appUrl = "http://Atlas.cn"
//        static let appIcon = UIImage(named: "7-140223103130591.png")
        
        static let sharingRecommendationTitle = "Recommendation From Atlas app"
        static let sharingRecommendationDescription = ""

        static let sharingFriendTitle = "在app store下载Where"
        static let sharingFriendDescription = "给我的推荐点赞"
        
        static let BaseUrl = "https://api.weixin.qq.com/sns"
        static let TokenForCodeUrl = "/oauth2/access_token?"
        static let TokenForRefreshUrl = "/oauth2/refresh_token?"
        static let CheckTokenUrl = "/auth?"
        static let UserInfoUrl = "/userinfo?"
    }

    struct SinaWeibo {
        static let SWAppID = /*"1538227249"*/"2421840635"
        static let SWAppSecret = /*"e23240fbb2c30ca08298d9cb00b0647f"*/"a013cb7de9c87471b2b4c80c1de117f4"
        static let redirectUrl = "http://wanpaiapp.com/oauth/callback/sina"
    }
    
    /**
    AVOSCloud constants
    */
    struct AVOSCloud {
        static let AVOSAppID = "19SkmeWi4b3YfOpj9QCMT3xx-gzGzoHsz"
        static let AVOSAppKey = "4TBsKfxcNcSTQqRiOE50bkSg"
        
        static let AVOSAppID_Dev = "AiJo4NCJT1VcvsxWr20mLYhv-gzGzoHsz"
        static let AVOSAppKey_Dev = "fvSeRiIm0xLniQW841oOxErb"
        
        static let UserTribesAVRelation = "userTribes"
        static let UserLikesAVRelation = "userLikes"
        static let RecommendationTribesAVRelation = "tribes"
        static let RecommendationTagsAVRelation = "tags"
        static let RecommendationPhotosAVRelation = "photos"
        static let RecommendationCategoryAVRelation = "category"

    }
    
    /**
    Baidu
    */
    struct Baidu {
        static let Key = "BG972Dz6XYBwzycNv9341XAG"
        static let BaiduBaseUrl = "http://api.map.baidu.com"

        static let SearchBaseUrl = BaiduBaseUrl + "/place/v2"
        static let GeocodingBaseUrl = BaiduBaseUrl + "/geocoder/v2/"
        
        static let PlaceSearchUrl = SearchBaseUrl + "/search"
        static let PoiSearchUrl = SearchBaseUrl + "/detail"
        static let PlaceSuggestionUrl = SearchBaseUrl + "/suggestion"
    }
    
    /**
    AppData (NSUserStorage) constants
    */
    struct AppData {
        static let Group = "group.zanadu.zanadu"
        
        struct AuthData {
            static let AccessToken = "acces_token"
            static let RefreshToken = "refresh_token"
            static let Openid = "openid"
        }
    }
    
    struct AppConf {
        static let DefaultUsernamePrefix = "where_"
        static let PhotoAlbumName = "Where"
        static let SharingUrl = "http://where.zanadu.cn"
        static let MinTribesPerUser = 1
        static let MaxTribesPerRecommendation = 3
        static let MinPhotoPerRecommendation = 1
        static let MaxPhotoPerRecommendation = 20
        static let PhotoCompressionFactor: CGFloat = 0.5
        static let PhotoMaxResolution: CGFloat = 2048
        static let SmallCornerRadiusFactor: CGFloat = 1/120
        static let MinTextScaleFactor = 0.8
        static let navigationBarAndStatuesBarHeight:CGFloat = 0
        static let navigationBarHeight:CGFloat = 44
        static let defaultUserAvatar = "user_default_avatar"
        static let defaultUserCover = "user_default_cover"
        static let StatusBarHeight:CGFloat = 20
        static let ScreenWidth:CGFloat = UIScreen.main.bounds.size.width
    }
    
    struct VenueSearch {
    
        static let SearchRadius = 10000
        static let VenuesPerPage = 20
        static let QueryTags = "酒店$餐厅$美食$酒吧$景点$购物$休闲娱乐$电影$演出$咖啡厅"
        
        static let scoreMatrix: [SearchDataSource:[SearchDataType:Float]] = [
            .where : [
                .photo: 0.994,
                .user: 0.974,
                .global: 0.934
            ],
            .baidu : [
                .photo: 0.923,
                .user: 0.723,
                .global: 0.423
            ],
            .foursquare : [
                .photo: 0.812,
                .user: 0.612,
                .global: 0.312
            ]
        ]
    }
    
    struct FormValidation {
        static let UsernameMinCharacters = 2
        static let UsernameMaxCharacters = 20
        static let UserMessageMinCharacters = 0
        static let UserMessageMaxCharacters = 20
    }
    
    
    struct Colors {
        /// Dark Pink : often used for buttons
        static let ZanaduCerisePink = UIColor(red:221/255, green:74/255, blue:116/255, alpha:1)
        /// Grey : used for disabled buttons (TODO:remove?)
        static let ZanaduGrey = UIColor(red: 169/255, green: 169/255, blue: 169/255, alpha: 1)
        
        
        /// Grey : often used for texts (or background)
        static let PaynesGrey = UIColor(red:0.25, green:0.26, blue:0.28, alpha:1)
        static let DarkJungleGreen = UIColor(red:0.11, green:0.13, blue:0.14, alpha:1)
        
        
        /// Dark Grey : used for backgrounds
        static let ZanaduShark = UIColor(red:0.15, green:0.16, blue:0.17, alpha:1)
        /// Ligh Grey : used for backgrounds
        static let ZanaduAluminum = UIColor(red:0.6, green:0.6, blue:0.6, alpha:1)
        /// Used for fields background
        static let ZanaduOpacity = CGFloat(0.6)
        
        /// Used for images overlay
        static let ImagesDarkOverlayColor = UIColor.black
        static let ImagesDarkOverlayAlpha = CGFloat(0.23)
        
        static let TagViewColor = UIColor(red:93/255.0, green:181/255.0, blue:193/255.0, alpha:1)
        
        static let TagViewBackground = UIColor(red:0.12, green:0.12, blue:0.12, alpha:1)
        static let TagFieldBackground = UIColor.white
        
        static let ButtonLightPink = UIColor(red:0.93, green:0.31, blue:0.49, alpha:1)
        static let ButtonDarkPink = UIColor(red:0.92, green:0.2, blue:0.41, alpha:1)

        static let SeparatorMiddleColor = UIColor(red:0.16, green:0.16, blue:0.16, alpha:1)
        static let SeparatorBorderColor = UIColor(red:0.15, green:0.15, blue:0.15, alpha:1)
        
        /// Used for texts and button borders
        static let LightGreyTextColor = UIColor(red:0.6, green:0.6, blue:0.6, alpha:1)

        /// Used for texts and button borders
        static let DarkGreyTextColor = UIColor(red:0.4, green:0.4, blue:0.4, alpha:1)
        ///used for root section title
        static let  SectionTextColor = UIColor(bd_hexColor: "000000")
        static let  SectionImageItemColor = UIColor(bd_hexColor: "999999")
        static let  FirstTitleColor = UIColor(bd_hexColor: "000000")
        static let  MainContentColorBlack = UIColor(bd_hexColor: "333333")
        static let  SecondTitleColor = UIColor(bd_hexColor: "999999")
        static let  GrayIconAndTextColor = UIColor(bd_hexColor: "d1d1d1")
        static let  GrayBackGroundWithAlpha = UIColor(bd_hexColor: "d1d1d1").withAlphaComponent(0.4)
        static let MainContentBackgroundWhite = UIColor(bd_hexColor: "f2f2f2")
        /// Used for texts and button borders
        /// RGB(100, 115, 145), CSS(#647391)
        static let DarkBlueTextColor = UIColor(red:0.392157, green:0.450980, blue:0.568627, alpha:1)
        static let LightBlueTextColor = UIColor(red:0.47, green:0.53, blue:0.63, alpha:1)
        
        static let ButtonGradient = [ButtonLightPink.cgColor, ButtonDarkPink.cgColor]
        static let SeparatorGradient = [SeparatorBorderColor.cgColor, SeparatorMiddleColor.cgColor, SeparatorBorderColor.cgColor]
        
        static let CommentTimeColor = UIColor(bd_hexColor: "F2F2F2")
        static let CommentSeparatorColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:0.3)
        static let CommentatorsNameColor = UIColor(bd_hexColor: "e03d6d")
        
        static let LikeLineColor = UIColor(bd_hexColor: "e9e9e9")

        //Used for global SearchBar
        static let TextFieldBackgroudColor = UIColor(bd_hexColor:"ffffff58")
        static let PlaceHolderColor = UIColor(bd_hexColor:"bbb8b8")
        static let CateCellBackgroudColor = UIColor(bd_hexColor:"ffffff57")
        static let CateCellHightliedTextColor = UIColor(bd_hexColor:"f43873")
        
        static let CateCellTextColor = UIColor(bd_hexColor:"444242")
        static let CateCellHighliedTextColor = UIColor(bd_hexColor:"f43873")
        static let SearchTextColor = UIColor(bd_hexColor:"ed366a")
        
        static let HistoryTitleColor = UIColor(bd_hexColor:"ee6a90")
        static let HistoryLabelTextColor = UIColor(bd_hexColor:"d7d5d5")
        
        static let HotSearchTitleColor = UIColor(bd_hexColor:"b9b5b5")
        
        
        static let PostDetailDesFiledEditColor = UIColor(red:255/255.0, green:255/255.0, blue:255/255.0, alpha:0.25)
        
        static let DestinationNormalColor = UIColor(bd_hexColor : "e7e7e7")
        static let DestinationHighiledColor = UIColor(bd_hexColor : "f43672")
        
        //destination DetailView
        static let TextfieldTextColor = UIColor(bd_hexColor : "5c5b5b")
        static let TextfieldBackgrounColor = UIColor(bd_hexColor : "ffffffdb")

        static let RecommendFriendsBackColor = UIColor(bd_hexColor : "ffffff14")

    }
    
    struct Sizes {
        static let tribeFlagSize = CGSize(width: 156, height: 239)
        static let tribeHomeFlagSize = CGSize(width: 186, height: 294)
    }
    
    struct Strings {
        
        // LABELS
        
        static let RegistrationLabel = NSLocalizedString("Register", comment: "")
        static let GetSMSButtonLabel = NSLocalizedString("Send SMS", comment: "")
        static let UserTribeChoosingDescriptionLabel = NSLocalizedString("Please choose at most 3 tribes, you will be able to change it in your profile", comment: "")
        static let RecommendationTribeChoosingDescriptionLabel = NSLocalizedString("Select the tribes where you want to publish", comment: "")

        
        // PLACEHOLDERS
        
        static let SMSCodeFieldPlaceholder = NSLocalizedString("Verification code", comment: "验证码")
        static let PhoneFieldPlaceholder = NSLocalizedString("Phone Number", comment: "手机号")
        static let descriptionFieldPlaceholder = NSLocalizedString("Write something", comment: "写点什么...")
        
        // ALERTS
        
        static let IncorrectPhoneNumberErrorTitle = NSLocalizedString("Incorrect phone number", comment: "")
        static let IncorrectPhoneNumberErrorMessage = NSLocalizedString("Please check your phone number and try again", comment: "")
        
        static let EmptyFieldErrorTitle = NSLocalizedString("Empty field", comment: "")
        
        static let PhoneNumberLengthErrorAlertTitle = NSLocalizedString("Incorrect phone number length", comment: "")
        static let PhoneNumberLengthErrorAlertMessage = NSLocalizedString("Your phone number should have 11 digits", comment: "")
        
        static let NoPhoneNumberErrorAlertTitle = NSLocalizedString("No phone number", comment: "")
        static let NoPhoneNumberErrorAlertMessage = NSLocalizedString("Please enter your phone number", comment: "")

        static let NoSMSCodeErrorTitle = NSLocalizedString("No SMS Code", comment: "")
        static let NoSMSCodeErrorMessage = NSLocalizedString("Please write the code you received by SMS", comment: "")
        
        static let WrongSMSCodeErrorTitle = NSLocalizedString("Wrong SMS Code", comment: "")
        static let WrongSMSCodeErrorMessage = NSLocalizedString("The SMS code is incorrect. Please check the SMS you received", comment: "")
        
        static let NetworkErrorAlertTitle = NSLocalizedString("Network error", comment: "")
        static let NetworkErrorAlertMessage = NSLocalizedString("Please check your network settings and try again", comment: "")
        
        static let MaxTribePerRecommendationWarningAlertTitle = NSLocalizedString("Tribe picking limit", comment: "")
        static let MaxTribePerRecommendationWarningAlertMessage = NSLocalizedString("Please pick up to 3 tribes", comment: "")
        
        static let AlertValidationLabel = NSLocalizedString("OK", comment: "")
        static let AlertConfirmationLabel = NSLocalizedString("Apply", comment: "")
        
        static let NoPhotoLibraryAccessAlertTitle = "照片权限"
        static let NoPhotoLibraryAccessAlertMessage = "where还没有获取照片权限，请去设置进行修改"
        
        //default three zanadu author id
        static let ZanaduTravelLife = "568b4e0860b2a099cde722b2"//赞那度旅行人生
        static let Zanadu = "55814db8e4b035745ad64add"//赞那度
        static let Where = "56931d5860b2638510a2c1fd"//where
    }
    struct locals {
        static let RecentTagIds = "RecentTagIds"
    }
}
