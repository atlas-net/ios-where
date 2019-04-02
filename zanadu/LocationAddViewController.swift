//
//  LocationAddController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 4/13/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import Alamofire
import CoreLocation
public protocol LocationAddViewControllerDelegate {
    func locationAddViewControllerDidAddVenue(_ tmpVenue: AnyObject)
}
class LocationAddViewController : BaseViewController,CLLocationManagerDelegate {

    
    // MARK: - Properties
    
    var mapChangedFromUserInteraction = false

    var locationManager = CLLocationManager()
    var delegate: LocationAddViewControllerDelegate?
    var locationVenues: [Venue] = []
    var foursquareRequest : Request?
    var currentSelectVenue : Venue?
    var currentLocation : CLLocation?
    var photoLocation :CLLocation?
    // MARK: - Outlets


    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pinView: UIImageView!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    
    @IBOutlet weak var validateButton: UIButton!
    
    
    // MARK: - Actions

    @IBAction func onValidateButtonClicked(_ sender: UIButton) {
        //TODO: validate data
        
        if currentSelectVenue != nil {
            currentSelectVenue!.customName = titleField.text
            currentSelectVenue!.customAddress = addressField.text
            
            
            currentSelectVenue?.saveInBackground({ (succeed, error) -> Void in
                if error != nil {
                    print("Venue save error : \(error)", terminator: "")
                } else {
                    print("Venue saved", terminator: "")
                    RecommendationFactory.sharedInstance.venue = self.currentSelectVenue
                    RecommendationFactory.sharedInstance.usingSavedVenue = true
                    self.delegate?.locationAddViewControllerDidAddVenue(self.currentSelectVenue!)
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
        else{
            if let titleText = titleField.text , let addressText = addressField.text , currentLocation != nil{
                if !titleText.isEmpty && !addressText.isEmpty{
                    self.validateButton.isEnabled = true
                    let venue = Venue(name: titleText, address: addressText, location: currentLocation!)
                    venue.saveInBackground({ (succeed, error) -> Void in
                        if error != nil {
                            print("Venue save error : \(error)", terminator: "")
                        } else {
                            print("Venue saved", terminator: "")
                            RecommendationFactory.sharedInstance.venue = venue
                            RecommendationFactory.sharedInstance.usingSavedVenue = true
                            self.delegate?.locationAddViewControllerDidAddVenue(venue)
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }
            }
        }
    }
    
    //MARK: - ViewController's Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.validateButton.isEnabled = false
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
        view.addGestureRecognizer(tap)
        locationManager.distanceFilter = 5.0
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.delegate = self
        if(CLLocationManager.locationServicesEnabled()) {
            locationManager.requestWhenInUseAuthorization()
        }
        mapView.mapType = MKMapType.standard
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        mapView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        if let photoLocation = self.photoLocation{
            let currentRegion = MKCoordinateRegionMakeWithDistance(photoLocation.coordinate, 2000, 2000)
            self.mapView.setRegion(currentRegion, animated: true)
            updateCurrentLocationAndAddress(photoLocation)
        }else{
            locationManager.startUpdatingLocation()
        }

    }
    
    //MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let _ = currentSelectVenue else{
            self.validateButton.isEnabled = false
            return true
        }
        currentSelectVenue!.customName = titleField.text
        self.view.endEditing(true)
        self.validateButton.isEnabled = true
        return true
    }
    
    
    //MARK: - locationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentRegion = MKCoordinateRegionMakeWithDistance(locations.last!.coordinate, 2000, 2000)
        self.mapView.setRegion(currentRegion, animated: true)
        updateCurrentLocationAndAddress(locations.last!)
        locationManager.stopUpdatingLocation()
    }
}

extension LocationAddViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        locationManager.stopUpdatingLocation()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if currentSelectVenue == nil {
            if let titleText = titleField.text , let addressText = addressField.text {
                if !titleText.isEmpty && !addressText.isEmpty{
                    self.validateButton.isEnabled = true
                }
            }
        }
    }
}
