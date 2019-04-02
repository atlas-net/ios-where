//
//  UIImagePicker+HiddenStatusBar.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/2/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


extension NYTPhotosViewController {
    
    open override var prefersStatusBarHidden : Bool {
        return true
    }

    func setRightBarButtonItemButton(_ button: UIButton) {
        let itemButton: UIButton = UIButton(frame:CGRect(x: 0, y: 0, width: 32, height: 32))
        itemButton.setImage(button.imageView!.image, for:UIControlState())
        itemButton.layer.borderColor = button.layer.borderColor
        itemButton.layer.borderWidth = button.layer.borderWidth
        print("background color : \(button.backgroundColor)", terminator: "")
        itemButton.backgroundColor = button.backgroundColor
        itemButton.layer.cornerRadius = 16
        itemButton.addTarget(self, action:Selector("actionButtonTapped:"), for:UIControlEvents.touchUpInside)
        self.overlayView.rightBarButtonItem = UIBarButtonItem(customView:itemButton)
    }

    
    func selectButton() {
        if let view = self.overlayView.rightBarButtonItem.getSubView() {
            view.backgroundColor = Config.Colors.ZanaduCerisePink
            view.layer.borderWidth = 0
        }
    }
    
    func deselectButton() {
        if let view = self.overlayView.rightBarButtonItem.getSubView() {
            view.backgroundColor = UIColor(white: 0, alpha: 0.4)
            view.layer.borderWidth = 1
        }
    }
    
    func setNavigationBarBackgroundColor(_ color: UIColor = UIColor(white: 0, alpha: 0.7)) {
        let navBar = (self.rightBarButtonItem.getSubView()!.superview as! UINavigationBar)
        navBar.backgroundColor = color
    }
}
