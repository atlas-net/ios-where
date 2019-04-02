//
//  UITagSelectionView.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/17/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



protocol UITagSelectionViewExpansionDelegate {
    func expandTagSelectionView()
    func reduceTagSelectionView()
}

let CPMaxTagsInLists = 8


/**
Display a tag field an tags propositions
*/
class UITagSelectionView : UIView {
    
    //MARK: - Properties
    ///show delete Btn  or not
    var isShowDeleteBtn = false
    let searchResultHeight: CGFloat = 82
    
    var expansionDelegate: UITagSelectionViewExpansionDelegate?
    
    var currentTagsArray = [Tag]() {
        didSet {

        }
    }
    var popularTagsArray = [Tag]()
    var recentTagsArray = [Tag]()
    
    var inputTagView: TagView!
    var popularTagView: TagView!
    var recentTagView: TagView!
    
    var popularTagLabel: UILabel!
    var recentTagLabel: UILabel!

    var inputTagViewTopConstraint: NSLayoutConstraint?
    var inputTagViewHeightConstraint: NSLayoutConstraint?
    
    var separator1TopConstraint: NSLayoutConstraint?
    
    var popularTagLabelTopConstraint: NSLayoutConstraint?
    var popularTagLabelHeightConstraint: NSLayoutConstraint?

    var popularTagViewTopConstraint: NSLayoutConstraint?
    var popularTagViewHeightConstraint: NSLayoutConstraint?

    var separator2TopConstraint: NSLayoutConstraint?
    
    var recentTagLabelTopConstraint: NSLayoutConstraint?
    var recentTagLabelHeightConstraint: NSLayoutConstraint?
    
    var recentTagViewTopConstraint: NSLayoutConstraint?
    var recentTagViewHeightConstraint: NSLayoutConstraint?
    
    var inputViewReducedBackgroundColor = Config.Colors.MainContentBackgroundWhite
    var inputViewExpandedBackgroundColor = UIColor.white
    
    
    //MARK: - Outlets
    
    
    //MARK: - Inspectables
    
    @IBInspectable var padding: CGFloat = 0
    @IBInspectable var innerPadding: CGFloat = 0
    @IBInspectable var innerTopPadding: CGFloat = 0
    @IBInspectable var popularTagLabelText: String = "popular"
    @IBInspectable var recentTagLbelText: String = "recent"

    
    //MARK: - Actions
    
    
    //MARK: - Methods
    
    func setup(_ delegate: TagViewDelegate? = nil, displayOnly: Bool = false) {
        backgroundColor = UIColor.white
        if inputTagView != nil{
            inputTagView.removeFromSuperview()
        }
        //init tagview
        inputTagView = TagView(frame: CGRect.zero)
        inputTagView.isShowDeleteBtn = self.isShowDeleteBtn
        addSubview(inputTagView)
        
        inputTagView.translatesAutoresizingMaskIntoConstraints = false

        log.error("padding : \(self.padding)")
        
        let inputTagViewLeading = NSLayoutConstraint(item: inputTagView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leadingMargin, multiplier: 1, constant: padding)

        let inputTagViewTrailing = NSLayoutConstraint(item: inputTagView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailingMargin, multiplier: 1, constant: -padding)

        inputTagViewTopConstraint = NSLayoutConstraint(item: inputTagView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.topMargin, multiplier: 1, constant: -innerPadding)

        inputTagViewHeightConstraint = NSLayoutConstraint(item: inputTagView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 44)

        log.error("frame height :  \(self.frame.height)")


        let inputTagViewBottomConstraint = NSLayoutConstraint(item:inputTagView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: 0)
        inputTagViewBottomConstraint.priority = 700
        
        addConstraints([inputTagViewLeading, inputTagViewTrailing,inputTagViewTopConstraint!, inputTagViewBottomConstraint])
        inputTagView.addConstraint(inputTagViewHeightConstraint!)

        layoutIfNeeded()
        inputTagView.layoutIfNeeded()

        inputTagView.commonSetup()

        
        if delegate != nil {
            inputTagView.delegate = delegate
        } else {
            inputTagView.delegate = self
        }
        
        inputTagView.promptText = ""
        inputTagView.editable = true
        inputTagView.direction = .horizontal
        inputTagView.style = .none
        inputTagView.placeholder = NSLocalizedString("Add tag...", comment:"添加标签...")
        inputTagView.marginX = 12
        inputTagView.marginY = 12
        inputTagView.descriptionText = "selected tags"
        inputTagView.style = TagViewStyle.rounded
        inputTagView.searchResultBackgroundColor = UIColor.clear
        inputTagView.backgroundColor = inputViewReducedBackgroundColor
        inputTagView.activityIndicatorColor = Config.Colors.ZanaduCerisePink
        
        
        log.error("frame height :  \(self.inputTagView._tagField.frame.height)")

        self.inputTagView._tagField.textColor = Config.Colors.MainContentColorBlack

        popularTagLabel = UILabel(frame: CGRect.zero)
        popularTagView = TagView(frame: CGRect(x: 0,y: 0,width: frame.width,height: 100))
        recentTagLabel = UILabel(frame: CGRect.zero)
        recentTagView = TagView(frame: CGRect.zero)

        
        addSubview(popularTagLabel)
        addSubview(popularTagView)
        addSubview(recentTagLabel)
        addSubview(recentTagView)

    
        let separator1 = UIView(frame:CGRect.zero)
        separator1.backgroundColor = Config.Colors.MainContentBackgroundWhite
        addSubview(separator1)
        
        separator1.translatesAutoresizingMaskIntoConstraints = false
        
        let separator1Leading = NSLayoutConstraint(item: separator1, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leadingMargin, multiplier: 1, constant: padding)
        
        let separator1Trailing = NSLayoutConstraint(item: separator1, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailingMargin, multiplier: 1, constant: -padding)
        
        separator1TopConstraint = NSLayoutConstraint(item: separator1, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: inputTagView, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: 0 + innerTopPadding * 2)
        
        let separator1HeightConstraint = NSLayoutConstraint(item: separator1, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 2)
        
        addConstraints([separator1Leading, separator1Trailing, separator1TopConstraint!])
        separator1.addConstraint(separator1HeightConstraint)
        
        layoutIfNeeded()
        separator1.layoutIfNeeded()
        
        
        
        popularTagLabel.text = popularTagLabelText
        popularTagLabel.textColor = Config.Colors.LightGreyTextColor
        popularTagLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let popularTagLabelLeading = NSLayoutConstraint(item: popularTagLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leadingMargin, multiplier: 1, constant: padding)

        let popularTagLabelTrailing = NSLayoutConstraint(item: popularTagLabel, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailingMargin, multiplier: 1, constant: -padding)

        popularTagLabelTopConstraint = NSLayoutConstraint(item: popularTagLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: separator1, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: innerTopPadding)

        popularTagLabelHeightConstraint = NSLayoutConstraint(item: popularTagLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 30)
        
        self.addConstraints([popularTagLabelLeading, popularTagLabelTrailing, popularTagLabelTopConstraint!])
        popularTagLabel.addConstraint(popularTagLabelHeightConstraint!)
        
        
        popularTagView.translatesAutoresizingMaskIntoConstraints = false
        
        let popularTagViewLeading = NSLayoutConstraint(item: popularTagView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leadingMargin, multiplier: 1, constant: padding)
        
        let popularTagViewTrailing = NSLayoutConstraint(item: popularTagView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailingMargin, multiplier: 1, constant: -padding)
        
        popularTagViewTopConstraint = NSLayoutConstraint(item: popularTagView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: popularTagLabel, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: innerPadding)
        
        popularTagViewHeightConstraint = NSLayoutConstraint(item: popularTagView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 52)
        
        addConstraints([popularTagViewLeading, popularTagViewTrailing, popularTagViewTopConstraint!])
        popularTagView.addConstraint(popularTagViewHeightConstraint!)
        
        layoutIfNeeded()
        popularTagView.layoutIfNeeded()
        popularTagView.autoScrollToEnd = false
        
        if !self.isShowDeleteBtn{
        popularTagView.commonSetup()
        }
        
        popularTagView.delegate = self
        popularTagView.editable = false
        popularTagView.promptText = ""
        popularTagView.maximumHeight = 52
        popularTagView.backgroundColor = UIColor.clear
        
        
        /****************************************************/
        //separator
        
        let separator2 = UIView(frame:CGRect.zero)
        separator2.backgroundColor = Config.Colors.MainContentBackgroundWhite
        addSubview(separator2)
        
        separator2.translatesAutoresizingMaskIntoConstraints = false
        
        let separator2Leading = NSLayoutConstraint(item: separator2, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leadingMargin, multiplier: 1, constant: padding)
        
        let separator2Trailing = NSLayoutConstraint(item: separator2, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailingMargin, multiplier: 1, constant: -padding)
        
        separator2TopConstraint = NSLayoutConstraint(item: separator2, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: popularTagView, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: innerTopPadding)
        
        let separator2HeightConstraint = NSLayoutConstraint(item: separator2, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 2)
        
        addConstraints([separator2Leading, separator2Trailing, separator2TopConstraint!])
        separator2.addConstraint(separator2HeightConstraint)
        
        layoutIfNeeded()
        separator2.layoutIfNeeded()
        


        
        /****************************************************/
        
        recentTagLabel.text = recentTagLbelText
        recentTagLabel.textColor = Config.Colors.LightGreyTextColor
        recentTagLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let recentTagLabelLeading = NSLayoutConstraint(item: recentTagLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leadingMargin, multiplier: 1, constant: 0)
        
        let recentTagLabelTrailing = NSLayoutConstraint(item: recentTagLabel, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailingMargin, multiplier: 1, constant: -0)
        
        recentTagLabelTopConstraint = NSLayoutConstraint(item: recentTagLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: separator2, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: innerTopPadding)
        
        recentTagLabelHeightConstraint = NSLayoutConstraint(item: recentTagLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 30)
        
        self.addConstraints([recentTagLabelLeading, recentTagLabelTrailing, recentTagLabelTopConstraint!])
        recentTagLabel.addConstraint(recentTagLabelHeightConstraint!)

        

        recentTagView.translatesAutoresizingMaskIntoConstraints = false
        
        let recentTagViewLeading = NSLayoutConstraint(item: recentTagView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leadingMargin, multiplier: 1, constant: 0)
        
        let recentTagViewTrailing = NSLayoutConstraint(item: recentTagView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailingMargin, multiplier: 1, constant: -0)
        
        recentTagViewTopConstraint = NSLayoutConstraint(item: recentTagView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: recentTagLabel, attribute: NSLayoutAttribute.bottomMargin, multiplier: 1, constant: innerPadding)
        
        recentTagViewHeightConstraint = NSLayoutConstraint(item: recentTagView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 52)
        
        addConstraints([recentTagViewLeading, recentTagViewTrailing, recentTagViewTopConstraint!])
        recentTagView.addConstraint(recentTagViewHeightConstraint!)
        
        layoutIfNeeded()
        recentTagView.layoutIfNeeded()
        if !self.isShowDeleteBtn{
        recentTagView.commonSetup()
        }
        
        
        recentTagView.delegate = self
        recentTagView.editable = false
        recentTagView.promptText = ""
        recentTagView.maximumHeight = 52
        recentTagView.backgroundColor = UIColor.clear
        

        if !displayOnly {
            fetchTagData()
        }
    }
    
    func addTags(_ tags: [Tag]) {
        //currentTagsArray += tags



        for tag in tags {
            inputTagView.addTag(TagControl(title: tag.name, object: tag))
        }
        
        inputTagView.tagize()
    }

    
    func setTagControls(_ tags: [TagControl]) {
        
        inputTagView.deleteAllTags()
        
        for tag in tags {
            inputTagView.addTag(tag)
        }
        
        inputTagView.tagize()
    }
    func setTagsWithNoDelegateAdd(_ tags: [Tag]) {
        //self.currentTagsArray = tags
        
        inputTagView.deleteAllTags()
        
        for tag in tags {
            let aTagControl = TagControl(title: tag.name, object: tag)
            aTagControl.isShowDeleteBtn = self.isShowDeleteBtn
            inputTagView.addTagWithNoDelegate(aTagControl)
        }
        
        inputTagView.tagize()
    }

    func setTags(_ tags: [Tag]) {
        //self.currentTagsArray = tags

        inputTagView.deleteAllTags()
        
        for tag in tags {
            inputTagView.addTag(TagControl(title: tag.name, object: tag))
        }
        
        inputTagView.tagize()
    }
    
    func getTags() -> [Tag] {


        var tagArray = [Tag]()
        
        if let inputTags = inputTagView.tags() {
            for tagCtrl in inputTags {                
                let tag: Tag
                if tagCtrl.object is Tag {
                    tag = tagCtrl.object as! Tag
                } else {
                    tag = Tag(name: tagCtrl.title, author: User.current() as! User)
                }
                
                tagArray.append(tag)
            }
        }
        
        return tagArray
    }
    
    
    fileprivate func fetchTagData() {
        // get recently used tags
        var query: AVQuery = AVQuery(className: "Tag")
        if let tagIds = LocalRecentTagsHandler().getTagIds(){
            query.whereKey("objectId", containedIn: tagIds)
            query.findObjectsInBackground({ (objects, error) -> Void in
                if error != nil {
                    log.error(error?.localizedDescription)
                } else if let recentTags = objects as? [Tag] {
                    self.recentTagsArray += recentTags
                    for tag in self.recentTagsArray {
                        self.recentTagView.addTagWithTitle(tag.name, tagObject: tag)
                    }
                    self.recentTagView.tagize()
                    self.recentTagView._tagField.disableTagsScrolling()
                    
                }
            })
            
        }
        
        // get popular tags
        query = AVQuery(className: "Tag")
        query.order(byDescending: "popularity")
        query.limit = CPMaxTagsInLists
        query.findObjectsInBackground({ (objects, error) -> Void in
            if error != nil {
                log.error(error?.localizedDescription)
            } else if let popularTags = objects as? [Tag] {
                self.popularTagsArray += popularTags
                for tag in self.popularTagsArray {
                    self.popularTagView.addTagWithTitle(tag.name, tagObject: tag)
                }
                self.popularTagView.tagize()
                self.popularTagView._tagField.disableTagsScrolling()

            }
        })
        
    }
}

extension UITagSelectionView: TagViewDelegate {
    
    func tagView(_ tagView:TagView, performSearchWithString string: String, completion: ((_ results: Array<Tag>) -> Void)?) {
        
        if tagView == inputTagView {
            if string != "" {
                print("searchString : \(string)", terminator: "")
                
                // get recently used tags
                let query: AVQuery = AVQuery(className: "Tag")
                query.whereKey("name", matchesRegex: "\(string)", modifiers: "iu")
                query.order(byDescending: "popularity")
                query.limit = 10
                
                query.findObjectsInBackground({ (tags, error) -> Void in
                    if error != nil {
                        print(error, terminator: "")
                        return
                    }
                    
                    print("found tags : \(tags)", terminator: "")
                    let tags = tags as! [Tag]
//                    var tagNames = [String]()
//                    if let tags = tags as? [Tag] {
//                        for tag in tags {
//                            tagNames.append(tag.name)
//                        }
//                    }
                    completion!(tags)
                    if (self.separator1TopConstraint?.constant)! < self.searchResultHeight {
                        self.separator1TopConstraint?.constant += self.searchResultHeight
                    }
                })
            } else {
                completion!([Tag]())
                if (self.separator1TopConstraint?.constant)! >= self.searchResultHeight {
                    self.separator1TopConstraint?.constant -= self.searchResultHeight
                }
            }
        }
    }
    
    func tagViewDidBeginEditing(_ tagView: TagView) {
        print("start editing tags", terminator: "")
        print(frame, terminator: "")
        
        expansionDelegate!.expandTagSelectionView()
        
        
//        superview?.backgroundColor = Config.Colors.TagViewBackground
        
//        inputTagView.backgroundColor = inputViewExpandedBackgroundColor
        backgroundColor = inputViewExpandedBackgroundColor
        
        popularTagView._tagField.updateLayout()
        
        for v in popularTagView._tagField._scrollView.subviews {
            v.setNeedsDisplay()
        }

        recentTagView._tagField.updateLayout()

        for v in recentTagView._tagField._scrollView.subviews {
            v.setNeedsDisplay()
        }
        
        inputTagViewTopConstraint?.constant = padding

        
//        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
//            self.popularTagLabel.frame.origin.y += tagView.searchResultSize.height
//            self.popularTagView.frame.origin.y += tagView.searchResultSize.height
//            self.recentTagLabel.frame.origin.y += tagView.searchResultSize.height
//            self.recentTagView.frame.origin.y += tagView.searchResultSize.height
//            
//            }) { (finished) -> Void in
//                println(self.frame)
//        }
    }
    
    func tagViewDidEndEditing(_ tagView: TagView) {
        print("end editing tags", terminator: "")
        print(frame, terminator: "")
        
        expansionDelegate?.reduceTagSelectionView()
        
//        superview?.backgroundColor = inputViewReducedBackgroundColor
        
//        inputTagView.backgroundColor = inputViewReducedBackgroundColor
//        backgroundColor = inputViewExpandedBackgroundColor
        
        
        inputTagViewTopConstraint?.constant = -innerPadding
        
        
//        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 3.5, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
//            self.popularTagLabel.frame.origin.y -= tagView.searchResultSize.height
//            self.popularTagView.frame.origin.y -= tagView.searchResultSize.height
//            self.recentTagLabel.frame.origin.y -= tagView.searchResultSize.height
//            self.recentTagView.frame.origin.y -= tagView.searchResultSize.height
//            }) { (finished) -> Void in
//                println(self.frame)
//        }
    }
    
    func tagView(_ selectedTagView: TagView, didSelectTag tag: TagControl) {
        if !selectedTagView.editable {
            print("didSelectTag / editable : \(selectedTagView.editable)", terminator: "")
            print(selectedTagView, terminator: "")
            //            self.tagView.addTag(tag)
            let tag2:TagControl = TagControl(title: tag.title, object: tag.object)
            
            self.inputTagView.tagize()
            self.inputTagView.addTag(tag2)
            self.inputTagView.tagize()
            //            self.tagView.deleteTag(tag2)
            //          self.tagView.tagize()
            
            self.inputTagView.setNeedsLayout()
            self.inputTagView.layoutIfNeeded()
            self.inputTagView.setNeedsDisplay()
//            selectedTagView.deleteTag(tag)
        }
    }
    
    func tagView(_ tag: TagView, displayTitleForObject object: AnyObject) -> String {
        return object as! String
    }
    
    func tagView(_ tagView: TagView, didAddTag tagCtrl: TagControl) {
        if tagView === self.inputTagView {
            let tag: Tag
            if tagCtrl.object is Tag {
                tag = tagCtrl.object as! Tag
            } else {
                tag = Tag(name: tagCtrl.title, author: User.current() as! User)
            }
            currentTagsArray.append(tag)
        }
    }
    
    func tagView(_ tagView: TagView, didDeleteTag tag: TagControl) {
        if tagView === self.inputTagView {
            print("REMOVED TAG", terminator: "")
            if let index = find(currentTagsArray, predicate: { (foundTag: Tag) -> Bool in foundTag.name == tag.title}) {
                currentTagsArray.remove(at: index)
            }
            
        }
    }
}
