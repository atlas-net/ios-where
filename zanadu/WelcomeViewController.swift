//
//  ViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 3/19/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import UIKit
import Foundation
import EAIntroView
import Cartography

class WelcomeViewController: UIViewController {
    
    //MARK: - Properties
    var introView:EAIntroView?
    var spinner: SARMaterialDesignSpinner?
    var view1 = IntroPage()
    var view2 = IntroPage()
    var view3 = IntroPage()
    var view4 = IntroPage()
    var bgView: UIView?
    
    //MARK: - ViewController's Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if !AppDelegate.isFirstLaunch(){
            Router.redirectToNavigationController(fromViewController: self)
            return
        }else{
            self.spinner = SARMaterialDesignSpinner(frame: CGRect(x: self.view.frame.width/2 - 20, y: self.view.frame.height/2 - 20, width: 40, height: 40))
            self.spinner!.lineWidth = 1.5
            self.spinner!.tintColor = Config.Colors.ZanaduCerisePink
            bgView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            bgView!.backgroundColor = UIColor.black
            bgView!.addSubview(self.spinner!)
            showIntro()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Router.Storyboard = storyboard
    }

    fileprivate func initIntro() {
        let yPos = self.view.frame.size.height * 5 / 80
        
        view1.bgImage.image = UIImage(named:"welcomeLocationBg")
        view1.bgImage.frame = CGRect(x: 60, y: 175, width: 200, height: 30)
        view1.titleLabel.text = "Coldplay开唱，声光、热舞和我"
        view1.titleLabel.frame = CGRect(x: 80, y: 175, width: 200, height: 15)
        view1.titleLabel2.text = "O2 Arena"
        view1.titleLabel2.frame = CGRect(x: 80, y: 190, width: 200, height: 15)
        view1.pinImageV.frame = CGRect(x: 35, y: 180, width: 20, height: 20)
        view1.coordinateImageV.frame = CGRect(x: 35, y: 180, width: 20, height: 20)
        view1.loadTopTimer()
        let page1 = EAIntroPage(customView: view1)
        page1?.bgImage = UIImage(named:"welcome1")
        
        view2.bgImage.image = UIImage(named:"welcomeLocationBg")
        view2.bgImage.frame = CGRect(x: 95, y: 195, width: 200, height: 30)
        view2.titleLabel.text = "不在机舱，靠双脚俯瞰阿尔卑斯云海"
        view2.titleLabel.frame = CGRect(x: 115, y: 195, width: 200, height: 15)
        view2.titleLabel2.text = "Bavarian Alps"
        view2.titleLabel2.frame = CGRect(x: 115, y: 210, width: 200, height: 15)
        view2.pinImageV.frame = CGRect(x: 70, y: 200, width: 20, height: 20)
        view2.coordinateImageV.frame = CGRect(x: 70, y: 200, width: 20, height: 20)
        view2.loadTopTimer()
        let page2 = EAIntroPage(customView: view2)
        page2?.bgImage = UIImage(named:"welcome2")

        view3.bgImage.image = UIImage(named:"welcomeLocationBg")
        view3.bgImage.frame = CGRect(x: 175, y: 215, width: 150, height: 30)
        view3.titleLabel.text = "酒杯碰撞施展魔法"
        view3.titleLabel.frame = CGRect(x: 195, y: 215, width: 200, height: 15)
        view3.titleLabel2.text = "Mr & Mrs Bund"
        view3.titleLabel2.frame = CGRect(x: 195, y: 230, width: 200, height: 15)
        view3.pinImageV.frame = CGRect(x: 150, y: 220, width: 20, height: 20)
        view3.coordinateImageV.frame = CGRect(x: 150, y: 220, width: 20, height: 20)
        view3.loadTopTimer()
        let page3 = EAIntroPage(customView: view3)
        page3?.bgImage = UIImage(named:"welcome3")
        
        view4.titleLabel.isHidden = true
        view4.pinImageV.isHidden = true
        view4.coordinateImageV.isHidden = true
        view4.loadTopTimer()
        let page4 = EAIntroPage(customView: view4)
        page4?.bgImage = UIImage(named:"welcome4")
        
        introView = EAIntroView(frame: view.bounds, andPages: [page1, page2, page3, page4])

        introView!.pageControlY = yPos
        introView!.skipButton.isHidden = true
        introView!.swipeToExit = false
        
        let accessLoginButton = UIImageView()
        accessLoginButton.isUserInteractionEnabled = true
        let continueTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(WelcomeViewController.hideIntro))
        accessLoginButton.addGestureRecognizer(continueTap)
        self.introView!.addSubview(accessLoginButton)
        
        let accessLoginButtonWidth: CGFloat = 0.76 * self.view.frame.width
        let accessLoginButtonHeight: CGFloat = 0.1 * self.view.frame.height
        
        constrain(accessLoginButton) { accessLoginButton in
            accessLoginButton.width == accessLoginButtonWidth
            accessLoginButton.height == accessLoginButtonHeight
            accessLoginButton.centerX == accessLoginButton.superview!.centerX
            accessLoginButton.bottom == accessLoginButton.superview!.bottom - 1.2 * accessLoginButtonHeight
        }
        accessLoginButton.isHidden = true
        
        self.view.layoutSubviews()
        
        page4?.onPageDidAppear = {
            accessLoginButton.isHidden = false
        }
        
        page4?.onPageDidDisappear = {
            accessLoginButton.isHidden = true
            Router.redirectToNavigationController(fromViewController: self)
            
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    fileprivate func showIntro() {
        initIntro()
        introView!.show(in: self.view, animateDuration:0.3, withInitialPageIndex:0)
    }

    func hideIntro() {
        
        guard let introView = introView else {
            return
        }
        view1.animateTimer.invalidate()
        view2.animateTimer.invalidate()
        view3.animateTimer.invalidate()
        view4.animateTimer.invalidate()
        introView.hide(withFadeOutDuration: 0.3)
        Router.redirectToNavigationController(fromViewController: self)
    }
}


