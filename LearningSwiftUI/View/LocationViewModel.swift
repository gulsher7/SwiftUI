//
//  LocationViewModel.swift
//  LearningSwiftUI
//
//  Created by Gulsher Khan on 27/09/23.
//

import Foundation

import SwiftUI
import CoreLocation

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    
    @Published var latitude: Double?
    @Published var longitude: Double?
    
    var num: Int = 0
    
    // Add properties to track distance
        private var lastLocation: CLLocation?
        private var totalDistance: CLLocationDistance = 0.0
        private let desiredDistance: CLLocationDistance = 10.0 // Change this to your desired distance in meters
        
    
    override init() {
        super.init()
        

    }
    
    func startLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.startUpdatingLocation()
    }
    
    func stopLocation(){
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.showsBackgroundLocationIndicator = false
        locationManager.stopUpdatingLocation()
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
      
            // Calculate distance
                       if let last = lastLocation {
                           let distance = location.distance(from: last)
                           totalDistance += distance
                           
                           // Check if the desired distance is reached
                           if totalDistance >= desiredDistance {
                               // Perform an action here, for example, print a message
                               latitude = location.coordinate.latitude
                               longitude = location.coordinate.longitude
                               num = num + 1
                               
                               print("You have walked \(desiredDistance) meters!")
                               
                               // Reset the total distance and last location
                               totalDistance = 0.0
                               lastLocation = nil
                           }
                       }
                       
                       // Update the last location
                       lastLocation = location
        }
    }
}
