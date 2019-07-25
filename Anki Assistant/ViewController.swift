//
//  ViewController.swift
//  Anki Assistant
//
//  Created by gpalya on 7/24/19.
//  Copyright © 2019 gpalya. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    var locationManager: CLLocationManager?
    var timerStopped = true
    
    //MARK: Properties
   
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK: Actions
    
    @IBAction func switchValueChanged(_ sender: UISwitch, forEvent event: UIEvent) {
        if sender.isOn {
            timerStopped = false
            if locationManager == nil {
                locationManager = CLLocationManager()
                startReceivingLocationChanges()
            } else {
                locationManager?.startUpdatingLocation()
            }
        } else { // switch is OFF
            timerStopped = true
            locationManager?.stopUpdatingLocation()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        statusLabel.text = "Anki Assistant"
    }
    
    
    // girish
    // to fake background task, use location manager
    func startReceivingLocationChanges() {

        // Configure and start the service.
        locationManager!.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager!.distanceFilter = 100000000.0  // In meters.
        locationManager!.delegate = self
        locationManager!.requestWhenInUseAuthorization()
        locationManager!.requestAlwaysAuthorization()

        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            // User has not authorized access to location information.
            NSLog("girish: user not authorized")
            return
        }
        // Do not start services that aren't available.
        if !CLLocationManager.locationServicesEnabled() {
            // Location services is not available.
            NSLog("girish: location not enabled")
            return
        }
        locationManager!.startUpdatingLocation()
    }
}

// girish
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        //let lastLocation = locations.last!
        //let MaxDuration = 24 * 60 * 60 // one day in seconds
        //for _ in 0..<MaxDuration {
        if !timerStopped {
            NSLog("event")
            sleep(1)
            NSLog("after")
            // stopping and starting is better than a loop with a sleep as it will give
            // this thread time to process switch on/off events from UI
            manager.stopUpdatingLocation()
            manager.startUpdatingLocation()
        } else {
            manager.stopUpdatingLocation()
        }
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
    
    // girish
    // make the font of top status bar white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
