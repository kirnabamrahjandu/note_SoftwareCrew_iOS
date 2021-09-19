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
    var locationManager = CLLocationManager()
    var latitude:Double?
    var longitude:Double?
    let regionRadius:CLLocationDistance = 300
    let locationMAnager = CLLocationManager()
    var userLocation:CLLocation!
    @IBOutlet weak var myMapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        myMapView.showsUserLocation = true
        
    }
    //MARK :- Location manager Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        longitude = (Double(userLocation.coordinate.longitude) * 10000000).rounded() / 10000000
        latitude = (Double(userLocation.coordinate.latitude) * 10000000).rounded() / 10000000
        UserDefaults.standard.set(latitude, forKey: "userLat")
        UserDefaults.standard.set(longitude, forKey: "userLong")
        locationManager.stopUpdatingLocation()
        print(latitude!)
        print(longitude!)
    }
}
