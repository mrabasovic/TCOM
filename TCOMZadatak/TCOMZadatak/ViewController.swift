//
//  ViewController.swift
//  TCOMZadatak
//
//  Created by Danica Rabasovic on 7.2.23..
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate {

    @IBOutlet private weak var myMap: MKMapView!
    @IBOutlet private weak var addressTextField: UITextField!
    @IBOutlet private weak var directionsButton: UIButton!
    
    let locationManager = CLLocationManager()
    var myGeoCoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
        }
        
        addressTextField.delegate = self
        myMap.delegate = self
        
        directionsButton.layer.cornerRadius = 10
        addressTextField.layer.shadowOpacity = 1
        addressTextField.layer.shadowRadius = 3.0
        addressTextField.layer.shadowOffset = CGSize.zero // Use any CGSize
        addressTextField.layer.shadowColor = UIColor.gray.cgColor
    }

    @IBAction func directionsTapped(_ sender: UIButton) {
        myGeoCoder.geocodeAddressString(addressTextField.text ?? "") { (placemark, error) in
            self.processResponse(withPlacemarks: placemark, error: error)
            self.addressTextField.endEditing(true)
        }
    }
    
    func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            print("Error fetching coordinates \(error)")
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let coordinate = location.coordinate
                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0), addressDictionary: nil))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude), addressDictionary: nil))
                request.transportType = .any
                //request.requestsAlternateRoutes = true
                
                let directions = MKDirections(request: request)
                directions.calculate { response, error in
                    guard let directionsResponse = response else { return }
                    for route in directionsResponse.routes {
                        self.myMap.addOverlay(route.polyline)
                        self.myMap.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        renderer.lineWidth = 4.0
        renderer.alpha = 1.0
        return renderer
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.first {
            manager.stopUpdatingLocation()
            let coordinates = CLLocationCoordinate2D(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: coordinates, span: span)
            myMap.setRegion(region, animated: true)
            let myPin = MKPointAnnotation()
            myPin.coordinate = coordinates
            myPin.title = "You are here"    // ili to stavi kao subtitle
            myMap.addAnnotation(myPin)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            return
        case .authorizedWhenInUse:
            return
        case .denied:
            return
        case .restricted:
            locationManager.requestWhenInUseAuthorization()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

