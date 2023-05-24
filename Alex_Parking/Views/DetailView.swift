//
//  DetailView.swift
//  Alex_Parking
//
//  Created by Alex Olechnowicz on 2023-03-28.
//

import SwiftUI

struct DetailView: View {
    
    @EnvironmentObject var database: DatabaseConnection
    
    @State var selection: Parking
    
    @State var gotoMapView = false
    
    var body: some View {
        
        //NavigationView{
            
            VStack{
                NavigationLink(destination: MapView(address: selection.pLocation), isActive: $gotoMapView){}
                Form{
                    Text("Lisence Plate: \(selection.plateID)")
                    Text("Parked for: \(selection.pHours) hours")
                    Text("On: \(selection.pDateTime.formatted())")
                    Text("At: \(selection.pLocation)")
                    
                    Text("Building Code: \(selection.buildingCode)")
                    Text("Suite Number: \(selection.roomNum)")
                    
                    Section{
                        
                        Button(action:{
                            gotoMapView = true
                        })
                        {
                            Text("See Map")
                        }
                    }
                }
            }
       // }
        
        
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
