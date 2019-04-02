//
//  MKMapView+MeterWidth.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/29/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import MapKit

extension MKMapView {
    func widthInMeters() -> CLLocationDistance {
        let mRect: MKMapRect = visibleMapRect
        let eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect))
        let westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect))
        let currentDistWideInMeters = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint)
        return currentDistWideInMeters
    }
}
