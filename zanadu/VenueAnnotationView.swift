//
//  VenueAnnotationView.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/29/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import MapKit

/**
VenueAnnotationView

*/
class VenueAnnotationView: MKAnnotationView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        image = UIImage(named: "coordinate_pink")
    }

//    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
//        var hitView = super.hitTest(point, withEvent:event)
//        if hitView != nil {
//            self.superview!.bringSubviewToFront(self)
//        }
//        return hitView
//    }
//    
//    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
//        var isInside = CGRectContainsPoint(self.bounds, point)
//        if(!isInside)
//        {
//            for view in self.subviews
//            {
//                isInside = CGRectContainsPoint(view.frame, point)
//                if isInside {
//                    break
//                }
//            }
//        }
//        return isInside;
//    }
}
