//
//  ImageCaptionCropView.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/5/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import Foundation

/**
 *  Subclass of ImageCropView with a bottom right button that display/hide a textfield on click
 */
open class ImageCaptionCropView: ImageCropView {
    
    let buttonWidth: CGFloat = 36
    let padding: CGFloat = 10
    
    var caption: String = ""
    var editing = false
    
    var container: UIView!
    var button: UIButton!
    var field: UITextField!
    
    var editIcon: UIImage!
    var validateIcon: UIImage!
    
    open var containerBackgroundColor = UIColor.black {
        didSet {
            container.backgroundColor = containerBackgroundColor
        }
    }
    open var fieldTintColor = UIColor.white {
        didSet {
            field.tintColor = fieldTintColor
        }
    }
    
    open func fieldText() -> String? {
        return field.text
    }
    
    open func isEditing() -> Bool {
        return editing
    }
    
    
    func onImageTapped(_ sender: AnyObject?) {
        
    }
    
    
    /**
     Setup the cropview and the button, field & container
     
     - parameter image:        the image to crop
     - parameter editIcon:     the caption edit button icon
     - parameter validateIcon: the validate input button icon
     */
    open func setup(_ image: UIImage, tapDelegate: ImageCropViewTapProtocol? = nil, editIcon: UIImage, validateIcon: UIImage) {
        // init
        super.setup(image, tapDelegate: tapDelegate)
        self.editIcon = editIcon
        self.validateIcon = validateIcon
        
        
        // setup container
        container = UIView(frame: closeFieldFrame())
        container.backgroundColor = containerBackgroundColor
        container.layer.cornerRadius = buttonWidth / 2
        
        
        // setup button
        button = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth))
        button.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        button.setImage(editIcon, for: UIControlState())
        button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.addTarget(self, action: #selector(ImageCaptionCropView.onButtonPressed(_:)), for: .touchUpInside)
        
        //setup field
        field = UITextField(frame: CGRect(x: padding * 2, y: 0, width: 0, height: buttonWidth))
        field.textColor = UIColor.white
        field.tintColor = fieldTintColor
        field.keyboardAppearance = UIKeyboardAppearance.default
        field.delegate = self
        container.addSubview(field)
        container.addSubview(button)
        self.addSubview(container)
    }
    
    open func setup(_ imageHook: ImageSetterBlock, placeholder: UIImage, tapDelegate: ImageCropViewTapProtocol? = nil, editIcon: UIImage, validateIcon: UIImage) {
        // init
        super.setup(imageHook, placeholder: placeholder, tapDelegate: tapDelegate)
        self.editIcon = editIcon
        self.validateIcon = validateIcon
        
        
        // setup container
        container = UIView(frame: closeFieldFrame())
        container.backgroundColor = containerBackgroundColor
        container.layer.cornerRadius = buttonWidth / 2
        
        
        // setup button
        button = UIButton(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth))
        button.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        button.setImage(editIcon, for: UIControlState())
        button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.addTarget(self, action: #selector(ImageCaptionCropView.onButtonPressed(_:)), for: .touchUpInside)
        
        //setup field
        field = UITextField(frame: CGRect(x: padding * 2, y: 0, width: 0, height: buttonWidth))
        field.textColor = UIColor.white
        field.tintColor = fieldTintColor
        field.keyboardAppearance = UIKeyboardAppearance.default
        field.delegate = self
        container.addSubview(field)
        container.addSubview(button)
        self.addSubview(container)
    }
    
    override open func enableEditing() {
        super.enableEditing()
        container.isHidden = false
    }
    
    override open func disableEditing() {
        super.disableEditing()
        container.isHidden = true
    }
    
    
    func onButtonPressed(_ sender: UIButton!) {
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            if self.editing {
                self.container.frame = self.closeFieldFrame()
                self.field.frame.size.width = 0
                self.button.frame.origin.x = 0
                self.button.setImage(self.editIcon, for: UIControlState())
            } else {
                self.container.frame = self.openFieldFrame()
                self.field.frame.size.width = self.frame.width - self.padding * 5 - self.buttonWidth
                self.button.frame.origin.x = self.field.frame.origin.x + self.field.frame.size.width + self.padding
                self.button.setImage(self.validateIcon, for: UIControlState())
            }
            self.layoutIfNeeded()
        }, completion: { (complete) -> Void in
            print("animation finished", terminator: "")
            self.editing = !self.editing
            if self.editing {
                self.field.becomeFirstResponder()
                self.isScrollEnabled = false
            } else {
                self.field.resignFirstResponder()
                self.isScrollEnabled = true
            }
        }) 
    }
    
    fileprivate func closeFieldFrame() -> CGRect {
        return CGRect(x: frame.width - buttonWidth - padding + contentOffset.x, y: frame.height - buttonWidth - padding + contentOffset.y, width: buttonWidth, height: buttonWidth)
    }
    
    fileprivate func openFieldFrame() -> CGRect {
        return CGRect(x: self.padding, y: self.container.frame.origin.y, width: self.frame.width - self.padding * 2, height: self.container.frame.height)
    }
    
    
    //MARK: - UIScrollViewDelegate
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        container.frame = self.editing ? self.openFieldFrame() : self.closeFieldFrame()
    }
}

extension ImageCaptionCropView : UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.onButtonPressed(nil)
        return false
    }
}
