//
//  ImageCropView.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/30/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

/**
ImageCropView allow you to easily display and crop images

1. Just put an UIScrollView at the size you want using Storyboard
2. In ViewDidLoad function use ImageCropView's setup() function to init the component
3. After the UI is rendered you can call the display() function
4. Let the user zoom & move the image as they want
5. Get the cropped image by using ImageCropView's croppedImage() function
5. Get the cropped image by using ImageCropView's croppedImage() function
6. Tap events can be handled using ImageCropViewTapProtocol
7. You can use this component to display a read only cropped image too

    imageCropView.setup(myImage)
    ...
    imageCropView.display()
    ...
    let croppedImage = imageCropView.croppedImage()
    // or
    let cropRect = imageCropView.cropRect()
    ...
    imageCropView.setCrop(rect)
*/

public typealias ImageSetterBlock = (_ setImage: @escaping (_ image:UIImage)->())->()

@IBDesignable
open class ImageCropView: UIScrollView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    //MARK: - IBInspectable Properties
    
    @IBInspectable var minScale: CGFloat = 0.8
    
    
    //MARK: - Private Properties

    fileprivate var tapDelegate: ImageCropViewTapProtocol?
    fileprivate var image: UIImage? = UIImage() {
        didSet {
            if image != nil {
                if image!.size.width > 0 && image!.size.height > 0 {
                    setup(self.image!)
                }
            }
 
        }
    }
    
    //MARK: - Public Properties

    open var coverImageView: UIImageView!
    open var editable = true {
        didSet {
            if editable {
                enableEditing()
            } else {
                disableEditing()
            }
        }
    }

    
    //MARK: - Initializers

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    //MARK: - Methods
    
    func setImage(_ image:UIImage) {
        self.image = image
    }
    
    func getImage() -> UIImage? {
        return self.image
    }
    
    /**
    Setup the view with a given image

    - parameter image: Will be displayed in the view
    */
    open func setup(_ image: UIImage, tapDelegate: ImageCropViewTapProtocol? = nil) {
        print(frame)
         self.frame.size.width = UIScreen.main.applicationFrame.size.width
         self.frame.size.height = UIScreen.main.applicationFrame.size.width
        if let coverImageView = coverImageView {
            coverImageView.removeFromSuperview()
        }
        
        coverImageView = UIImageView(image: image)
        coverImageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size:image.size)
        
        addSubview(coverImageView)
        contentSize = image.size
        
        self.delegate = self
        self.tapDelegate = tapDelegate
    }
    
    open func setup(_ url: String, tapDelegate: ImageCropViewTapProtocol? = nil, imageSetCompleteBlock:@escaping ()->Void) {
        
        self.frame.size.width = UIScreen.main.applicationFrame.size.width
        self.frame.size.height = UIScreen.main.applicationFrame.size.width
        if let coverImageView = coverImageView {
            coverImageView.removeFromSuperview()
        }
        
        coverImageView = UIImageView()
       
        coverImageView.sd_setImage( with: URL(string:url)) { (image, error, cacheType, requestUrl) in
            if error != nil{
                print(error)
                return
            }
            self.coverImageView.image = image
            self.coverImageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size:(image?.size)!)
            
            self.addSubview(self.coverImageView)
            self.contentSize = (image?.size)!
            
            self.delegate = self
            self.tapDelegate = tapDelegate
            imageSetCompleteBlock()
        }
    }
    
    open func setup(_ imageSetter: ImageSetterBlock, placeholder: UIImage, tapDelegate: ImageCropViewTapProtocol? = nil) {
        self.frame.size.width = UIScreen.main.applicationFrame.size.width
        self.frame.size.height = UIScreen.main.applicationFrame.size.width
        print(frame)
        setup(placeholder)
        imageSetter(setImage)
        self.tapDelegate = tapDelegate
    }

    
    open func display() {
        if let image = coverImageView.image {
            contentSize = image.size
        }
        
        let scrollViewFrame = frame
        let scaleWidth = scrollViewFrame.size.width / contentSize.width
        let scaleHeight = scrollViewFrame.size.height / contentSize.height
        let tmpMinScale = max(scaleWidth, scaleHeight)
        
        minimumZoomScale = tmpMinScale
        maximumZoomScale = (tmpMinScale > minScale) ? tmpMinScale : minScale

        zoomScale = tmpMinScale
        
        contentOffset.x = (contentSize.width - bounds.width) / 2
        contentOffset.y = (contentSize.height - bounds.height) / 2
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let tapDelegate = tapDelegate {
            tapDelegate.onImageCropViewTapped(self)
        }
    }
    
    
    open func enableEditing() {
        isScrollEnabled = true
        pinchGestureRecognizer?.isEnabled = true
    }
    
    
    open func disableEditing() {
        isScrollEnabled = false
        pinchGestureRecognizer?.isEnabled = false
    }
    

    /**
    Crop the image using the ImageCropView bounds and scale factor

    - returns: the cropped image
    */
    open func croppedImage() -> UIImage? {
        let tmp = coverImageView.image?.cgImage?.cropping(to: cropRect())
        let img = UIImage(cgImage: tmp!, scale: coverImageView.image!.scale, orientation: coverImageView.image!.imageOrientation)
        
        return img
    }

    /**
    Returns the Crop Rect of the image
    
    The cropRect will be used to display the image with the right scale and offset.
    It is calculated using the ImageCropView bounds and scale factor.
    
    - returns: the cropRect
    */
    open func cropRect() -> CGRect {
        var scale:CGFloat = 0
        if let _ = coverImageView.image ,coverImageView.image!.size.width <= coverImageView.image!.size.height{
            scale = (coverImageView.frame.size.width) / frame.width
        }else{
            scale = (coverImageView.frame.size.height) / frame.height
        }
        let cropRect = CGRect(x: zoomScale, y: frame.width , width: contentOffset.x, height: contentOffset.y)
        print(cropRect)
        return cropRect
    }

    
    
    /**
    Apply crop parameters on the image
    
    - parameter rect: The crop Rect
    */
    open func setCrop(_ rect: CGRect) {
        
        if let image = coverImageView.image {
            contentSize = image.size
        }
        
        let scrollViewFrame = frame
        let scaleWidth = scrollViewFrame.size.width / contentSize.width
        let scaleHeight = scrollViewFrame.size.height / contentSize.height
        let tmpMinScale = max(scaleWidth, scaleHeight)
        
        minimumZoomScale = tmpMinScale
        maximumZoomScale = (tmpMinScale > minScale) ? tmpMinScale : minScale
        print("minZoom", minimumZoomScale, "maxZoom", maximumZoomScale)
        
        zoomScale = rect.origin.x * ( frame.width / rect.origin.y )
        contentOffset.x = rect.width * ( frame.width / rect.origin.y )
        contentOffset.y = rect.height * ( frame.width / rect.origin.y )

    }
    
    //MARK: - UIScrollViewDelegate
    
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return coverImageView
    }
}
