//
//  SectionsStreamView.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/22/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//



//import GenericLayoutView

protocol RecommendationSectionsStreamViewHeightDelegate {
    func onHeightChanged(_ height: CGFloat)
}

/**
RecommendationSectionsStreamView

Display a stream of RecommendationSectionView
*/
class RecommendationSectionsStreamView : UIView {
    
    //MARK: - Properties
    var sections: [Section]!
    var layoutView: GenericLayoutView<RecommendationSectionView>!
    var heightChangeDelegate: RecommendationSectionsStreamViewHeightDelegate?
    var recommendationSelectionDelegate: RecommendationSelectionProtocol?
    var sectionSelectionDelegate: SectionSelectionProtocol?

    let padding: CGFloat = 6
    
    //MARK: - Outlets

    //MARK: - Initializers

    //MARK: - Actions

    //MARK: - Methods
    
    func getRecommendationViews() -> [RecommendationView] {
        let sectiobViews = layoutView.getItems() 
        var recommendationViews :[RecommendationView] = []
        sectiobViews.forEach { (sectionView) in
            recommendationViews.append(contentsOf: sectionView.getRecommendationViews())
        }
        return recommendationViews
    }
    
    func setup(_ sections:[Section]) {
        var sectionViews = [RecommendationSectionView]()

        backgroundColor = UIColor.clear

        layoutView = GenericLayoutView<RecommendationSectionView>(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))


        var count = 0
        let expected = sections.count
        let location = Location.shared
        for section in sections {
            if section.isAroundMeSection()  {
                if location.coordinate.latitude == 0 && location.coordinate.longitude == 0{
                    if sections.count == 1{
                        heightChangeDelegate?.onHeightChanged(0)
                    }
                    continue
                }
            }
            configureView(section) { (sectionView) -> () in
                if let view = sectionView {
                    view.sectionNum = Int(section.position?.intValue ?? Int.max)
                    sectionViews.append(view)
                }
                count += 1
                if count == expected {
                    
                    self.layoutView.padding = self.padding
                    self.layoutView.cellPadding = 0
                    self.layoutView.cellBorderColor = UIColor.black
                    self.layoutView.cellBorderWidth = 0
                    self.layoutView.backgroundColor = UIColor.clear
                    self.addSubview(self.layoutView)
                    sectionViews.sort() {
                        $0.sectionNum < $1.sectionNum
                    }
                    self.layoutView.setup(sectionViews, template: GenericLayoutName.fullWidthOneRow, delegate: self)
                    
                    for sectionView in sectionViews {
                        sectionView.endSetup()
                    }
                }
            }
        }
    }

    func configureView(_ section: Section, completion: @escaping (RecommendationSectionView?) -> ()) {
        let recommendationSectionView = RecommendationSectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width - padding * 2, height: self.frame.height - padding * 2))

        recommendationSectionView.recommendationSelectionDelegate = recommendationSelectionDelegate
        recommendationSectionView.sectionSelectionDelegate = sectionSelectionDelegate
        recommendationSectionView.container = layoutView
    
        let recommendationQuery: Query?
        if section.type!.intValue == SectionType.dynamic.rawValue
        || section.type!.intValue == SectionType.aroundMe.rawValue {
            
            recommendationQuery = section.queryMatchingConditionsWithLatestDate(nil, oldestDate: nil)
        } else if section.type!.intValue == SectionType.normal.rawValue {
            let tmpQuery = section.recommendations?.query() 
//            tmpQuery!.limit = section.limit!.intValue
            tmpQuery!.cachePolicy = AVCachePolicy.networkElseCache
            tmpQuery!.includeKey("cover")
            tmpQuery!.whereKeyExists("title")
            tmpQuery!.whereKeyExists("cover")
            tmpQuery!.whereKeyExists("author")
            tmpQuery!.order(byDescending: "createdAt")
            tmpQuery!.whereKey("status", greaterThan: 0)
            recommendationQuery = SimpleQuery(query: tmpQuery!)
        } else {
            recommendationQuery = nil
        }
        
        if let recommendationQuery = recommendationQuery {
            recommendationQuery.executeInBackground({ (objects: [Any]?, error) -> () in
                
                if error != nil {
                    log.error("Section recommendations fetching error : \(error?.localizedDescription)")
                    recommendationSectionView.frame = CGRect.zero
                    completion(nil)
                } else if let recommendations = objects as? [Recommendation] , (objects?.count)! > 0 {

                    recommendationSectionView.setup(section, recommendations: recommendations)
                    completion(recommendationSectionView)
                } else {

                    recommendationSectionView.frame = CGRect.zero
                    completion(nil)
                }
                
            })
        } else {
            recommendationSectionView.frame = CGRect.zero
            completion(nil)
        }
    }
}

extension RecommendationSectionsStreamView: GenericLayoutDelegate {
    func onLayoutHeightCalculated(_ height: CGFloat) {
        
        self.frame.size.height = height
        heightChangeDelegate?.onHeightChanged(height)
        self.clipsToBounds = true
    }
}
