//
//  RecommendationSectionView.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/22/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



/**
RecommendationSectionView

Display a section of recommendation define by the Section attribute
*/
class RecommendationSectionView : UIView {
    
    //MARK: - Properties
    
    var section: Section!
    var sectionListButton: UIButton!
    var sectionItemButton: UIButton!
    var layoutView: GenericLayoutView<RecommendationView>!
    var container: ResizableLayoutItemContainer?
    var recommendationSelectionDelegate: RecommendationSelectionProtocol?
    var sectionSelectionDelegate: SectionSelectionProtocol?
    var sectionNum = 0

    var tmpHeight: CGFloat = 0
    
    //MARK: - Initializers
    
    func getRecommendationViews() -> [RecommendationView] {
        return layoutView.getItems() 
    }
    
    //MARK: - Actions
    
    func onSectionListButtonTapped() {
        if let delegate = sectionSelectionDelegate {
            delegate.onSectionButtonSelected(section)
        }
    }
    
    
    func onSectionItemButtonTapped() {
        if section.isAroundMeSection() {
            if let delegate = sectionSelectionDelegate {
                delegate.onSectionItemButtonSelected!(section)
            }
        }else{
            onSectionListButtonTapped()
        }
    }

    //MARK: - Methods
    func setup(_ section: Section, recommendations: [Recommendation]) {
        self.section = section
        
        backgroundColor = UIColor.clear
        
        let buttonPaddingLeft: CGFloat = 6
        let buttonPaddingTop: CGFloat = 8
        let buttonFont = UIFont.boldSystemFont(ofSize: 18)
        
        let title = NSString(string: section.title!)
        let textSize = title.size(attributes: [NSFontAttributeName: buttonFont])
        sectionListButton = UIButton(frame: CGRect(x: buttonPaddingLeft, y: buttonPaddingTop, width: textSize.width + 32, height: 27))
        sectionListButton.contentHorizontalAlignment = .left
        sectionListButton.titleLabel?.font = buttonFont
        sectionListButton.setTitleColor(Config.Colors.SectionTextColor, for: UIControlState())
//        sectionListButton.cornerRadius = sectionListButton.frame.height / 8
//        sectionListButton.layer.borderColor = Config.Colors.SectionTextColor.CGColor
//        sectionListButton.layer.borderWidth = 1
        sectionListButton.titleLabel?.textAlignment = NSTextAlignment.center
        sectionListButton.setTitle(section.title!, for: UIControlState())

        sectionListButton.addTarget(self, action: #selector(RecommendationSectionView.onSectionListButtonTapped), for: UIControlEvents.touchUpInside)
        addSubview(sectionListButton)
        
        sectionItemButton = UIButton(type: .custom)
        sectionItemButton.frame = CGRect(x: self.frame.width - sectionListButton.frame.height - buttonPaddingLeft, y: buttonPaddingTop + 6, width: sectionListButton.frame.height, height: 25)
        
        
        sectionItemButton.addTarget(self, action: #selector(RecommendationSectionView.onSectionItemButtonTapped), for: UIControlEvents.touchUpInside)
        addSubview(sectionItemButton)
        if section.isAroundMeSection() {
            sectionItemButton.setImage(UIImage(named: "icon_map")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
        }else{
            sectionItemButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            sectionItemButton.setTitle(NSLocalizedString("More", comment: "更多"), for: UIControlState())
            sectionItemButton.setImage(UIImage(named: "arrow_right")!.withRenderingMode(.alwaysTemplate), for: UIControlState())
            sectionItemButton.imageView?.contentMode = .center
            let width = sectionItemButton.titleLabel?.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 16))
            let moreSectionItemButtonWidth = width!.width + 25
              sectionItemButton.frame = CGRect(x: self.frame.width - moreSectionItemButtonWidth - buttonPaddingLeft, y: buttonPaddingTop + 6, width: moreSectionItemButtonWidth,  height: 16)
            sectionItemButton.setTitleColor(Config.Colors.SectionImageItemColor, for: UIControlState())
            sectionItemButton.imageEdgeInsets = UIEdgeInsetsMake(0, width!.width + 20, 0, 0)
        }
        sectionItemButton.tintColor = Config.Colors.SectionImageItemColor

        
        var recommendationViews = [RecommendationView]()

        for (index, recommendation) in recommendations.enumerated() {
            if let view:RecommendationView = Bundle.main.loadNibNamed("RecommendationView", owner: self, options: nil)?[0] as? RecommendationView {
                view.sectionNum = self.sectionNum
                view.rowNum = index
                recommendationViews.append(view)
                configureView(view, withRecommendation: recommendation)
            }
        }
        layoutView = GenericLayoutView<RecommendationView>(frame: CGRect(x: 0, y: buttonPaddingTop + sectionListButton.frame.height + 8, width: self.frame.width, height: 0))
        
        layoutView.padding = 0
        layoutView.cellPadding = 6
        layoutView.cellBorderColor = UIColor.white
        layoutView.cellBorderWidth = 0
        layoutView.backgroundColor = UIColor.clear

        addSubview(layoutView)

        if section.style == 1{
            layoutView.setup(recommendationViews, template: GenericLayoutName.halfWidthOneRow, delegate: self)
        }else{
            layoutView.setup(recommendationViews, template: GenericLayoutName.fullWidthOneRow, delegate: self)
        }
        

        tmpHeight = self.frame.height
    }

    func endSetup() {
        if let container = container {
            let height = tmpHeight
            container.onHeightUpdated(height, forItem: self)
        }
    }
    
    func configureView(_ recommendationView: RecommendationView, withRecommendation recommendation: Recommendation) {
        recommendationView.recommendation = recommendation
        recommendationView.delegate = self.recommendationSelectionDelegate
        recommendationView.addTapListeners()

        recommendationView.backgroundColor = UIColor.clear
        recommendationView.titleLabel.text = recommendation.title
        recommendationView.coverImageView.contentMode = UIViewContentMode.scaleAspectFill

        if let cover = recommendation.cover {
            if let coverFile = cover.file {
                let imageV = UIImageView()
                imageV.backgroundColor = UIColor.red
                imageV.image = UIImage(named: "itemDefaultImage")
                self.setupRecommendationViewCover(recommendationView, imageV: imageV)
                imageV.image = nil
                coverFile.getImageWithBlock(withBlock: { (image, error) -> Void in
                    if error != nil {
                        log.error(error?.localizedDescription)
                    } else {
                        imageV.image = image
                        self.setupRecommendationViewCover(recommendationView, imageV: imageV)
                    }
                })
            }
        }
        configureViewBottomElements(recommendationView)
    }
    
    func setupRecommendationViewCover(_ recommendationView: RecommendationView, imageV: UIImageView) {
        if recommendationView.frame.width > self.frame.width / 2{
            recommendationView.coverImageView.image = UIImage(named: "effectCover254")
        }
        recommendationView.coverImageView.image = imageV.image
        recommendationView.layer.cornerRadius = 5 //recommendationView.coverImageView.frame.height * Config.AppConf.SmallCornerRadiusFactor
        recommendationView.clipsToBounds = true
    }
    
    func configureViewBottomElements(_ recommendationView: RecommendationView) {
        if let user = User.current() as? User{
        user.isLiking(recommendationView.recommendation!, completion: { (isLiking) -> () in
            if isLiking {
                recommendationView.likeImageView.image = UIImage(named: "icon_like")
            } else {
                recommendationView.likeImageView.image = UIImage(named: "icon_dislike")
            }
        })
        }else{
            recommendationView.likeImageView.image = UIImage(named: "icon_dislike")
        }
        
        DataQueryProvider.likesForRecommendation(recommendationView.recommendation!).executeInBackground { (objects:[Any]?, error) -> () in
            if error != nil {
                log.error("Fetching likes for recommendation error : \(error?.localizedDescription)")
            } else {
                recommendationView.likeLabel.text = String(describing: objects!.count)
            }
        }
        
        if section.isAroundMeSection() || recommendationView.recommendation!.type?.intValue == RecommendationContentType.list.rawValue{
            recommendationView.coordinateImageView.isHidden = true
            recommendationView.coordinateLabel.isHidden = true
        } else {
            let location = Location.shared
            
            recommendationView.recommendation!.distanceToLocation(location, completion: { (dist:Double) -> () in
                
                let distance = FormatingHelper.distanceFormater(dist)
                
                if distance != "" {
                    recommendationView.coordinateLabel.text = distance
                } else {
                    recommendationView.coordinateImageView.isHidden = true
                    recommendationView.coordinateLabel.isHidden = true
                }
            })
        }
    }
    
    //MARK: - Overrides
    
    override func update() {
        super.update()

        if let layout = self.layoutView {
            let items = layout.getItems()

            for item in items {
                configureViewBottomElements(item)
            }
        }
    }
}


extension RecommendationSectionView: GenericLayoutDelegate {
    func onLayoutHeightCalculated(_ height: CGFloat) {
        self.frame.size.height = height + (16 + self.sectionListButton.frame.height  + 8)
    }
}
