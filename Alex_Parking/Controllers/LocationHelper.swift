//
//  LocationHelper.swift
//  Alex_Parking
//
//  Created by Alex Olechnowicz on 2023-03-28.
//

import Foundation
import CoreLocation
import Contacts
import MapKit

class LocationHelper : NSObject, ObservableObject, CLLocationManagerDelegate{
    private var locationManager = CLLocationManager()
    private var lastKnownLocation : CLLocation?
    private let geocoder = CLGeocoder()
    
    @Published var active: Bool = false
    
    @Published var currentLocation : CLLocation?
    @Published var currentAddress : String = ""
    
    override init() {
        super.init()
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.delegate = self
    }
    
    func activate(){
        self.locationManager = CLLocationManager()
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.delegate = self
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{
        case .authorizedWhenInUse:
            //enable location features
            manager.startUpdatingLocation()
            break
        case .restricted, .denied:
            //disable location features or request permission
//            manager.requestWhenInUseAuthorization()
            break
        case .notDetermined:
            //request permission
            manager.requestWhenInUseAuthorization()
            break
        default:
            break
        }
    }
    
    func checkLocation(address: String) async -> Bool{
        
        do{
            let coords = try await self.geocoder.geocodeAddressString(address)
            
            DispatchQueue.main.sync {
                self.currentLocation = coords[0].location
            }
            print("valid address")
        }
        catch{
            print("invalid address")
            return false
        }
        
        return true
    }
    
    func getLocation(address: String) async -> CLLocation?{
        
        do{
            let coords = try await self.geocoder.geocodeAddressString(address)
        
            print("valid address")
            return coords[0].location
        }
        catch{
            print("invalid address")
            return nil
        }
        
        //return coords.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        if active{
            print(#function, "location change is received")
            
            guard let location = locations.last else { return }
            
            Task{
                do{
                    let address = try await self.geocoder.reverseGeocodeLocation(location)
                    DispatchQueue.main.async {
                        self.currentAddress = address.first!.name!
                        print("done assigning")
                    }
                    print("done converting")
                    print(address.first!.name!)
                }
                catch{
                    print("Error converting location")
                }
            }
        }
        else{
            print("location not enabled")
        }
        
        
        
        
        
//        if locations.last != nil{
//            //most recent location
//            currentLocation = locations.last
//        }else{
//            //location.first - last know location
//            //oldest or previously known location
//            currentLocation = locations.first
//        }
        
        //lastKnownLocation = locations.first
        
        //print(#function, "Last known location : \(lastKnownLocation)")
        //print(#function, "Most recent location : \(currentLocation)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function, "Unable to receive location events : \(error.localizedDescription)")
    }
    
    //Escaping Closure
    func doReverseGeocoding(completionHandler: @escaping(String?, NSError?) -> Void){
        
        if currentLocation == nil{
            print("current location not found")
            return
        }
        
        self.geocoder.reverseGeocodeLocation(self.currentLocation!, completionHandler: { [self](placemarks, error) in
            if (error != nil){
                print(#function, "Unable to perform reverse geocoding : \(error?.localizedDescription)")
                
                //completionHandler of doReverseGeocoding()
                completionHandler(nil, error as NSError?)
            }else{
                if let placemarkList = placemarks, let placemark = placemarkList.first {
                    
                    print(#function, "Locality : \(placemark.locality ?? "NA")")
                    print(#function, "country : \(placemark.country ?? "NA")")
                    print(#function, "country code : \(placemark.isoCountryCode ?? "NA")")
                    print(#function, "sub-Locality : \(placemark.subLocality ?? "NA")")
                    print(#function, "Street-level address : \(placemark.thoroughfare ?? "NA")")
                    print(#function, "province : \(placemark.administrativeArea ?? "NA")")
    
                    let postalAddress : String = CNPostalAddressFormatter.string(from: placemark.postalAddress!, style: .mailingAddress)
                    print(#function, "Postal Address : \(postalAddress)")
                    
                    DispatchQueue.main.async {
                        self.currentAddress = postalAddress
                    }
                    
                    completionHandler(postalAddress, nil)
                   
                }else{
                    print(#function, "Unable to obtain placemark for reverse geocoding")
                }
            }
        })
    }
    
    func addPinToMap(mapView: MKMapView, coordinates : CLLocationCoordinate2D){
        
        let mapAnnotation = MKPointAnnotation()
        mapAnnotation.coordinate = coordinates
        mapAnnotation.title = "You're here"
        mapView.addAnnotation(mapAnnotation)
    }
}
