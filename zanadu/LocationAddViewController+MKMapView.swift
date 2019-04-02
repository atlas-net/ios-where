//
//  LocationAddViewController+MKMapViewDelegate.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/15/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import MapKit
import UIKit
import Alamofire

extension LocationAddViewController : MKMapViewDelegate {
    
    
    //Mark: - MKMapView Delegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is LocationAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation as! LocationAnnotation
        
        anView!.image = UIImage(named:cpa.imageName)
        anView!.centerOffset = CGPoint(x: 6, y: -26)
        return anView
    }

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
        if mapChangedFromUserInteraction {
            
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if mapChangedFromUserInteraction {
            updateCurrentLocationAndAddress(CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude))
        }
    }
    
    //MARKS: - Methods
    
    func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews.first
        for recognizer in view!.gestureRecognizers! {
            if recognizer.state == UIGestureRecognizerState.began || recognizer.state == UIGestureRecognizerState.ended {
                return true
            }
        }
        return false
    }
    
    func updateCurrentLocationAndAddress(_ location: CLLocation) {
        let geoCoder = CLGeocoder()
        self.locationVenues.removeAll()
        currentSelectVenue = nil
        currentLocation = location
        updateVenus(false)
        foursquareRequest?.cancel()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if error != nil{
                self.parseCLLocationToVenueBy4SQ(location)
                return
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let placeArray = placemarks {
                placeArray.forEach({ (placeMark) in
                    // Formated Address
                    if placeMark.addressDictionary!["FormattedAddressLines"] != nil {
                        let tmpVenue = Venue()
                        tmpVenue.updateWithPlacemark(placeMark)
                        self.locationVenues.append(tmpVenue)
                    }
                })
            }
            
            self.updateVenus(true)
            
        })
        
            }
    
    func parseCLLocationToVenueBy4SQ(_ location: CLLocation) {
        let lati = location.coordinate.latitude
        let longi = location.coordinate.longitude
        let baseRquestUrlStr = "https://api.foursquare.com/v2/venues/search?client_id=41S3Z535ROMBR4IBDAPHFX5CKZ0AQAVL4VDANCYJRYHVDKKZ&client_secret=LG200JKI5J5SHVZDUFSGZ2F5H1FODQEHCXCPPVCRIK4D5BBS&v=20160728&ll=%@,%@"
        let requestUrlStr = String(format: baseRquestUrlStr, lati.description, longi.description)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Alamofire.request(requestUrlStr, headers : ["Accept-Language":"en;q=0.8,zh-CN,zh;q=0.6"]).validate().responseJSON { (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if response.result.error != nil{
                self.updateVenus(true)
                return
            }
            guard let result = response.result.value as? NSDictionary , result["response"] != nil else{
                self.updateVenus(true)
                return
            }
            guard let venues = ((result as AnyObject)["response"] as? NSDictionary)?["venues"] as? NSArray , venues.count > 0 else{
                self.updateVenus(true)
                return
            }
            venues.forEach({ (venueData) in
                guard let venueDataDict = venueData as? NSDictionary else{
                    return
                }
                let venue = FoursquareVenueSearchData(foursquareVenue: venueDataDict, score: 0).toVenue()
                self.locationVenues.append(venue)
            })
            self.updateVenus()
        }
    }
    
    func updateVenus(_ isEndLocate: Bool = true)  {

        if(self.locationVenues.count > 0){
            self.currentSelectVenue = self.locationVenues[0]
            self.validateButton.isEnabled = true
            self.titleField.text = self.currentSelectVenue?.placeName
            self.addressField.text = self.currentSelectVenue?.fullAddress

            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                self.pinView.frame = CGRect(x: self.pinView.frame.origin.x, y: self.pinView.frame.origin.y - 16, width: self.pinView.frame.width, height: self.pinView.frame.height)
            }, completion: { (finished) -> Void in
                if finished {

                    UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 5.5, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                        self.pinView.frame = CGRect(x: self.pinView.frame.origin.x, y: self.pinView.frame.origin.y + 16, width: self.pinView.frame.width, height: self.pinView.frame.height)
                    }, completion: { (finished) -> Void in

                    })
                }


            })
        }


        if isEndLocate{
            endLocate()
        }else{
            beginLocating()
        }
    }
    
    func beginLocating()  {
        if self.currentSelectVenue == nil{
            self.validateButton.isEnabled = false
            self.addressField.text = ""
                        self.addressField.isEnabled = false
            self.addressField.placeholder = "定位中..."
            self.titleField.text = ""
            self.titleField.isEnabled = false
            self.titleField.placeholder = "定位中..."
        }
    }
    
    func endLocate()  {
         self.addressField.isEnabled = true
        self.titleField.isEnabled = true
        if self.currentSelectVenue == nil{
            self.validateButton.isEnabled = false
            self.addressField.text = ""
            self.addressField.placeholder = "请输入名称"
            self.titleField.text = ""
            self.titleField.placeholder = "请输入地址"
        }
    }
}
