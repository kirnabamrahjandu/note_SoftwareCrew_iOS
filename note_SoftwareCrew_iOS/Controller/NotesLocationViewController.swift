//
//  AppDelegate.swift
//  note_SoftwareCrew_iOS
//
//  Created by Kirna on 13/09/21.
//


import UIKit
import MapKit
import  CoreLocation
import CoreData

class NoteLocationViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {
    var locationManager:CLLocationManager? = CLLocationManager()
    var userLocation:CLLocation!
    var userLat = Double()
    var userLong = Double()
    @IBOutlet weak var myMapView: MKMapView!
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager!.requestWhenInUseAuthorization()
        locationManager!.startUpdatingLocation()
        myMapView.showsUserLocation = true
        self.setLocationAccuracy()
    }
    //MARK:- Set location accuracy
    func setLocationAccuracy(){
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.distanceFilter = kCLDistanceFilterNone
        locationManager!.requestAlwaysAuthorization()
        locationManager!.pausesLocationUpdatesAutomatically = false
        locationManager!.delegate = self
    }
    //MARK :- Core Location manager Delegate
    
    //MARK:- Location manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        userLong = (Double(userLocation.coordinate.longitude) * 10000000).rounded() / 10000000
        userLat = (Double(userLocation.coordinate.latitude) * 10000000).rounded() / 10000000
        UserDefaults.standard.set(userLat, forKey: "userLat")
        UserDefaults.standard.set(userLong, forKey: "userLong")
        print("Updated lat is ",userLat)
        print("Updated lng is ",userLong)
       // myMapView.showsUserLocation = true
        //locationManager!.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkForAllowLocation()
    }
    func checkForAllowLocation(){
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestAlwaysAuthorization()
        }
        else if CLLocationManager.authorizationStatus() == .denied {
            print("denied")
           
        }
        else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager?.requestAlwaysAuthorization()
           // print("authorizedWhenInUse")
            if(userLat == 0.0){
                self.locationManager!.startUpdatingLocation()
            }
        }
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
           // print("authorizedAlways")
            if(userLat == 0.0){
                self.locationManager!.startUpdatingLocation()
            }
        }
    }
}
