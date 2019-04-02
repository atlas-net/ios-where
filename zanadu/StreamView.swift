//
//  StreamView.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/12/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

@objc
protocol StreamViewDelegate : NSObjectProtocol{
    @objc optional func onDataFetched(_ streamView: StreamView, objects: [AnyObject])
    @objc optional func onHeightChanged(_ height:CGFloat)
    @objc optional func onHeightChangedWithStream(_ streamView: StreamView,height:CGFloat)
    @objc optional func recommendationCount(_ count:Int)
}

class StreamView : UITableView, UITableViewDelegate {
    
    //MARK: - Properties
    var paging = false
    var currentPage = 0
    var itemsPerPage = 20
    var totalItems = -1

    var isResetting: Bool = false

    let loadingCellIdentifier = "LoadingViewCell"
    let loadingCellTag = 16644242
    weak var streamViewDelegate: StreamViewDelegate!
    var fetchStatus = 2

    var dataQuery: Query? {
        willSet {

            dataQuery?.cancel()
            isResetting = true
            removeAll()
        }
        didSet {

            currentPage = 0
            fetchData()
        }
    }
    
    var emptyStreamMessage: String = NSLocalizedString("No result", comment:"无结果"){
        didSet {
            if let emptyStreamLabel = emptyStreamLabel {
                emptyStreamLabel.text = emptyStreamMessage
            }
        }
    }
    
    var emptyStreamLabel: UILabel!
    internal var refreshCtrl: UIRefreshControl!

    
    //MARK: - Initializers
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.register(UINib(nibName: loadingCellIdentifier, bundle: nil), forCellReuseIdentifier: loadingCellIdentifier)
    }
    
    init(frame: CGRect) {
        super.init(frame: frame, style: UITableViewStyle.plain)
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }
    
    //MARK: - Methods
    
    func pullRefresh() {
        isResetting = true
        currentPage = 0
        refresh()
    }
    
    func refresh() {
        fetchData()
    }
    
    func cancelQuery() {
        dataQuery?.cancel()
    }
    
    func showEmptyStreamLabel() {
        
        if emptyStreamLabel == nil {
            emptyStreamLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            emptyStreamLabel.text = emptyStreamMessage
            emptyStreamLabel.textColor = Config.Colors.SecondTitleColor
            emptyStreamLabel.textAlignment = NSTextAlignment.center
            emptyStreamLabel.font = UIFont.systemFont(ofSize: 20)
            emptyStreamLabel.sizeToFit()
            backgroundView = emptyStreamLabel
        }
        
        emptyStreamLabel.isHidden = false
    }
    
    func hideEmptyStreamLabel() {
        if let emptyStreamLabel = emptyStreamLabel {
            emptyStreamLabel.isHidden = true
        }
    }
    
    func fetchData() {
        

        guard let dataQuery = dataQuery else {
            return
        }
        self.fetchStatus = 0
        if paging {
            dataQuery.setLimit(0)
            dataQuery.setCurrentPage(0)
            dataQuery.countObjectsInBackgroundWithBlock({ (count, error) -> Void in
                if error == nil && count > 0 {
                    self.totalItems = count
                    dataQuery.setLimit(self.itemsPerPage)
                    dataQuery.setCurrentPage(self.currentPage)

                    dataQuery.executeInBackground({ (objects:[Any]?, error) -> () in
                        if error != nil {
                            log.error(error?.localizedDescription)
                        } else {
                            print(objects?.count)
                            self.handleQueryForObjects(objects as! [AnyObject])
                                self.fetchStatus = 1
                        }
                        if let streamViewDelegate = self.streamViewDelegate , self.streamViewDelegate.responds(to: #selector(StreamViewDelegate.recommendationCount(_:))){
                            streamViewDelegate.recommendationCount!(count)
                        }
                    })
                } else if count == 0 {


                }
            })
        } else {
            dataQuery.executeInBackground({ (objects:[Any]?, error) -> () in
                if error != nil {
                    log.error(error?.localizedDescription)
                } else {
                    self.handleQueryForObjects(objects as! [AnyObject])
                    if let streamViewDelegate = self.streamViewDelegate , self.streamViewDelegate.responds(to: #selector(StreamViewDelegate.recommendationCount(_:))){
                        streamViewDelegate.recommendationCount!((objects?.count)!)
                    }
                }
                
            })
        }
    }
    
    
    //MARK - Virtual methods
    
    func handleQueryForObjects(_ objects: [AnyObject]) {
        fatalError("Method handleQueryForObjects must be overridden")
    }
    
    func removeAll() {
        fatalError("Method removeObjects must be overridden")
    }
    
    
    //MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if paging && cell.tag == loadingCellTag {
            currentPage += 1
            cell.tag = 0
            self.fetchData()
        }
    }
    
}
