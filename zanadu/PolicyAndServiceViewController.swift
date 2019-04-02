//
//  PolicyAndServiceViewController.swift
//  Atlas
//
//  Created by Atlas on 15/12/30.
//  Copyright © 2015年 Atlas. All rights reserved.
//

import Foundation
class PolicyAndServiceViewController:FormViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        let textV = Bundle.main.loadNibNamed("PolicyAndService", owner: nil, options: nil)?.first as! UITextView
        textV.frame = CGRect(x: 16, y: Config.AppConf.navigationBarAndStatuesBarHeight, width: self.view.frame.size.width - 32, height: self.view.frame.size.height  - Config.AppConf.navigationBarAndStatuesBarHeight)
        textV.scrollRangeToVisible(NSMakeRange(0, 1))
        self.view.addSubview(textV)

        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.title = NSLocalizedString("Privacy Policy and Terms of Service", comment:"隐私政策与服务条款")
    }

    
}
