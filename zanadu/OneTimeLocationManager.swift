//
//  OneTimeLocationManager.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 5/10/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import UIKit
import CoreLocation

/**
OneTimeLocation errors

- AuthorizationDenied:        The user have refused the app to use location
- AuthorizationNotDetermined: The user haven't yet authorized the app to use location
- InvalidLocation:            Got an invalid location from server
*/
enum OneTimeLocationManagerErrors: Int {
    case authorizationDenied
    case authorizationNotDetermined
    case invalidLocation
}

/**
*  Get the current device location once and then invoke the completion closure
*/
class OneTimeLocationManager: NSObject, CLLocationManagerDelegate {
    
    
    //MARK: - Properties

    fileprivate var locationManager: CLLocationManager?
    typealias LocationClosure = ((_ location: CLLocation?, _ error: NSError?)->())
    fileprivate var didComplete: LocationClosure?
    
    
    //MARK: - Init/Deinit
    
    deinit {
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    //MARK - Methods
    
    /**
    Initialize the LocationManager, the completion closure, and ask for location permissions
    
    - parameter completion: The closure invoked once a location is fetched
    */
    func fetchWithCompletion(_ completion: @escaping LocationClosure) {
        //store the completion closure
        didComplete = completion
        
        //fire the location manager
        locationManager = CLLocationManager()
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.delegate = self
        
        //check for description key and ask permissions
        if (Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil) {
            locationManager!.requestWhenInUseAuthorization()
        } else if (Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysUsageDescription") != nil) {
            locationManager!.requestAlwaysAuthorization()
        } else {
            fatalError("To use location in iOS8 you need to define either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription in the app bundle's Info.plist file")
        }
        
    }
    
    //location manager returned, call didcomplete closure
    fileprivate func _didComplete(_ location: CLLocation?, error: NSError?) {
        locationManager?.stopUpdatingLocation()
        didComplete?(location, error)
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    
    //MARK: - CLLocationManager Delegate
    
    //location authorization status changed
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            self.locationManager!.startUpdatingLocation()
        case .denied:
            _didComplete(nil, error: NSError(domain: self.classForCoder.description(),
                code: OneTimeLocationManagerErrors.authorizationDenied.rawValue,
                userInfo: nil))
        default:
            break
        }
    }
    
    internal func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        _didComplete(nil, error: error as NSError?)
    }
    
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        _didComplete(location, error: nil)
    }
}
