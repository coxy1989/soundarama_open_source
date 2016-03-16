//
//  Compass.swift
//  Soundarama
//
//  Created by Jamie Cox on 16/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import CoreLocation

class LocationService {
    
    static let manager = CLLocationManager()
}

class Compass: NSObject {
    
    let locationManager: CLLocationManager
    
    var handler: ((heading: Double) -> ())!
    
    init(locationManager: CLLocationManager) {
        
        self.locationManager = locationManager
    }
    
    func start(handler: (heading: Double) -> ()) {
        
        self.handler = handler
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
    }
}

extension Compass: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        handler(heading: newHeading.trueHeading)
    }
}