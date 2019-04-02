//
//  TagField.swift
//  TagView
//  Atlas
//  Created by Benjamin Lefebvre on 4/22/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import UIKit

enum TagFieldState {
    case opened
    case closed
}


@objc protocol TagFieldDelegate : UITextFieldDelegate {
    func tagFieldShouldChangeHeight(_ height: CGFloat)
    @objc optional func tagFieldDidSelectTag(_ tag: TagControl)
    @objc optional func tagFieldDidBeginEditing(_ tagField: TagField)
    @objc optional func tagFieldDidEndEditing(_ tagField: TagField)
    @objc optional func tagFieldTextDidChange(_ tagField: TagField)
}


class TagField: UITextField,TagControlDelegate {
    
    // MARK: - Private Properties
    fileprivate var _cursorColor: UIColor = UIColor.gray {
        willSet {
            tintColor = newValue
        }
    }
    
    var scrollToEnd = true
    fileprivate var _setupCompleted: Bool = false
    fileprivate var _selfFrame: CGRect?
    fileprivate var _caretPoint: CGPoint?
    fileprivate var _placeholderValue: String?
    fileprivate var _placeholderLabel: UILabel?
    fileprivate var _state: TagFieldState = .opened
    fileprivate var _minWidthForInput: CGFloat = 50.0
    fileprivate var _separatorText: String?
    fileprivate var _font: UIFont?
    fileprivate var _paddingX: CGFloat?
    fileprivate var _paddingY: CGFloat?
    fileprivate var _marginX: CGFloat?
    fileprivate var _marginY: CGFloat?
    fileprivate var _removesTagsOnEndEditing = false
     var _scrollView = UIScrollView(frame: .zero)
    fileprivate var _scrollPoint = CGPoint.zero
    fileprivate var _direction: TagViewScrollDirection = .vertical {
        didSet {
            if (oldValue != _direction) {
                updateLayout()
            }
        }
    }
    fileprivate var _descriptionText: String = "selections" {
        didSet {
            _updateText()
        }
    }
    
    internal var fromGlobalSearch = false
    // MARK: - Public Properties
    
    /// default is grayColor()
    var promptTextColor: UIColor = Config.Colors.ZanaduCerisePink
    
    /// default is grayColor()
    var placeHolderColor: UIColor = Config.Colors.LightGreyTextColor
    
    /// default is 120.0. After maximum limit is reached, tags starts scrolling vertically
    var maximumHeight: CGFloat = 120.0
    
    /// default is nil
    override var placeholder: String? {
        get {
            return _placeholderValue
        }
        set {
            super.placeholder = newValue
            if (newValue == nil) {
                return
            }
            _placeholderValue = newValue
        }
    }

    weak var parentView: TagView? {
        willSet (tagView) {
            if (tagView != nil) {
                _cursorColor = tagView!.cursorColor
                _paddingX = tagView!.paddingX
                _paddingY = tagView!.paddingY
                _marginX = tagView!.marginX
                _marginY = tagView!.marginY
                _direction = tagView!.direction
                _font = tagView!.font
                _minWidthForInput = tagView!.minWidthForInput
                _separatorText = tagView!.separatorText
                _removesTagsOnEndEditing = tagView!.removesTagsOnEndEditing
                _descriptionText = tagView!.descriptionText
                _setPromptText(tagView!.promptText)
                if (_setupCompleted) {
                    updateLayout()
                }
            }
        }
    }
    
    weak var tagFieldDelegate: TagFieldDelegate? {
        didSet {
            delegate = tagFieldDelegate
        }
    }
    
    /// returns Array of tags
    var tags = [TagControl]()
    
    /// returns selected Tag object
    var selectedTag: TagControl?
    
    // MARK: - Constructors
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setupTagField()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupTagField()
    }
    
    
    // MARK: - Methods
    
    // MARK: - Setup
    fileprivate func _setupTagField() {
        text = ""
       // autocorrectionType = UITextAutocorrectionType.No
        textAlignment = NSTextAlignment.left

        autocapitalizationType = UITextAutocapitalizationType.none
        contentVerticalAlignment = UIControlContentVerticalAlignment.fill
        returnKeyType = UIReturnKeyType.done
        text = TagTextEmpty
        backgroundColor = UIColor.white
        clipsToBounds = true
        _state = .closed
        
        _setScrollRect()
        _scrollView.backgroundColor = UIColor.clear
        keyboardAppearance = UIKeyboardAppearance.default
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIResponder.becomeFirstResponder))
        gestureRecognizer.cancelsTouchesInView = false
        _scrollView.addGestureRecognizer(gestureRecognizer)
        _scrollView.delegate = self
        addSubview(_scrollView)
        
        addTarget(self, action: #selector(TagFieldDelegate.tagFieldTextDidChange(_:)), for: UIControlEvents.editingChanged)
    }
    
    func _setScrollRect() {
        _scrollView.frame = CGRect(x: _leftViewRect().width, y: 0, width: frame.width - _leftViewRect().width, height: frame.height)
    }
    
    override func draw(_ rect: CGRect) {
        _selfFrame = rect
        _setupCompleted = true
        _updateText()
    }
    
    // MARK: - Add Tag
    /**
    Create and add new tag
    
    - parameter title: String value
    
    - returns: Tag object
    */
    func addTagWithTitle(_ title: String) -> TagControl? {
        return addTagWithTitle(title, tagObject: nil)
    }
    
    /**
    Create and add new tag with custom object
    
    - parameter title:       String value
    - parameter tagObject: Any custom object
    
    - returns: Tag object
    */
    func addTagWithTitle(_ title: String, tagObject: AnyObject?) -> TagControl? {
        let tag = TagControl(title: title, object: tagObject)
        return addTag(tag)
    }
    
    /**
    Add new tag
    
    - parameter tag: Tag object
    
    - returns: Tag object
    */
    func addTag(_ tag: TagControl) -> TagControl? {
        if tag.title.characters.count == 0 {
            return nil
        }
        if (!tags.contains(tag)) {
            tag.tagDelete = self
            tag.addTarget(self, action: #selector(TagField.tagTouchDown(_:)), for: .touchDown)
            tag.addTarget(self, action: #selector(TagField.tagTouchUpInside(_:)), for: .touchUpInside)
            tags.append(tag)
            _insertTag(tag)
        }
        
        return tag
    }
    
    fileprivate func _insertTag(_ tag: TagControl, shouldLayout: Bool = true) {
      //  GCDBlock.async(GCDQueue.Main) {
            self._scrollView.addSubview(tag)
            self._scrollView.bringSubview(toFront: tag)
            
            if shouldLayout == true {
                self.updateLayout()
            }
     //   }
    }
    
    //MARK: - Delete Tag
    /*
    **************************** Delete Tag ****************************
    */
    
    /**
    Deletes a tag from view
    
    - parameter tag: Tag object
    */
    func deleteTag(_ tag: TagControl) {
        removeTag(tag)
    }
    
    /**
    Deletes a tag from view, if any tag is found for custom object
    
    - parameter object: Custom object
    */
    func deleteTagWithObject(_ object: AnyObject?) {
        if object == nil {return}
        for tag in tags {
            if (tag.object!.isEqual(object)) {
                removeTag(tag)
                break
            }
        }
    }
    
    /**
    Deletes all tags from view
    */
    func forceDeleteAllTags() {
        tags.removeAll(keepingCapacity: false)
        for tag in tags {
            removeTag(tag, removingAll: true)
        }
        updateLayout()
    }
    
    /**
    Deletes tag from view
    
    - parameter tag:       Tag object
    - parameter removingAll: A boolean to describe if removingAll tags
    */
    func removeTag(_ tag: TagControl, removingAll: Bool = false) {
        if tag.isEqual(selectedTag) {
            deselectSelectedTag()
        }
        tag.removeFromSuperview()
        
        let index = tags.index(of: tag)
        if (index != nil) {
            tags.remove(at: index!)
        }
        if (!removingAll) {
            updateLayout()
        }
    }
    
    
    //MARK: - Layout
    /*
    **************************** Layout ****************************
    */
    
    /**
    Untagzies the layout
    */
    func untagize() {
        if (!_removesTagsOnEndEditing) {
            return
        }
        _state = .closed
        for subview in _scrollView.subviews {
            if subview is TagControl {
                subview.removeFromSuperview()
            }
        }
        updateLayout()
    }
    
    /**
    Tagizes the layout
    */
    func tagize() {
        _state = .opened
//        for tag: TagControl in tags {
//            _insertTag(tag, shouldLayout: false)
//        }
        updateLayout()
    }
    
    /**
    Updates the tagView layout and calls delegate methods
    */
    func updateLayout() {
        if (parentView == nil) {
            return
        }
        _caretPoint = _layoutTags()
        deselectSelectedTag()
        _updateText()
        
        if _caretPoint != .zero {
            let tagsMaxY = _caretPoint!.y
            
            if (frame.size.height != tagsMaxY) {
                tagFieldDelegate?.tagFieldShouldChangeHeight(tagsMaxY)
            }
        }
    }
    
    /**
    Layout tags
    
    - returns: CGPoint maximum position values
    */
    fileprivate func _layoutTags() -> CGPoint {
        if (_selfFrame == nil) {
            return .zero
        }
        if (_state == .closed) {
            return CGPoint(x: _marginX!, y: _selfFrame!.size.height)
        }
        
        if (_direction == .horizontal) {
            return _layoutTagsHorizontally()
        }
        
        var lineNumber = 1
        let leftMargin = _leftViewRect().width
        let rightMargin = _rightViewRect().width
        let tagHeight = _font!.lineHeight + _paddingY!;
        var deleteBtnWidth:CGFloat = 0
        
        var  currentWidth = bounds.width
        if fromGlobalSearch {
            currentWidth = UIScreen.main.bounds.width //bounds maybe changed when runtime,so we can use the Width of mainScreen
        }
        
        var tagPosition = CGPoint(x: _marginX!*2, y: _marginY!)
        
        for tag: TagControl in tags {
            if tag.isShowDeleteBtn{
                deleteBtnWidth = 20
            }
            let width = TagUtils.getRect(tag.title as NSString, width: currentWidth, font: _font!).size.width + ceil(_paddingX!*2+1)
            let tagWidth = min(width, tag.maxWidth) + deleteBtnWidth
            
            // Add tag at specific position
            if ((tag.superview) != nil) {
                if (tagPosition.x + tagWidth + _marginX! + leftMargin > currentWidth - rightMargin) {                    lineNumber += 1
                    tagPosition.x = _marginX!
                    tagPosition.y += (tagHeight + _marginY!);
                }
                
                tag.frame = CGRect(x: tagPosition.x, y: tagPosition.y, width: tagWidth, height: tagHeight)
                tagPosition.x += tagWidth + _marginX!;
            }
        }
        
        // check if next tag can be added in same line or new line
        if ((currentWidth) - (tagPosition.x + _marginX!) - leftMargin < _minWidthForInput) {
            lineNumber += 1
            tagPosition.x = _marginX!
            tagPosition.y += (tagHeight + _marginY!);
        }
        
        var positionY = (lineNumber == 1 && tags.count == 0) ? _selfFrame!.size.height: (tagPosition.y + tagHeight + _marginY!)
        _scrollView.contentSize = CGSize(width: _scrollView.frame.width, height: positionY)
        if (positionY > maximumHeight) {
            positionY = maximumHeight
        }
        
        _scrollView.frame.size = CGSize(width: _scrollView.frame.width, height: positionY)
        scrollViewScrollToEnd()
        
        return CGPoint(x: tagPosition.x + leftMargin, y: positionY)
    }
    
    
    /**
    Layout tags horizontally
    
    - returns: CGPoint maximum position values
    */
    fileprivate func _layoutTagsHorizontally() -> CGPoint {
        let leftMargin = _leftViewRect().width
        let tagHeight = _font!.lineHeight + _paddingY!;


        
        var tagPosition = CGPoint(x: _marginX!, y: _marginY!)
        var deleteBtnWidth:CGFloat = 0
        
        for tag: TagControl in tags {
            if tag.isShowDeleteBtn{
                deleteBtnWidth = 20
            }
            let width = TagUtils.getRect(tag.title as NSString, width: bounds.size.width, font: _font!).size.width + ceil(_paddingX!*2+1)
            let tagWidth = min(width, tag.maxWidth) + deleteBtnWidth
            
            if ((tag.superview) != nil) {
                tag.frame = CGRect(x: tagPosition.x, y: tagPosition.y, width: tagWidth, height: tagHeight)

                tagPosition.x += tagWidth + _marginX!;
            }
        }
        
        if textAlignment == .center {

            let zero = self.frame.width / 2
            let tagsCenter = tagPosition.x / 2

            
            for tag: TagControl in tags {
                
                
                //            tag.frame.origin.x += tagsCenter

                tag.frame.origin.x += (frame.width - tagPosition.x) / 2
            }
        }
        
        let offsetWidth = ((tagPosition.x + _marginX! + _leftViewRect().width) > (frame.width - _minWidthForInput)) ? _minWidthForInput : 0
        _scrollView.contentSize = CGSize(width: max(_scrollView.frame.width, tagPosition.x + offsetWidth), height: frame.height)
        scrollViewScrollToEnd()
        
        return CGPoint(x: min(tagPosition.x + leftMargin, frame.width - _minWidthForInput), y: frame.height)
    }
    
    /**
    Scroll the tags to end
    */
    func scrollViewScrollToEnd() {
        if !scrollToEnd {
            return
        }
        var bottomOffset: CGPoint
        switch _direction {
        case .vertical:
            bottomOffset = CGPoint(x: 0, y: _scrollView.contentSize.height - _scrollView.bounds.height)
        case .horizontal:
            bottomOffset = CGPoint(x: _scrollView.contentSize.width - _scrollView.bounds.width, y: 0)
        }
        _scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    /**
    Disable tags scrolling
    */
    func disableTagsScrolling() {
        _scrollView.isScrollEnabled = false
    }
    
    
    //MARK: - Text Rect
    /*
    **************************** Text Rect ****************************
    */
    
    fileprivate func _textRectWithBounds(_ bounds: CGRect) -> CGRect {
        if (!_setupCompleted) {return .zero}
        if (tags.count == 0 || _caretPoint == nil) {
            return CGRect(x: _leftViewRect().width + _marginX!, y: (bounds.size.height - font!.lineHeight)*0.5, width: bounds.size.width-5, height: bounds.size.height)
        }
        
        if (tags.count != 0 && _state == .closed) {
            return CGRect(x: _leftViewRect().maxX + _marginX!, y: (_caretPoint!.y - font!.lineHeight - (_marginY!)), width: (frame.size.width - _caretPoint!.x - _marginX!), height: bounds.size.height)
        }
        return CGRect(x: _caretPoint!.x, y: (_caretPoint!.y - font!.lineHeight - (_marginY!)), width: (frame.size.width - _caretPoint!.x - _marginX!), height: bounds.size.height)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: _marginX!, y: (_selfFrame != nil) ? (_selfFrame!.height - _leftViewRect().height)*0.5: (bounds.height - _leftViewRect().height)*0.5, width: _leftViewRect().width, height: _leftViewRect().height)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return _textRectWithBounds(bounds)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return _textRectWithBounds(bounds)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return _textRectWithBounds(bounds)
    }
    
    fileprivate func _leftViewRect() -> CGRect {
        if (leftViewMode == .never ||
            (leftViewMode == .unlessEditing && isEditing) ||
            (leftViewMode == .whileEditing && !isEditing)) {
                return .zero
        }
        return leftView!.bounds
    }
    
    fileprivate func _rightViewRect() -> CGRect {
        if (rightViewMode == .never ||
            rightViewMode == .unlessEditing && isEditing ||
            rightViewMode == .whileEditing && !isEditing) {
                return .zero
        }
        return rightView!.bounds
    }
    
    fileprivate func _setPromptText(_ text: String?) {
        if (text != nil) {
            var label = leftView
            if !(label is UILabel) {
                label = UILabel(frame: .zero)
                label?.frame.origin.x += _marginX!
                (label as! UILabel).textColor = promptTextColor
                leftViewMode = .always
            }
            
            (label as! UILabel).text = text
            (label as! UILabel).font = font
            (label as! UILabel).sizeToFit()
            leftView = label
            
        } else {
            leftView = nil
        }
        _setScrollRect()
    }
    
    
    //MARK: - Placeholder
    /*
    **************************** Placeholder ****************************
    */
    
    fileprivate func _updateText() {
        if (!_setupCompleted) {return}
        _initPlaceholderLabel()
        
        switch(_state) {
        case .opened:
            text = TagTextEmpty
            break
            
        case .closed:
            if tags.count == 0 {
                text = TagTextEmpty
            } else {
                var title = TagTextEmpty
                for tag: TagControl in tags {
                    title += "\(tag.title)\(_separatorText!)"
                }
                
                if (title.characters.count > 0) {
                    title = title.substring(with: (title.characters.index(title.startIndex, offsetBy: 0) ..< title.characters.index(title.endIndex, offsetBy: -(_separatorText!).characters.count)))
                }

                let width = TagUtils.widthOfString(title, font: font!)
                if width + _leftViewRect().width > bounds.width {
                    text = "\(tags.count) \(_descriptionText)"
                } else {
                    text = title
                }
            }
            break
        }
        _updatePlaceHolderVisibility()
    }
    
    fileprivate func _updatePlaceHolderVisibility() {
        if tags.count == 0 && (text == TagTextEmpty || text!.isEmpty) {
            _placeholderLabel?.text = _placeholderValue!
            _placeholderLabel?.isHidden = false
            
        } else {
            _placeholderLabel?.isHidden = true
        }
    }
    
    fileprivate func _initPlaceholderLabel() {
        let xPos = _marginX!
        if (_placeholderLabel == nil) {
            _placeholderLabel = UILabel(frame: CGRect(x: xPos, y: 0, width: _selfFrame!.width - xPos - _leftViewRect().size.width, height: self.frame.height))
            _placeholderLabel?.textColor = placeHolderColor
            _placeholderLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(TagField.placeholderTapped)))
            _scrollView.addSubview(_placeholderLabel!)
            //         addSubview(_placeholderLabel!)
        } else {
            _placeholderLabel?.frame.origin.x = xPos
        }
    }
    
    
    //MARK: - Tag Gestures
    //__________________________________________________________________________________
    //
    func isSelectedTag(_ tag: TagControl) -> Bool {
        if tag.isEqual(selectedTag) {
            return true
        }
        return false
    }
    
    
    func deselectSelectedTag() {
        selectedTag?.isSelected = false
        selectedTag = nil
    }
    
    func selectTag(_ tag: TagControl) {
        if (tag.sticky) {
            return
        }
        for tag: TagControl in tags {
            if isSelectedTag(tag) {
                deselectSelectedTag()
                break
            }
        }
        
        tag.isSelected = true
        selectedTag = tag
        tagFieldDelegate?.tagFieldDidSelectTag?(tag)
    }
    
    func tagTouchDown(_ tag: TagControl) {
        if (selectedTag != nil) {
            selectedTag?.isSelected = false
            selectedTag = nil
        }
    }
    
    func tagTouchUpInside(_ tag: TagControl) {
        selectTag(tag)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if (touch.view == self) {
            deselectSelectedTag()
        }
        return super.beginTracking(touch, with: event!)
    }
    
    func tagFieldTextDidChange(_ textField: UITextField) {
        _updatePlaceHolderVisibility()
        tagFieldDelegate?.tagFieldTextDidChange?(self)
    }
    
    // MARK: - Other Methods
    
    func paddingX() -> CGFloat? {
        return _paddingX
    }
    
    func tagFont() -> UIFont? {
        return _font
    }
    
    func objects() -> NSArray {
        let objects = NSMutableArray()
        for object: AnyObject in tags {
            objects.add(object)
        }
        return objects
    }
    
    override func becomeFirstResponder() -> Bool {
        tagFieldDelegate?.tagFieldDidBeginEditing?(self)
        return super.becomeFirstResponder()
    }
    
    func placeholderTapped() {
        
    }
    
    override func resignFirstResponder() -> Bool {
        tagFieldDelegate?.tagFieldDidEndEditing?(self)
        return super.resignFirstResponder()
    }
    func TagControlDelegateDidDeleteTag(_ tag: AnyObject) {
        self.removeTag(tag as! TagControl, removingAll: false)
    }
    
}


//MARK: - UIScrollViewDelegate
//__________________________________________________________________________________
//
extension TagField : UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _scrollPoint = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ aScrollView: UIScrollView) {
        text = TagTextEmpty
        updateCaretVisiblity(aScrollView)
    }
    
    func updateCaretVisiblity(_ aScrollView: UIScrollView) {
        let scrollViewHeight = aScrollView.frame.size.height;
        let scrollContentSizeHeight = aScrollView.contentSize.height;
        let scrollOffset = aScrollView.contentOffset.y;
        
        if (scrollOffset + scrollViewHeight < scrollContentSizeHeight - 10) {
            hideCaret()
            
        } else if (scrollOffset + scrollViewHeight >= scrollContentSizeHeight - 10) {
            showCaret()
        }
    }
    
    func hideCaret() {
        tintColor = UIColor.clear
    }
    
    func showCaret() {
        tintColor = _cursorColor
    }
}
