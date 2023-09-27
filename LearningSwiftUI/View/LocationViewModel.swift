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
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            num = num + 1
        }
    }
}
