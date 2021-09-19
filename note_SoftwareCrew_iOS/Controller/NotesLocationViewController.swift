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
    @IBOutlet weak var myMapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        myMapView.showsUserLocation = true
        
    }
}
