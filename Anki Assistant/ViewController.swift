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
    let DefaultLabel = "Anki Assistant"
    var backgroundTaskID: UIBackgroundTaskIdentifier?
    
    //MARK: Properties
   
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK: Actions
    
    @IBAction func switchValueChanged(_ sender: UISwitch, forEvent event: UIEvent) {
        if sender.isOn {
             //toggleSwitch.setOn(false, animated: true)
            toggleSwitch.isEnabled = false
            // when main thread gets occupied in sleep loop, UI will not respond. Just
            // wait for 3 hours loop to expire.
            configureLocationManager()
            startReceivingLocationChanges()
        } //else { // switch is OFF
          //  locationManager?.stopUpdatingLocation()
         //}
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        statusLabel.text = DefaultLabel
        toggleSwitch.isEnabled = true
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
        manager.stopUpdatingLocation()
        
        // Perform the task on a background queue.
        DispatchQueue.global().async {
            // Request the task assertion and save the ID.
            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask (withName: "Finish Network Tasks") {
                // End the task if time expires.
                UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
                self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
            }
            
            // Send the data synchronously.
            //self.sendAppDataToServer( data: data)
            let MaxDuration = 3 * 60 * 60 // in seconds
            for _ in 0..<MaxDuration {
                //if toggleSwitch.isOn {
                NSLog("event")
                PasteboardHelper.transform()
                sleep(1)
                
                //NSLog("after")
                // does not update UI because this app is single threaded and
                //   it is occupied
                //let remaining = MaxDuration - tick
                //let minutes = remaining / 60
                //let seconds = remaining % 60
                //let hours = remaining % 3600
                //statusLabel.text = "\(hours) : \(minutes) : \(seconds) remaining"
            }
            self.toggleSwitch.isEnabled = true
            //statusLabel.text = DefaultLabel
            
            // End the task assertion.
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
            self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("failed with error")
        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorized.
            manager.stopUpdatingLocation()
            return
        }
    }
    
    // girish
    // make the font of top status bar white
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


//
// girish
//
// Busy loop with sleep() does not work. Even when you call PasteboardHelper.transform
// it is like that never gets called. It prints 0 contents in pastboard (when you
// copy some text) but after you reinstall app the pasteboard content is there!
// you can even formate when called outside of busy loop.
//
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
// even navigation option in desiredAccuracy does not work
//
// stopping and starting updatenotification to make it deliver another event
//
