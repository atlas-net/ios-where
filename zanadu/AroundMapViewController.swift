//
//  AroundMapViewController.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 7/29/15.
//  Copyright (c) 2015 Atlas. All rights reserved.
//

import MapKit


/**
AroundMapViewController

Display recommendations around
*/
class AroundMapViewController : BaseViewController {
    
    //MARK: - Properties
    
    let initialBoxWidth: Double = 100
    let calloutTag = 42
    
    var regionDefined = false
    var venues = [Venue]()
    
    var currentRadius = Double.infinity
    
    //MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempRangeLabel: UILabel!
    @IBOutlet weak var pm25IndexLabel: UILabel!
    @IBOutlet weak var pm25ValueLabel: UILabel!
    
    //MARK: - Initializers
    
    //MARK: - Actions
    
    //MARK: - Methods
    
    func reloadVenueListForLocation(_ location: CLLocation) {
        currentRadius = mapView.widthInMeters() * 0.4

        DataQueryProvider.venuesAround(location, withinRadius: Int(currentRadius)).executeInBackground({ (objects:[Any]?, error) -> () in
            if error != nil {
                log.error("Venue fetching error: \(error!.localizedDescription)")
            } else {
                self.venues = objects as! [Venue]
                
                self.removeOutOfRadiusAnnotations()
                self.addAnnotationsForCurrentVenues()
            }
        })
    }

    func addAnnotationsForCurrentVenues() {
        for venue in venues {
            if containsAnnotationForVenue(venue) {
                continue
            }
            
            let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(venue.coordinate!.latitude), CLLocationDegrees(venue.coordinate!.longitude))
            let title = venue.customName
            let subtitle = venue.customAddress
            let annotation = VenueAnnotation(venue: venue, coordinate: coordinate, title: title!, subtitle: subtitle!)
            mapView.addAnnotation(annotation)
        }
    }

    func removeOutOfRadiusAnnotations() {
        var toRemove = [VenueAnnotation]()


        
        for annotation in mapView.annotations {
            if let venueAnnotation = annotation as?VenueAnnotation {
            if isAnnotationOutOfRadius(venueAnnotation) {
                toRemove.append(venueAnnotation)
                }
            }
        }

        mapView.removeAnnotations(toRemove)
    }
    
    func containsAnnotationForVenue(_ venue: Venue) -> Bool {
        for annotation in mapView.annotations {
            if annotation.title! == venue.customName {
                return true
            }
        }
        return false
    }
    
    func isAnnotationOutOfRadius(_ annotation: VenueAnnotation) -> Bool {
        let mapCenter = AVGeoPoint(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        

        
        if annotation.venue.coordinate!.distanceInKilometers(to: mapCenter) > currentRadius / 1000 {
            return true
        }
        return false
    }
    
    
//    func calloutViewForAnnotationView(view: VenueAnnotationView) -> UIView {
//        
//        let calloutHeight: CGFloat = 100
//        let calloutWidth: CGFloat = 260
//        
//        var calloutView = UIView(frame: CGRect(x: -calloutWidth / 2, y: -calloutHeight, width: calloutWidth, height: calloutHeight))
//
//        calloutView.backgroundColor = Config.Colors.TagViewBackground
//        calloutView.tag = calloutTag
//
//        
//   //     var titleLabel = UILabel(frame: )
//        
//        
//        return calloutView
//    }
    
    
    //MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        WeatherService.weatherDataForCorrentLocation { (data, error) -> () in
            if let data = data {
//                if let city = data.city {
                self.navigationItem.title = data.city
                self.currentTempLabel.text = data.currentTemperature
                self.weatherImageView.image = data.weatherIcon
//                }
                
//                if let date = data.date {
                self.dateLabel.text = data.date
                self.tempRangeLabel.text = data.temperatureRange
                
                self.pm25IndexLabel.text = "空气质量: " + data.pm25Index
                self.pm25ValueLabel.text = "PM2.5: " + data.pm25Value
//                } else {
//                    self.dateLabel.text = "_/_/_"
//                }
                
//                if let currentTemperature = data.currentTemperature {
//                } else {
//                    self.dateLabel.text = "_°"
//                }

            }
        }
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

extension AroundMapViewController {
    func updateMapWithUserLocation(_ location: CLLocation) {
        if !regionDefined {
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(location.coordinate, initialBoxWidth, initialBoxWidth), animated: true)
            regionDefined = true

            reloadVenueListForLocation(location)
        }
    }
}

extension AroundMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let location = userLocation.location {
            updateMapWithUserLocation(location)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {

    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        reloadVenueListForLocation(CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude))
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        let annotationView = VenueAnnotationView(annotation: annotation, reuseIdentifier: "Attraction")

        annotationView.canShowCallout = true
    
        annotationView.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        if let view = view as? VenueAnnotationView {
//            view.addSubview(calloutViewForAnnotationView(view))
//        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let view = view as? VenueAnnotationView {
            if let annotation = view.annotation as? VenueAnnotation {
                Router.redirectToVenue(annotation.venue, fromViewController: self)
            }
        }
    }
}
