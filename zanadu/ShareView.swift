//
//  ShareView.swift
//  Atlas
//
//  Created by Atlas on 16/2/2.
//  Copyright © 2016年 Atlas. All rights reserved.
//

import Foundation

protocol ShareViewTapDelegete {
    func shareViewTapDelegeteWillShareToWechatSession()
    func shareViewTapDelegeteWillShareToWechatTimeLine()
    func shareViewTapDelegeteWillCancel()
    func shareViewTapDelegateCoverTapped()
}

class ShareView: UIView {
    
    var tapDelegate : ShareViewTapDelegete?
    
    @IBOutlet weak var lineViewUp: UIView!
    @IBOutlet weak var lineViewDown: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var coverView: UIView!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBAction func wechatTimeLineBtnClick(_ sender: AnyObject) {
        if let delegate = tapDelegate {
            delegate.shareViewTapDelegeteWillShareToWechatTimeLine()
        }
    }
    
    @IBAction func wechatSeesionBtnClick(_ sender: AnyObject) {
        if let delegate = tapDelegate {
            delegate.shareViewTapDelegeteWillShareToWechatSession()
        }
    }
    
    @IBAction func cancelBtnClick(_ sender: AnyObject) {
        if let delegate = tapDelegate {
            delegate.shareViewTapDelegeteWillCancel()
        }
    }
   func commentSetting(){
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ShareView.onCoverTapped))
    self.coverView.addGestureRecognizer(tap)
    }
    
    func onCoverTapped() {
        if let delegate = tapDelegate {
            delegate.shareViewTapDelegateCoverTapped()
        }
        
    }
    
    func hideView() {
        self.lineViewUp.isHidden = true
        self.lineViewDown.isHidden = true
        self.cancelBtn.isHidden = true
    }
}

