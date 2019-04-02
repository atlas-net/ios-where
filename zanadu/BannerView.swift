//
//  BannerView.swift
//  Atlas
//
//  Created by yangying on 15/11/20.
//  Copyright © 2015年 Atlas. All rights reserved.
//
protocol BannerViewTapDelegate{
    //代理方法
    func BannerViewTapWithIndex(_ index:Int)
}
class BannerView: UIView,UIScrollViewDelegate{
    //MARK: - Properties
    var slideShowPageControl = UIPageControl()
    var slideshowView = UIScrollView()
    var bannerObjects = [AnyObject]()
    var bannerTimer = Timer()
    var delegate : BannerViewTapDelegate?
    var isTimerChange = false
    var tapShouldResponse:Bool = true
    //MARK: - method
    func defaultSettings(){
        print(self.frame.size.width)
        self.slideshowView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.frame.size.height)
        self.slideshowView.contentSize = CGSize(width: 0, height: self.slideshowView.frame.size.height)
        self.slideshowView.isPagingEnabled = true
        self.slideshowView.delegate = self
        self.slideshowView.backgroundColor = UIColor.clear
            self.slideshowView.showsHorizontalScrollIndicator = false
        self.slideshowView.showsVerticalScrollIndicator   = false
        self.slideshowView.isUserInteractionEnabled         = true
        self.addSubview(self.slideshowView)
        
        
        //pageControl
        slideShowPageControl.frame = CGRect(x: 45, y: 200, width: 200, height: 20)
        slideShowPageControl.pageIndicatorTintColor = UIColor.white
        slideShowPageControl.currentPageIndicatorTintColor = UIColor(red: 0.93, green: 0.31, blue: 0.49, alpha: 1)
        slideShowPageControl.isUserInteractionEnabled = true
        slideShowPageControl.numberOfPages = 0
        slideShowPageControl.currentPage = 0
        self.addSubview(slideShowPageControl)
        self.slideshowView.bringSubview(toFront: slideShowPageControl)
        
        
        // 手势
        let singleTap = UITapGestureRecognizer(target: self, action:#selector(BannerView.onCoverTapped))
        singleTap.numberOfTapsRequired = 1
        self.addGestureRecognizer(singleTap)
        self.isUserInteractionEnabled = true
        
        
    }
    func setbannerObjects(_ objects:[AnyObject]){
        //self.loadTopTimer()
        self.bannerObjects = objects
        print(self.frame.size.width * CGFloat(objects.count + 2))
        self.slideshowView.contentSize = CGSize(width: self.frame.size.width * CGFloat(objects.count + 2), height: self.slideshowView.frame.size.height)
        self.slideshowView.contentOffset = CGPoint(x: self.frame.size.width, y: 0)
        self.slideShowPageControl.numberOfPages = objects.count
        for i in 0 ... objects.count + 1 {
            var j = 0
            if objects.count < 1 {
                return
            }
            if i == 0 {
                j = objects.count - 1
            } else if i == objects.count + 1 {
                j = 0
            } else {
                j = i - 1
            }
            let ad = objects[j] as! Ad
            //effectCover
            let coverImageV = UIImageView()
            coverImageV.image = UIImage(named:"effectCover398")
            coverImageV.frame = CGRect( x: CGFloat(i) * self.frame.size.width, y: 0, width: self.frame.size.width, height: self.bounds.size.height)
            //imageView
            let imageV = UIImageView()
            imageV.image = UIImage(named:"itemDefaultImage")
            imageV.frame = CGRect( x: CGFloat(i) * self.frame.size.width, y: 0, width: self.frame.size.width, height: self.bounds.size.height)
            imageV.contentMode = UIViewContentMode.scaleAspectFill
            imageV.clipsToBounds = true
            slideshowView.addSubview(imageV)
            slideshowView.addSubview(coverImageV)
            if let adImage = ad.image {
                imageV.image = nil
                adImage.getImageWithBlock(withBlock: { (image, error) -> Void in
                    if error != nil {
//                        log.error(error?.localizedDescription)
                       
                    } else {
                        imageV.image = image
                    }
                })
                
            }
            
            //titleLabel
            if(ad.title != nil){
            let titleLabel = UILabel()
            titleLabel.frame = CGRect(x: 13, y: 130, width: self.frame.size.width - 32, height: 50)
            titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
            titleLabel.textColor = UIColor.white
            titleLabel.text = ad.title
            coverImageV.addSubview(titleLabel)
            }
            
            //desciptionLabel
            if(ad.subtitle != nil){
            let descriptionLabel = UILabel()
            descriptionLabel.frame = CGRect(x: 13, y: 160, width: self.frame.size.width - 32, height: 50)
            descriptionLabel.font = UIFont.systemFont(ofSize: 15)
            descriptionLabel.textColor = UIColor.white
            descriptionLabel.text = ad.subtitle
            coverImageV.addSubview(descriptionLabel)
            }
            
        }

    }
    func bannerAction(_ btn:UIButton){
        
    }
    func bannerTimer(_ timer:Timer){
        var current =  self.slideShowPageControl.currentPage
        current += 1
        if current == self.bannerObjects.count {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.isTimerChange = true
                self.slideshowView.contentOffset = CGPoint(x: CGFloat( 1 + current) * self.bounds.size.width, y: 0)
                }, completion: { (success) -> Void in
                    current = 0
                    self.slideshowView.contentOffset = CGPoint(x: CGFloat( 1 + current) * self.bounds.size.width, y: 0)
                     self.slideShowPageControl.currentPage =  current
                    self.isTimerChange = false
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.slideshowView.contentOffset = CGPoint(x: CGFloat( 1 + current) * self.bounds.size.width, y: 0)
            })
        }
        self.slideShowPageControl.currentPage =  current
        
    }
    func setTimerInvalidate(){
        self.bannerTimer.invalidate()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == slideshowView{
            if self.isTimerChange {return}
            var page = CGFloat(slideshowView.contentOffset.x)
            if page <= 0{
                print(self.bounds.size.width)
                slideshowView.setContentOffset(CGPoint(x: scrollView.contentSize.width - 2 * self.bounds.size.width, y: 0), animated: false)
                slideShowPageControl.currentPage = self.bannerObjects.count - 1
            }else if page >= (slideshowView.contentSize.width - self.bounds.size.width){
                slideshowView.setContentOffset(CGPoint( x: self.bounds.size.width, y: 0), animated: false)
                slideShowPageControl.currentPage = 0
            }else{
                page = (scrollView.contentOffset.x / self.bounds.size.width ) - 1
                slideShowPageControl.currentPage = Int(page)
            }
            
        }
    }
    func loadTopTimer(){
        bannerTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(BannerView.bannerTimer(_:)), userInfo: nil, repeats: true)
        bannerTimer.fire()
    }
    func onCoverTapped(){
        if tapShouldResponse{
            tapShouldResponse = false
        if delegate != nil{
            self.delegate?.BannerViewTapWithIndex(self.slideShowPageControl.currentPage)
          
        }
        }
    }
}
