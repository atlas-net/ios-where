//
//  TagView.swift
//  TagView
//  Atlas
//  Created by Benjamin Lefebvre on 4/22/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import UIKit


enum TagViewStyle {
    case rounded
    case squared
    case none
}

enum TagViewScrollDirection {
    case vertical
    case horizontal
}


//MARK: - TagViewDelegate
//__________________________________________________________________________________
//

@objc protocol TagViewDelegate {
    
    /**
    AsTag the delegate whether the tag should be added
    
    - parameter tagView: TagView object
    - parameter tag:     Tag object that needs to be added
    
    - returns: Boolean
    
    */
    @objc optional func tagView(_ tagView: TagView, shouldAddTag tag: TagControl) -> Bool
    @objc optional func tagView(_ tagView: TagView, willAddTag tag: TagControl)
    @objc optional func tagView(_ tagView: TagView, shouldChangeAppearanceForTag tag: TagControl) -> TagControl?
    @objc optional func tagView(_ tagView: TagView, didAddTag tag: TagControl)
    @objc optional func tagView(_ tagView: TagView, didFailToAdd tag: TagControl)
    
    @objc optional func tagView(_ tagView: TagView, shouldDeleteTag tag: TagControl) -> Bool
    @objc optional func tagView(_ tagView: TagView, willDeleteTag tag: TagControl)
    @objc optional func tagView(_ tagView: TagView, didDeleteTag tag: TagControl)
    @objc optional func tagView(_ tagView: TagView, didFailToDeleteTag tag: TagControl)
    
    @objc optional func tagView(_ tagView: TagView, willChangeFrame frame: CGRect)
    @objc optional func tagView(_ tagView: TagView, didChangeFrame frame: CGRect)
    
    @objc optional func tagView(_ tagView: TagView, didSelectTag tag: TagControl)
    @objc optional func tagViewDidBeginEditing(_ tagView: TagView)
    @objc optional func tagViewDidEndEditing(_ tagView: TagView)
    
    func tagView(_ tag: TagView, performSearchWithString string: String, completion: ((_ results: Array<Tag>) -> Void)?)
    func tagView(_ tag: TagView, displayTitleForObject object: AnyObject) -> String
    @objc optional func tagView(_ tag: TagView, withObject object: AnyObject, tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    @objc optional func tagView(_ tag: TagView, didSelectRowAtIndexPath indexPath: IndexPath)
    
    @objc optional func tagViewShouldDeleteAllTag(_ tagView: TagView) -> Bool
    @objc optional func tagViewWillDeleteAllTag(_ tagView: TagView)
    @objc optional func tagViewDidDeleteAllTag(_ tagView: TagView)
    @objc optional func tagViewDidFailToDeleteAllTags(_ tagView: TagView)
}

//MARK: - TagView
//__________________________________________________________________________________
//

/**
*  A TagView is a control that displays a collection of tags in a an editable UITextField and sends messages to delegate object. It can be used to gather small amounts of text from user and perform search operation. User can choose multiple search results, which are displayed as tag in UITextField.
*/
class TagView: UIView {
    
    //MARK: - Private Properties
    //__________________________________________________________________________________
    //
    ///show delete Btn  or not
    var isShowDeleteBtn = false
    var _tagField = TagField(frame: .zero)
    fileprivate var _searchTableView: UITableView = UITableView(frame: .zero, style: UITableViewStyle.plain)
    fileprivate var _resultArray = [Tag]()
    fileprivate var _showingSearchResult = true
    fileprivate var _indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    fileprivate var _popover: UIPopoverController?
    fileprivate let _searchResultHeight: CGFloat = 90.0
    fileprivate var _lastSearchString: String = ""
    fileprivate let maxSearchResults = 3
    var isSetup = false
    var autoScrollToEnd = true
    
    //MARK: - Public Properties
    //__________________________________________________________________________________
    //
    
    /// default is true. tag can be deleted with keyboard 'x' button
    var shouldDeleteTagOnBacTagpace = true
    
    /// Only worTag for iPhone now, not iPad devices. default is false. If true, search results are hidden when one of them is selected
    var shouldHideSearchResultsOnSelect = false
    
    /// default is false. If true, already added tag still appears in search results
    var shouldDisplayAlreadyTagized = false
    
    /// default is ture. Sorts the search results alphabatically according to title provided by tagView(_:displayTitleForObject) delegate
    var shouldSortResultsAlphabatically = true
    
    /// default is true. If false, tag can only be added from picking search results. All the text input would be ignored
    var shouldAddTagFromTextInput = true
    
    /// default is 1
    var minimumCharactersToSearch = 1
    
    /// default is nil
    var delegate: TagViewDelegate?
    
    /// default is .Vertical.
    var direction: TagViewScrollDirection = .vertical {
        didSet {
            _updateTagField()
        }
    }
    
    /// Default is (TagViewWidth, 200)
    var searchResultSize: CGSize = CGSize.zero {
        didSet {
            if (TagUtils.isIpad()) {
                _popover?.contentSize = searchResultSize
            } else {
                _searchTableView.frame.size = searchResultSize
            }
        }
    }
    
    /// Default is whiteColor()
    var searchResultBackgroundColor: UIColor = UIColor.clear {
        didSet {
            if (TagUtils.isIpad()) {
                _popover?.contentViewController.view.backgroundColor = searchResultBackgroundColor
                _popover?.backgroundColor = searchResultBackgroundColor
            } else {
                _searchTableView.backgroundColor = searchResultBackgroundColor
            }
        }
    }
    
    /// default is UIColor.blueColor()
    var activityIndicatorColor: UIColor = UIColor.blue {
        didSet {
            _indicator.color = activityIndicatorColor
        }
    }
    
    /// default is 120.0. After maximum limit is reached, tags starts scrolling vertically
    var maximumHeight: CGFloat = 120.0 {
        didSet {
            _tagField.maximumHeight = maximumHeight
        }
    }
    
    /// default is UIColor.grayColor()
    var cursorColor: UIColor = UIColor.gray {
        didSet {
            _updateTagField()
        }
    }
    
    /// default is 10.0. Horizontal padding of title
    var paddingX: CGFloat = 10.0 {
        didSet {
            if (oldValue != paddingX) {
                _updateTagField()
            }
        }
    }
    
    /// default is 2.0. Vertical padding of title
    var paddingY: CGFloat = 2.0 {
        didSet {
            if (oldValue != paddingY) {
                _updateTagField()
            }
        }
    }
    
    /// default is 5.0. Horizontal margin between tags
    var marginX: CGFloat = 5.0 {
        didSet {
            if (oldValue != marginX) {
                _updateTagField()
            }
        }
    }
    
    /// default is 5.0. Vertical margin between tags
    var marginY: CGFloat = 5.0 {
        didSet {
            if (oldValue != marginY) {
                _updateTagField()
            }
        }
    }
    
    /// default is UIFont.systemFontOfSize(16)
    var font: UIFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            if (oldValue != font) {
                _updateTagField()
            }
        }
    }
    
    /// default is NSTextAlignment.Left
    var textAlignment: NSTextAlignment = NSTextAlignment.left {
        didSet {
            _tagField.textAlignment = textAlignment
            _updateTagField()
        }
    }
    
    /// default is 50.0. Caret moves to new line if input width is less than this value
    var minWidthForInput: CGFloat = 50.0 {
        didSet {
            if (oldValue != minWidthForInput) {
                _updateTagField()
            }
        }
    }
    
    /// default is ", ". Used to separate titles when untoknized
    var separatorText: String = ", " {
        didSet {
            if (oldValue != separatorText) {
                _updateTagField()
            }
        }
    }
    
    /// An array of string values. Default values are " " and ",". Tag is created when any of the character in this Array is pressed
    var tagizingCharacters = [" ", ","]
    
    /// default is 0.25.
    var animateDuration: TimeInterval = 0.25 {
        didSet {
            if (oldValue != animateDuration) {
                _updateTagField()
            }
        }
    }
    
    /// default is true. When resignFirstResponder is called tags are removed and description is displayed.
    var removesTagsOnEndEditing: Bool = false {
        didSet {
            if (oldValue != removesTagsOnEndEditing) {
                _updateTagField()
            }
        }
    }
    
    /// Default is "selections"
    var descriptionText: String = "selections" {
        didSet {
            if (oldValue != descriptionText) {
                _updateTagField()
            }
        }
    }
    
    /// set -1 for unlimited.
    var maxTagLimit: Int = -1 {
        didSet {
            if (oldValue != maxTagLimit) {
                _updateTagField()
            }
        }
    }
    
    /// default is "To: "
    var promptText: String = "To: " {
        didSet {
            if (oldValue != promptText) {
                _updateTagField()
            }
        }
    }
    
    /// default is true. If false, cannot be edited
    var editable: Bool = true {
        didSet(newValue) {
            print("disable tag field", terminator: "")
            _tagField.isEnabled = newValue
//          _tagField.userInteractionEnabled = !newValue
        }
    }
    
    /// default is nil
    var placeholder: String {
        get {
            return _tagField.placeholder!
        }
        set {
            
            _tagField.attributedPlaceholder = NSAttributedString(string: newValue, attributes: [NSForegroundColorAttributeName: Config.Colors.LightGreyTextColor, NSFontAttributeName : _tagField.font!.withSize(18)])
            
            _tagField.placeholder = newValue            
        }
    }
    
    /// default is .Rounded, creates rounded corner
    var style: TagViewStyle = .rounded {
        didSet(newValue) {
            _updateTagFieldLayout(style)
        }
    }
    
    //MARK: - Constructors
    //__________________________________________________________________________________
    //
    
    /**
    Create and inialize TagView object
    
    - parameter frame: An object of type CGRect
    
    - returns: TagView object
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("TagView/init frame : \(frame)", terminator: "")

        _tagField = TagField(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
       // commonSetup()
    }
    
    /**
    Create and inialize TagView object from Interface builder
    
    - parameter aDecoder: An object of type NSCoder
    
    - returns: TagView object
    */
    required init?(coder aDecoder: NSCoder) {
        _tagField = TagField()
        super.init(coder: aDecoder)
        
        print("init", terminator: "")
        print(frame, terminator: "")
        print(bounds, terminator: "")
      //  commonSetup()
    }
    
    
    //MARK: - Common Setup
    //__________________________________________________________________________________
    //
    func commonSetup() {
//        setTranslatesAutoresizingMaskIntoConstraints(true)
        backgroundColor = UIColor.clear
        _tagField.textColor = UIColor.white
        _tagField.backgroundColor = UIColor.clear
        _tagField.isEnabled = true
        _tagField.tagFieldDelegate = self
        _tagField.placeholder = ""
        _tagField.scrollToEnd = autoScrollToEnd
 //       _tagField.setTranslatesAutoresizingMaskIntoConstraints(true)
        _tagField.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        _updateTagField()
        addSubview(_tagField)
        
        print("tagField frame", terminator: "")
        print(_tagField.frame, terminator: "")
        
        _indicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        _indicator.hidesWhenStopped = true
        _indicator.stopAnimating()
        _indicator.color = activityIndicatorColor
        
        searchResultSize = CGSize(width: frame.width, height: _searchResultHeight)
        _searchTableView.frame = CGRect(x: 0, y: frame.height, width: searchResultSize.width, height: searchResultSize.height)
        _searchTableView.delegate = self
        _searchTableView.dataSource = self
        _searchTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        
        if TagUtils.isIpad() {
            let viewController = UIViewController()
            viewController.view = _searchTableView
            _popover = UIPopoverController(contentViewController: viewController)
            _popover?.delegate = self
            _popover?.backgroundColor = searchResultBackgroundColor
            _popover?.passthroughViews = subviews
            _popover?.contentSize = searchResultSize
        } else {
            addSubview(_searchTableView)
            _hideSearchResults()
        }
        
        isSetup = true
    }
    
    fileprivate func _updateTagField() {
        _tagField.parentView = self
    }
    
    fileprivate func _updateTagFieldLayout(_ newValue: TagViewStyle) {
        switch (newValue) {
        case .rounded:
            _tagField.borderStyle = .roundedRect
            backgroundColor = UIColor.clear
            
        case .squared:
            _tagField.borderStyle = .bezel
            backgroundColor = _tagField.backgroundColor
            
        case .none:
            _tagField.borderStyle = .none
            _tagField.layer.borderWidth = 0
            _tagField.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    
    //MARK: - Public Methods
    //__________________________________________________________________________________
    //
    func tagize() {
        _tagField.tagize()
    }
    
    
    //MARK: - Private Methods
    //__________________________________________________________________________________
    //
    fileprivate func _lastTag() -> TagControl? {
        if _tagField.tags.count == 0 {
            return nil
        }
        return _tagField.tags.last
    }
    
    
    fileprivate func _removeTag(_ tag: TagControl, removingAll: Bool = false) {
        if tag.sticky {return}
        if (!removingAll) {
            var shouldRemoveTag: Bool? = true
            
            if let shouldRemove = delegate?.tagView?(self, shouldDeleteTag: tag) {
                shouldRemoveTag = shouldRemove
            }
            if (shouldRemoveTag != true) {
                delegate?.tagView?(self, didFailToDeleteTag: tag)
                return
            }
            delegate?.tagView?(self, willDeleteTag: tag)
        }
        _tagField.removeTag(tag, removingAll: removingAll)
        if (!removingAll) {
            delegate?.tagView?(self, didDeleteTag: tag)
            if editable {
                startSearchWithString(_lastSearchString)
            }
        }
    }
    
    fileprivate func _canAddMoreTag() -> Bool {
        if (maxTagLimit != -1 && _tagField.tags.count >= maxTagLimit) {
            _hideSearchResults()
            return false
        }
        return true
    }
    
    
    /**
    Returns an Array of Tag objects
    
    - returns: Array of Tag objects
    */
    func tags () -> Array<TagControl>? {
        return _tagField.tags
    }
    
    //MARK: - Add Tag
    //__________________________________________________________________________________
    //
    
    
    /**
    Creates Tag from input text, when user press keyboard "Done" button
    
    - parameter tagField: Field to add in
    
    - returns: Boolean if tag is added
    */
    func addTagFromUntagizedText(_ tagField: TagField) -> Bool {
        if (shouldAddTagFromTextInput && tagField.text != nil && tagField.text != TagTextEmpty) {
            addTagWithTitle(tagField.text!)
            return true
        }
        return false
    }
    
    /**
    Creates and add a new Tag object
    
    - parameter title:       Title of tag
    - parameter tagObject: Any custom object
    
    - returns: Tag object
    */
    func addTagWithTitle(_ title: String, tagObject: AnyObject? = nil) -> TagControl? {
        let tag = TagControl(title: title, object: tagObject)
        return addTag(tag)
    }
    /**
     Creates and add a new Tag object  without no delegate
     
     - parameter tag: Tag object
     
     - returns: Tag object
     */
    func addTagWithNoDelegate(_ tag: TagControl) -> TagControl? {
        if (!_canAddMoreTag()) {
            return nil
        }
        
        var shouldAddTag: Bool? = true
        if let shouldAdd = delegate?.tagView?(self, shouldAddTag: tag) {
            shouldAddTag = shouldAdd
        }
        
        if (shouldAddTag != true) {
            delegate?.tagView?(self, didFailToAdd: tag)
            return nil
        }
        
        delegate?.tagView?(self, willAddTag: tag)
        var addedTag: TagControl?
        if let updatedTag = delegate?.tagView?(self, shouldChangeAppearanceForTag: tag) {
            addedTag = _tagField.addTag(updatedTag)
            
        } else {
            addedTag = _tagField.addTag(tag)
        }
        
        return addedTag
    }
    func setTagfiledSource(_ flag : Bool) {
        _tagField.fromGlobalSearch = flag
    }
    
    /**
    Creates and add a new Tag object
    
    - parameter tag: Tag object
    
    - returns: Tag object
    */
    func addTag(_ tag: TagControl) -> TagControl? {
        if (!_canAddMoreTag()) {
            return nil
        }
        
        var shouldAddTag: Bool? = true
        if let shouldAdd = delegate?.tagView?(self, shouldAddTag: tag) {
            shouldAddTag = shouldAdd
        }
        
        if (shouldAddTag != true) {
            delegate?.tagView?(self, didFailToAdd: tag)
            return nil
        }
        
        delegate?.tagView?(self, willAddTag: tag)
        var addedTag: TagControl?
        if let updatedTag = delegate?.tagView?(self, shouldChangeAppearanceForTag: tag) {
            addedTag = _tagField.addTag(updatedTag)
            
        } else {
            if self.isShowDeleteBtn{
                tag.isShowDeleteBtn = true
            }
            addedTag = _tagField.addTag(tag)
        }
        
        delegate?.tagView?(self, didAddTag: addedTag!)
        
        return addedTag
    }


    //MARK: - Delete Tag
    //__________________________________________________________________________________
    //

    /**
    Deletes an already added Tag object

    - parameter tag: Tag object
    */
    func deleteTag(_ tag: TagControl) {
        _removeTag(tag)
    }

    /**
    Searches for Tag object and deletes

    - parameter object: Custom object
    */
    func deleteTagWithObject(_ object: AnyObject?) {
        if object == nil {return}
        for tag in _tagField.tags {
            if (tag.object!.isEqual(object)) {
                _removeTag(tag)
                break
            }
        }
    }

    /**
    Deletes all added tags. This doesn't delete sticky tag
    */
    func deleteAllTags() {
        if (_tagField.tags.count == 0) {return}
        var shouldDeleteAllTags: Bool? = true
        
        if let shouldRemoveAll = delegate?.tagViewShouldDeleteAllTag?(self) {
            shouldDeleteAllTags = shouldRemoveAll
        }
        
        if (shouldDeleteAllTags != true) {
            delegate?.tagViewDidFailToDeleteAllTags?(self)
            return
        }
        
        delegate?.tagViewWillDeleteAllTag?(self)
        for tag in _tagField.tags {_removeTag(tag, removingAll: true)}
        _tagField.updateLayout()
        delegate?.tagViewDidDeleteAllTag?(self)
        
        if (_showingSearchResult) {
            startSearchWithString(_lastSearchString)
        }
    }
    
    /**
    Deletes last added Tag object
    */
    func deleteLastTag() {
        let tag: TagControl? = _lastTag()
        if tag != nil {
            _removeTag(tag!)
        }
    }
    
    /**
    Deletes selected Tag object
    */
    func deleteSelectedTag() {
        let tag: TagControl? = selectedTag()
        if (tag != nil) {
            _removeTag(tag!)
        }
    }
    
    /**
    Returns Selected Tag object
    
    - returns: Tag object
    */
    func selectedTag() -> TagControl? {
        return _tagField.selectedTag
    }
    
    
    //MARK: - TagFieldDelegates
    //__________________________________________________________________________________
    //
    func tagFieldDidBeginEditing(_ tagField: TagField) {

        if editable {
            delegate?.tagViewDidBeginEditing?(self)
            print("edit frame : \(superview!.frame)", terminator: "")
            tagField.tagize()
        }
    }
    
    func tagFieldDidEndEditing(_ tagField: TagField) {
        if editable {
            delegate?.tagViewDidEndEditing?(self)
            tagField.untagize()
            _hideSearchResults()
        }
    }
    func tagFieldTextDidChange(_ tagField: TagField) {
        guard let string = tagField.text else{return}
            if string != ""{
            startSearchWithString(string)
          }

        
    }
    
    override func becomeFirstResponder() -> Bool {
        return _tagField.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        if (!addTagFromUntagizedText(_tagField)) {
            _tagField.resignFirstResponder()
        }
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        if !editable {
//            _tagField.becomeFirstResponder()
//        }
        return editable
    }
    
    //MARK: - Search
    //__________________________________________________________________________________
    //
    
    /**
    Triggers the search after user input text
    
    - parameter string: Search keyword
    */
    func startSearchWithString(_ string: String) {
        if (!_canAddMoreTag()) {
            return
        }
        print("startSearch", terminator: "")
        _showEmptyResults()
        _showActivityIndicator()
        
        let trimmedSearchString = string.trimmingCharacters(in: CharacterSet.whitespaces)
        delegate?.tagView(self, performSearchWithString:trimmedSearchString, completion: { (results) -> Void in
            self._hideActivityIndicator()
            if (results.count > 0) {
                self._displayData(results)
            }
        })
    }
    
    fileprivate func _displayData(_ results: Array<Tag>) {
        _resultArray = _filteredSearchResults(results)
        _searchTableView.reloadData()
        _showSearchResults()
    }
    
    fileprivate func _showEmptyResults() {
        print("showEmpty", terminator: "")
        _resultArray.removeAll(keepingCapacity: false)
        _searchTableView.reloadData()
        _showSearchResults()
    }
    
    fileprivate func _showSearchResults() {
        if (_tagField.isFirstResponder) {
            _showingSearchResult = true
            if (TagUtils.isIpad()) {
                _popover?.present(from: _tagField.frame, in: _tagField, permittedArrowDirections: .up, animated: false)
                
            } else {
                addSubview(_searchTableView)
                _searchTableView.frame.origin = CGPoint(x: 0, y: bounds.height)
                _searchTableView.isHidden = false
            }
        }
    }
    
    fileprivate func _hideSearchResults() {
        _showingSearchResult = false
        if (TagUtils.isIpad()) {
            _popover?.dismiss(animated: false)
            
        } else {
            _searchTableView.isHidden = true
            _searchTableView.removeFromSuperview()
        }
    }
    
    fileprivate func _repositionSearchResults() {
        if (!_showingSearchResult) {
            return
        }
        
        if (TagUtils.isIpad()) {
            if (_popover!.isPopoverVisible) {
                _popover?.dismiss(animated: false)
            }
            if (_showingSearchResult) {
                _popover?.present(from: _tagField.frame, in: _tagField, permittedArrowDirections: .up, animated: false)
            }
            
        } else {
            _searchTableView.frame.origin = CGPoint(x: 0, y: bounds.height)
            _searchTableView.layoutIfNeeded()
        }
        
    }
    
    fileprivate func _filteredSearchResults(_ results: Array <Tag>) -> Array <Tag> {
        var filteredResults: Array<Tag> = Array()
        
        for object: Tag in results {
            // Check duplicates in array
            var shouldAdd = !(filteredResults as NSArray).contains(object)
            
            if (shouldAdd) {
                if (!shouldDisplayAlreadyTagized && _tagField.tags.count > 0) {
                    
                    // Search if already tagized
                    for tag: TagControl in _tagField.tags {
                        if (object.name.isEqual(tag.object)) {
                            shouldAdd = false
                            break
                        }
                    }
                }
                
                if (shouldAdd && filteredResults.count < maxSearchResults) {
                    filteredResults.append(object)
                }
            }
        }
        
        if (shouldSortResultsAlphabatically) {
            return filteredResults.sorted(by: { s1, s2 in return self._sortStringForObject(s1) < self._sortStringForObject(s2) })
        }
        return filteredResults
    }
    
    fileprivate func _sortStringForObject(_ object: AnyObject) -> String {
        let tag = object as! Tag
        return tag.name
    }
    
    fileprivate func _showActivityIndicator() {
        _indicator.startAnimating()
        _searchTableView.tableHeaderView = _indicator
    }
    
    fileprivate func _hideActivityIndicator() {
        _indicator.stopAnimating()
        _searchTableView.tableHeaderView = nil
    }
    
    //MARK: - HitTest for _searchTableView
    //__________________________________________________________________________________
    //
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if (_showingSearchResult) {
            let pointForTargetView = _searchTableView.convert(point, from: self)
            
            if (_searchTableView.bounds.contains(pointForTargetView)) {
                return _searchTableView.hitTest(pointForTargetView, with: event)
            }
        }
        return super.hitTest(point, with: event)
    }
    
    //MARK: - Memory Mangement
    //__________________________________________________________________________________
    //
    deinit {
        
    }
    
}

//MARK: - Extension TagFieldDelegate
//__________________________________________________________________________________
//
extension TagView : TagFieldDelegate {
    func tagFieldDidSelectTag(_ tag: TagControl) {
        delegate?.tagView?(self, didSelectTag: tag)
    }
    
    func tagFieldShouldChangeHeight(_ height: CGFloat) {
    
    }
    
//    func tagFieldShouldChangeHeight(height: CGFloat) {
//        guard let delegate = delegate else { return }
//  //      delegate.tagView?(self, willChangeFrame: frame)
//        frame.size.height = height
//        
////        UIView.animateWithDuration(
////            animateDuration,
////            animations: {
////                self._tagField.frame.size.height = height
////                self._repositionSearchResults()
////            },
////            completion: {completed in
////                if (completed) {
////                    self.delegate?.tagView?(self, didChangeFrame: self.frame)
////                }
////        })
//    }
}


//MARK: - Extension UITextFieldDelegate
//__________________________________________________________________________________
//
extension TagView : UITextFieldDelegate {
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // If bacTagpace is pressed
        if (_tagField.tags.count > 0 && _tagField.text == TagTextEmpty && string.isEmpty == true && shouldDeleteTagOnBacTagpace) {
            if (_lastTag() != nil) {
                if (selectedTag() != nil) {
                    deleteSelectedTag()
                } else {
                    _tagField.selectTag(_lastTag()!)
                }
            }
            return false
        }
        
        // Prevent removing TagEmptyString
        if (string.isEmpty == true && _tagField.text == TagTextEmpty) {
            return false
        }
        
        var searchString: String
        let olderText = _tagField.text
        
        // TODO: Test with different keyboards
        if _tagField.markedTextRange != nil {
            // Marked.
            print("marked", terminator: "")
            print(_tagField.markedTextRange!, terminator: "")
            
            let location = _tagField.offset(from: _tagField.beginningOfDocument, to: _tagField.markedTextRange!.start)
            let length = _tagField.offset(from: _tagField.markedTextRange!.start, to: _tagField.markedTextRange!.end)
            
            let range = NSMakeRange(location, length)
            print(range, terminator: "")
            print(_tagField.text(in: _tagField.markedTextRange!), terminator: "")
            
            
            
          // olderText = _tagField.markedTextRange
        }
        
        // Check if character is removed at some index
        // Remove character at that index
        if (string.isEmpty) {
            let first: String = olderText!.substring(to: olderText!.characters.index(olderText!.startIndex, offsetBy: range.location)) as String
            let second: String = olderText!.substring(from: olderText!.characters.index(olderText!.startIndex, offsetBy: range.location+1)) as String
            searchString = first + second
        }  else { // new character added
            let stringArray = Array(arrayLiteral: string)
            var contains = false
            for char in tagizingCharacters {
                if (stringArray as NSArray).contains(char) {
                    contains = true
                }
            }
            if (contains && olderText != TagTextEmpty && olderText!.trimmingCharacters(in: CharacterSet.whitespaces) != "") {
                addTagWithTitle(olderText!, tagObject: nil)
                return false
            }
            searchString = olderText!+string
        }
        
        // Allow all other characters
        if (searchString.characters.count >= minimumCharactersToSearch && searchString != "\n") {
            _lastSearchString = searchString
            startSearchWithString(_lastSearchString)
        }
        _tagField.scrollViewScrollToEnd()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        return true
    }
}

//MARK: - Extension UITableViewDelegate
//__________________________________________________________________________________
//

extension TagView : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        delegate?.tagView?(self, didSelectRowAtIndexPath: indexPath)
        let tag = _resultArray[(indexPath as NSIndexPath).row]
         addTag(TagControl(title: tag.name, object: tag))
        if (shouldHideSearchResultsOnSelect) {
            _hideSearchResults()
            
        } else if (!shouldDisplayAlreadyTagized) {
            _resultArray.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
        }
    }
}

//MARK: - Extension UITableViewDataSource
//__________________________________________________________________________________
//
extension TagView : UITableViewDataSource {
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _resultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = delegate?.tagView?(self, withObject: _resultArray[(indexPath as NSIndexPath).row], tableView: tableView, cellForRowAtIndexPath: indexPath)
        if cell != nil {
            return cell!
        }
        
        let cellIdentifier = "TagSearchTableCell"
        cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: cellIdentifier)
        }
        
        let tag = _resultArray[(indexPath as NSIndexPath).row]
        cell!.textLabel!.text = (tag.name != nil) ? tag.name : "No Title"
        cell!.selectionStyle = UITableViewCellSelectionStyle.none
        cell?.textLabel?.textColor = UIColor.white
        cell?.backgroundColor = UIColor.clear
        
        return cell!
    }
}


//MARK: - Extension UIPopoverControllerDelegate
//__________________________________________________________________________________
//
extension TagView : UIPopoverControllerDelegate {
    func popoverControllerDidDismissPopover(_ popoverController: UIPopoverController) {
        _showingSearchResult = false
    }
}
