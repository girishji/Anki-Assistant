//
//  ViewController.swift
//  Anki Assistant
//
//  Created by gpalya on 7/24/19.
//  Copyright © 2019 gpalya. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    
    //MARK: Properties
    
    
    
    //MARK: Actions
    
    @IBAction func switchValueChanged(_ sender: UISwitch, forEvent event: UIEvent) {
        if sender.isOn {
            NSLog("on")
            //startReceivingVisitChanges()
            startReceivingLocationChanges()
        } else {
            NSLog("off")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    
    // girish
    
    func startReceivingLocationChanges() {

        // Configure and start the service.
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0  // In meters.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()

        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            NSLog("girish: user not authorized")
            // XXX: to make settings->privacy->(anki helper) appear
            locationManager.startUpdatingLocation()
            return
        }
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            // Location services is not available.
            NSLog("girish: location not enabled")
            return
        }
        locationManager.startUpdatingLocation()
        NSLog("requested loc")
    }

    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        //let lastLocation = locations.last!
        NSLog("event")
        sleep(1)
        NSLog("after")
        // Do something with the location.
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("failed with error")
        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorized.
            manager.stopUpdatingLocation()
            return
        }
        // Notify the user of any errors.
    }
}

