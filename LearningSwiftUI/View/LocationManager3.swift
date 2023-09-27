//
import UIKit
import CoreMotion
import CoreLocation
import Contacts



struct Location : CustomStringConvertible {
    
    var current_lat : CLLocationDegrees?
    var current_lng : CLLocationDegrees?
    var current_formattedAddr : String?
    var current_city : String?
    var current_area : String?
    var current_placeName: String?
    var currentCountry: String?
    var currentISOCountryCode: String?
    var currentState : String?
    var currentPostalCode: String?
    var mobileNumberCode: String?
    var county: String?
    
    
    var description: String{
        return self.appendOptionalStrings(withArray: [current_formattedAddr])
    }
    
    func appendOptionalStrings(withArray array : [String?]) -> String {
        
        return array.compactMap{$0}.joined(separator: " ")
    }
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    var currentLocation : Location? = Location()
    private var locationManager = CLLocationManager()
    private var locationUpdateCallback: ((CLLocation) -> Void)?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocationUpdate(_ callback: @escaping (CLLocation) -> Void) {
        locationUpdateCallback = callback
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdate() {
        locationManager.stopUpdatingLocation()
        locationUpdateCallback = nil
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
           
            
            locationUpdateCallback?(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed with error: \(error.localizedDescription)")
    }
}


extension LocationManager {
    
    func getLocation(){
        if UserData.share.selectedServiceAddress != nil{
            self.currentLocation?.current_lat = CLLocationDegrees(/UserData.share.selectedServiceAddress?.lat)
            self.currentLocation?.current_lng = CLLocationDegrees(/UserData.share.selectedServiceAddress?.long)
            self.currentLocation?.currentPostalCode = UserData.share.selectedServiceAddress?.zip
            self.currentLocation?.current_formattedAddr = UserData.share.selectedServiceAddress?.address
            self.currentLocation?.county = UserData.share.selectedServiceAddress?.county
        }else{
            self.startTrackingUser()
        }
    }
    
    func startTrackingUser(){
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }
    
    
    func getCounty(by lat:CLLocationDegrees?, lng:CLLocationDegrees?, completion:@escaping (String)->Void){
        let location = CLLocation(latitude: /lat, longitude: /lng)
        if /UserData.share.loggedInUser?.accessToken != "" && lat != 0.0 && lng != 0.0{
            self.handleCountyFromLatiLongi(location) { respnse in
                let parsed = respnse.replacingOccurrences(of: " County", with: " ")
                completion(parsed)
            }
        }
    }

    func handleCountyFromLatiLongi(_ location : CLLocation, completion:@escaping (String)->Void){
        
        reverseGeocodeLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { city, country, countryISOCode, postalCode, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let city = city, let country = country, let countryISOCode = countryISOCode, let postalCode = postalCode {
                print("City: \(city)")
                print("Country: \(country)")
                print("Country ISO Code: \(countryISOCode)")
                print("Postal Code: \(postalCode)")
                if /postalCode != "" {
                    self.getCountyNew(by: /postalCode) { respnse in
                        completion(respnse)
                    }
                }else {
                    completion("")
                }
            } else {
                completion("")
            }
            
        }
        
    }

    func reverseGeocodeLocation(latitude: Double, longitude: Double, completion: @escaping (String?, String?, String?, String?, Error?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard error == nil else {
                completion(nil, nil, nil, nil, error)
                return
            }

            if let placemark = placemarks?.first {
                let city = placemark.locality ?? ""
                let country = placemark.country ?? ""
                let countryISOCode = placemark.isoCountryCode ?? ""
                let postalCode = placemark.postalCode ?? ""

                completion(city, country, countryISOCode, postalCode, nil)
            } else {
                completion(nil, nil, nil, nil, nil)
            }
        }
    }
    func getCountyNew(by zipCode: String?, completion:@escaping (String)->Void){
        
        HomeEndpoint.getNewCounty(zipCode: zipCode).request(isImage: false, images: [], isLoaderNeeded: false, header: ["authorization": "bearer " + /UserData.share.loggedInUser?.accessToken]) { (response) in
            print(response)
            switch response{
            case .success(let respnse):
                let parsed = respnse as? String ?? "".replacingOccurrences(of: "County", with: "")
                completion(parsed)
            case .failure(_):
                completion("")
            }
        }
    }
    func getFullAddress(from location: CLLocation, completion: @escaping (_ address:String?,_ error: Error?) -> ())  {
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Error reverse geocoding location: \(error.localizedDescription)")
                return
            }

            guard let place = placemarks?.first else {
                print("No placemark found.")
                return
            }

            let postalAddressFormatter = CNPostalAddressFormatter()
            postalAddressFormatter.style = .mailingAddress

            if let postalAddress = place.postalAddress {
                let addressString = postalAddressFormatter.string(from: postalAddress)
                print("Formatted Address: \(addressString)")
                completion(addressString, error)
            } else {
                print("No postal address available.")
                completion("", error)
            }
        }
      
    }
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city:String?,_ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            
            let val = placemarks?.first?.subAdministrativeArea
            let subLocality = placemarks?.first?.subLocality
            let locality = placemarks?.first?.locality
            let country = placemarks?.first?.country
            if let zipCode = placemarks?.first?.postalCode {
                objSelectedLocation.selectedZipCode = zipCode
            } else {
                
            }
            
            let finalAddress: String =   "\(val ?? "") \(subLocality ?? "") \(locality ?? "") \(country ?? "")"
            completion(finalAddress, error)
        }
    }
  
    
    //MARK:- WHEN DENIED
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if status == CLAuthorizationStatus.denied {
            UserDefaults.standard.set("\(0.0)", forKey: "lat")
            UserDefaults.standard.set("\(0.0)", forKey: "long")
            UserDefaults.standard.synchronize()
            objSelectedLocation.selectedLatitute = 0.0
            objSelectedLocation.selectedLongitute = 0.0
            self.generateAlertToNotifyUser(status: status)
        }
    }
    func generateAlertToNotifyUser( status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse,.authorizedAlways:
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        case .denied:
            var title: String
            title = "Location Services Off"
            let message: String = "Track Ride"
            showAlertContr(title, msgStr: message)
        case .notDetermined:
            let title = ""
            let message = "Location Service Enable"
            showAlertContr(title, msgStr: message)
        default:
            break
        }
    }
    func showAlertContr(_ titleStr: String, msgStr: String){
        let alertController = UIAlertController(title: titleStr, message: msgStr , preferredStyle: .alert)
        let okBtnAction = UIAlertAction(title:  "Settings", style: .default) { (action) in
            
            let settingsURL = NSURL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.canOpenURL(settingsURL as URL)
        }
        let cancelBtnAction = UIAlertAction(title: "Cancel", style: .destructive) { (action) in}
        alertController.addAction(okBtnAction)
        alertController.addAction(cancelBtnAction)
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
    func calculateInitialBearing(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let φ1 = lat1.degreesToRadians
        let φ2 = lat2.degreesToRadians
        let Δλ = (lon2 - lon1).degreesToRadians

        let y = sin(Δλ) * cos(φ2)
        let x = cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(Δλ)
        let bearing = atan2(y, x).radiansToDegrees

        return (bearing + 360).truncatingRemainder(dividingBy: 360) // Normalize to [0, 360) range
    }

}



class LocationData: Codable {
    var lat: Double?
    var long: Double?
    var bearing: Double?
    var accuracy: Double?
    var userId: String?
    var address : String?
    init(latitude: Double, longitude: Double, _bearing: Double?, _accuracy: Double?, _address: String?) {
        userId = /UserData.share.loggedInUser?.id
        lat = latitude
        long = longitude
        bearing = _bearing
        accuracy = _accuracy
        address = _address
    }
    
    func getDictionary() -> [String : Any]? {
        return JSONHelper<LocationData>().toDictionary(model: self)
    }


}


extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ zipcode :String?, _ error: Error?) -> ()) {
        
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country,$0?.first?.postalCode, $1) }
    }
}



extension Double {
var degreesToRadians: Double { return self * .pi / 180.0 }
var radiansToDegrees: Double { return self * 180.0 / .pi }
}



