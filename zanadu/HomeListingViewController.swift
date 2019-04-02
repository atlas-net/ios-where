//
//  HomeListingViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/28/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//


enum HomeListingState {
    case tribe
    case venue
}

/**
Display a page with cover, tabs and listings
*/
class HomeListingViewController : BaseViewController {
    
    //MARK: - Properties
    
    var state: HomeListingState!
    
    
    //MARK: - Outlets
    
    weak var recommendationStream: RecommendationStreamView!
    
    //MARK: - Actions
    
    
    //MARK: - Methods
    
    
    //MARK: - ViewController's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}
