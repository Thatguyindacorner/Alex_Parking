//
//  ViewParkingView.swift
//  Alex_Parking
//
//  Created by Alex Olechnowicz on 2023-03-28.
//

import SwiftUI

enum SheetView{
    case profile
    case addParking
    case editParking
}

struct ViewParkingView: View {
    
    @EnvironmentObject var database: DatabaseConnection
    
    @State var parkingList: [Parking] = []
    
    @State var sheetToDisplay: SheetView = .profile
    
    @State var showSheet = false
    
    @State var selectedParking: Parking? = nil
    
    @State var inDisplay: Bool = false
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        
        let binding = Binding<Bool>(get: {
            if self.selectedParking != nil{
                if sheetToDisplay != .editParking{
                    return true
                }
                else{
                    return false
                }
            }
            else{
                return false
            }
                }, set: {
                    self.inDisplay = $0
                })
        
        NavigationView{
            VStack{
                if database.loggedInUser == nil{
                    //logout
                    Text("Signing Out").onAppear{
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                else{
                    if selectedParking != nil{
                        NavigationLink(destination: DetailView(selection: selectedParking!).environmentObject(database), isActive: binding){}
                    }
                    
                    
                    if parkingList.isEmpty{
                        Text("No Parkings Yet")
                    }
                    else{
                        List{
                            ForEach(parkingList.sorted(by: { p1, p2 in
                                return p1.pDateTime > p2.pDateTime
                            }), id: \.id){ parking in
                                Button(action:{
                                    selectedParking = parking
                                    if sheetToDisplay == .editParking{
                                        showSheet = true
                                    }
                                }){
                                    VStack{
                                        Text("\(parking.plateID) parked at \(parking.pLocation)")
                                        Text("on \(parking.pDateTime.formatted()) for \(parking.pHours) hours")
                                    }.foregroundColor(Color.black)
                                }
                                
                            }.onDelete { IndexSet in
                                for index in IndexSet{
                                    let toDelete = parkingList.sorted(by: { p1, p2 in
                                        return p1.pDateTime > p2.pDateTime
                                    })[index]
                                    Task{
                                        if await database.deleteParking(parking: toDelete){
                                            parkingList = database.parkingList
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }.onAppear{
                print("appeared")
                sheetToDisplay = .profile
                selectedParking = nil
                parkingList = database.parkingList
                print(parkingList.count)
            }
            .sheet(isPresented: $showSheet, onDismiss: {
                sheetToDisplay = .profile
                selectedParking = nil
                if database.loggedInUser != nil{
                    parkingList = database.parkingList
                }
                
            }){
                switch sheetToDisplay{
                case .profile:
                    UserProfileView().environmentObject(database)
                case .addParking:
                    AddParkingView(selection: nil).environmentObject(database)
                case .editParking:
                    //edit
                    AddParkingView(selection: selectedParking!).environmentObject(database)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action:{
                        selectedParking = nil
                        sheetToDisplay = .profile
                        showSheet = true
                    }){
                        Image(systemName: "person.text.rectangle")
                    }
                    
                }
                
//                if sheetToDisplay == .editParking{
//                    ToolbarItem(placement: .bottomBar){
//                        
//                        Text("Edit selected")
//                        
//                    }
//                }
                
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action:{
                        selectedParking = nil
                        sheetToDisplay = .addParking
                        showSheet = true
                    }){
                        Image(systemName: "plus")
                    }
                    
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    
                    if sheetToDisplay == .editParking{
                        Button(action:{
                            selectedParking = nil
                            sheetToDisplay = .profile
                        }){
                            Text("Done")
                        }
                    }
                    else{
                        Button(action:{
                            sheetToDisplay = .editParking
                        }){
                            Text("Edit")
                        }
                    }
                    
                    
                    
                }
            }.navigationTitle("Parking List")
        }.navigationBarBackButtonHidden(true)
            
    }
}

struct ViewParkingView_Previews: PreviewProvider {
    static var previews: some View {
        ViewParkingView().environmentObject(DatabaseConnection.shared)
    }
}
