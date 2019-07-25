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
    let queue = DispatchQueue(label: "com.girish.ankiassistant")
    // cannot read toggleSwitch.isOn from async thread, without causing thread backtrace
    // and error in nslog, although after 15 seconds everything will start running fine again.
    // But if you use dispatchque of main loop to read toggleSwitch, OS gives control back to
    // main thread and background task stops.
    // To avoid this, use a local variable and connect it to toggleSwitch state
    var stopBackgroundTask = true
    
    //MARK: Properties
   
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK: Actions
    
    @IBAction func switchValueChanged(_ sender: UISwitch, forEvent event: UIEvent) {
        if sender.isOn {
            configureLocationManager()
            startReceivingLocationChanges()
            stopBackgroundTask = false
            //toggleSwitch.setOn(false, animated: true)
            //toggleSwitch
        } //else { // switch is OFF
          //  locationManager?.stopUpdatingLocation()
          //  stopBackgroundTask = true
        //}
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        statusLabel.text = "Anki Assistant"
    }
    
    // girish
    
    func configureLocationManager() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager?.distanceFilter = 100000000.0  // In meters.
            locationManager?.delegate = self
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.requestAlwaysAuthorization()
        }
    }
    
    // to fake background task, use location manager in a async thread
    func startReceivingLocationChanges() {

        // Configure and start the service.
        
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
        queue.async {
            let MaxDuration = 12 * 60 * 60 // 12 hours in seconds
            for _ in 0..<MaxDuration {
                if !self.stopBackgroundTask {
                    NSLog("event")
                    sleep(1)
                    NSLog("after")
                    // stopping and starting updatenotification does not deliver events
                    // when app is in background. So, use for loop with sleep
                    //manager.stopUpdatingLocation()
                    //manager.startUpdatingLocation()
                } else {
                    manager.stopUpdatingLocation()
                    return
                }
            }
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

// girish
// UIApplication is a singleton
//                if UIApplication.shared.applicationState == .active {
//                    NSLog("active")
//                } else if UIApplication.shared.applicationState == .inactive {
//                    NSLog("inactive")
//                } else if UIApplication.shared.applicationState == .background {
//                    NSLog("background")
//                } else {
//                    NSLog("unknown")
//
// state does not change from 'active' when you background the task
//   if it is blocked in a sleep loop.

//
// cannot read toggleSwitch.isOn from async thread, without causing thread backtrace
// and error in nslog, although after 15 seconds everything will start running fine again.
// But if you use dispatchque of main loop to read toggleSwitch, OS gives control back to
// main thread and background task stops.
// To avoid this, use a local variable and connect it to toggleSwitch state
//                var toggleSwitchIsOn = false
//                DispatchQueue.main.async {
//                    //Do UI Code here.
//                    toggleSwitchIsOn = self.toggleSwitch.isOn
//                }
// above causes OS to give control back to main thread and background task stops
//
// asych queues don't work when app is backgrounded
//
