//
//  CreationSharingViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/6/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



class CreationSharingViewController: BaseViewController {
    
    //MARK: - Properties
    
    var recommendation: Recommendation!
    var coverImage = UIImage()
    
    @IBOutlet weak var shareViewContainers: UIView!
    var shareView:ShareView?
    
    let sharingMethods: [[String:AnyObject?]] = [
        [
            "icon" : UIImage(named:"C_12_2_Wechat_Post.png"),
            "label" :NSLocalizedString("Wechat friends", comment:"微信好友") as Optional<AnyObject>,
            "method" : Int(WXScene.wxSceneSession.rawValue) as Optional<AnyObject>
        ],
        [
            "icon" : UIImage(named:"C_12_2_WechatMoment.png"),
            "label" :NSLocalizedString("Moment", comment:"朋友圈") as Optional<AnyObject>,
            "method" : Int(WXScene.wxSceneTimeline.rawValue) as Optional<AnyObject>
        ]
    ]
    var selectSharingMethod: WXScene?
    
    //MARK: - Outlets
    @IBOutlet weak var sendBtn: UIButton!
    
    //MARK: - Initializers
    
    
    //MARK: - Actions
    
    @IBAction func onSendButtonClick(_ sender: UIButton) {
        
        navigationController?.dismiss(animated: true, completion: nil)
        RecommendationFactory.delete()
        
    }
    
    //MARK: - Methods
    
    
    //MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupShareView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool)  {
        super.viewWillDisappear(animated)
    }
    func setupShareView(){
        self.shareView = Bundle.main.loadNibNamed("ShareView", owner: self, options: nil)?[0] as? ShareView
        if let shareV = self.shareView {
            shareV.tapDelegate = self
            shareV.hideView()
            shareV.backgroundView.backgroundColor = UIColor.clear
            shareV.frame = CGRect(x: 0, y: shareViewContainers.frame.size.height - shareV.bounds.size.height, width: UIScreen.main.bounds.size.width, height: shareV.frame.size.height)
            self.shareViewContainers.addSubview(shareV)
        }
    }

    //scale image
    func scaleToSize(_ image: UIImage) -> UIImage{
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}



extension CreationSharingViewController : ShareViewTapDelegete{
    
    func shareViewTapDelegeteWillCancel() {}
    func shareViewTapDelegateCoverTapped() {}
    
    func shareViewTapDelegeteWillShareToWechatSession() {
        shareToWechat(WXScene.wxSceneSession)
    }
    
    func shareViewTapDelegeteWillShareToWechatTimeLine() {
        shareToWechat(WXScene.wxSceneTimeline)
    }
    
    func shareToWechat(_ sharingMethod:WXScene) {
        guard let recommendation = recommendation else { return }
        guard let _ = recommendation.shortId,
            let _ = recommendation.title else {
                recommendation.fetchInBackground({ (obj, error) in
                    if error == nil{
                        if let recommendation = obj as? Recommendation{
                                               WeixinApi.instance.shareRecommendation(recommendation, withImage: self.coverImage, andSharingMethod: sharingMethod)
                        }
                    }
                })
                return
        }
        WeixinApi.instance.shareRecommendation(recommendation, withImage: coverImage, andSharingMethod: sharingMethod)
    }
}
