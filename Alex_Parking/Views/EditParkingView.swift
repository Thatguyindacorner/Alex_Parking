//
//  EditParkingView.swift
//  Alex_Parking
//
//  Created by Alex Olechnowicz on 2023-03-28.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    @EnvironmentObject var database: DatabaseConnection
    
    @State var location: CLLocation? = nil
    
    @State var address: String
    
    @State var mapLoaded = false
    
    @State var showAlert = false
    @State var errorMessage = ""
    
    var body: some View {
        VStack{
            if mapLoaded{
                MyMap(location: location!)
            }
            else{
                if errorMessage != ""{
                    Text("Could not load map")
                }
                else{
                    Text("Loading map...")
                }
            }
            
        }.onAppear{
            Task{
                guard let mappedLocation = await LocationHelper().getLocation(address: address)
                else{
                    errorMessage = "Could not load map"
                    showAlert = true
                    return
                }

                    location = mappedLocation
                    mapLoaded = true
                print(address)
                print(location!.coordinate)

            }
            
        }.alert(isPresented: $showAlert){
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .cancel(Text("Okay")))
        }
        
    }
}

struct MyMap : UIViewRepresentable{
    typealias UIViewType = MKMapView
    
    private var location: CLLocation

    
    init(location: CLLocation) {
        self.location = location
    }
    
    func makeUIView(context: Context) -> MKMapView{
        let sourceCordinates : CLLocationCoordinate2D
        let region : MKCoordinateRegion
        
        sourceCordinates = location.coordinate
        
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        region = MKCoordinateRegion(center: sourceCordinates, span: span)
        
        let map = MKMapView()
        
        map.mapType = MKMapType.hybrid
        map.setRegion(region, animated: true)
        map.showsUserLocation = true
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        
        return map
        
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        print(#function, "Trying to update MyMap")
        
        let sourceCordinates : CLLocationCoordinate2D
        let region : MKCoordinateRegion
        
        sourceCordinates = location.coordinate
        
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        region = MKCoordinateRegion(center: sourceCordinates, span: span)
        
        uiView.setRegion(region, animated: true)
        LocationHelper().addPinToMap(mapView: uiView, coordinates: sourceCordinates)
        
    }
    
}
