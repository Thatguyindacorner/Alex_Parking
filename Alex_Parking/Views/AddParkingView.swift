//
//  AddParkingView.swift
//  Alex_Parking
//
//  Created by Alex Olechnowicz on 2023-03-28.
//

import SwiftUI

extension String: Identifiable { public var id: String { self } }

extension Bool{
    func toColor() -> Color{
        switch self{
        case true:
            return Color.gray
        case false:
            return Color.black
        }
    }
}

struct AddParkingView: View {
    
    @EnvironmentObject var database: DatabaseConnection
    @StateObject var locationHelper: LocationHelper = LocationHelper()
    
    @State var selection: Parking?
    
    @State var buildingCode = ""
    @State var hours = 1
    @State var selectedLicensePlatePos = 0
    
    @State var useNewLicensePlate = false
    @State var newLicensePlate = ""
    
    @State var suiteNum = ""
    @State var location = ""
    
    @State var locationText = "Enter Street Address"
    @State var useCurrentLocation: Bool = false
    @State var timeParking = Date()
    
    @State var showAlert = false
    @State var errorTitle = ""
    @State var errorMessage = ""

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        let binding = Binding<String>(get: {
            if useCurrentLocation{
                DispatchQueue.main.async {
                    self.location = self.locationHelper.currentAddress
                }
                
                
                return self.locationHelper.currentAddress
            }
            else{
                return self.location
            }
            
                }, set: {
                    if !useCurrentLocation{
                        self.location = $0
                    }
                })
        
        VStack(spacing: 25){
            Spacer()
            if selection == nil{
                //add
                Text("Add Parking").font(.title)
            }
            else{
                //edit
                Text("Edit Parking").font(.title).onAppear{
                    buildingCode = selection!.buildingCode
                    suiteNum = selection!.roomNum
                    hours = selection!.pHours
                    useNewLicensePlate = true
                    newLicensePlate = selection!.plateID
                    location = selection!.pLocation
                }
            }
                

            Form{
                Section{
                    TextField("Building Code", text: $buildingCode)
                    TextField("Suite Number", text: $suiteNum)
                }
                
                Picker("Hours parking for", selection: $hours){
                    Text("0-1 hours").tag(1)
                    Text("4 hours").tag(4)
                    Text("12 hours").tag(12)
                    Text("24 hours").tag(24)
                }.pickerStyle(.segmented)
                
                Section{
                    if useNewLicensePlate{
                        TextField("Enter License Plate", text: $newLicensePlate)
                    }
                    else{
                        Picker("Choose License Plate", selection: $selectedLicensePlatePos){
                            ForEach(database.loggedInUser!.licensePlates){ plate in
                                Text(plate).tag(database.loggedInUser!.licensePlates.firstIndex(of: plate)!)
                            }
                        }
                    }
                    Toggle("Use new license plate", isOn: $useNewLicensePlate)
                }
                
                Section{

                    TextField(locationText , text: binding).disabled(useCurrentLocation).foregroundColor(useCurrentLocation.toColor())
                    
                    Toggle("Use current location", isOn: $useCurrentLocation).onChange(of: useCurrentLocation) { newValue in
                        switch newValue{
                        case true:
                            locationText = "Using current location"
                            locationHelper.active = true
                            locationHelper.activate()
                            location = locationHelper.currentAddress
    
                        case false:
                            locationText = "Enter Street Address"
                            locationHelper.active = false
                        }
                    }
                }
                
                Section{
                    Button(action:{
                        Task{
                            if await validated(){
                                
                                if selection != nil{
                                    print(selection!.id)
                                }
                                else{
                                    print("in add")
                                }
                                
                                
                                let newParking = Parking()
                                
                                print(newParking.id)
                                
                                newParking.buildingCode = buildingCode
                                newParking.roomNum = suiteNum
                                newParking.pHours = hours
                                if useNewLicensePlate{
                                    newParking.plateID = newLicensePlate
                                }
                                else{
                                    newParking.plateID = database.loggedInUser!.licensePlates[selectedLicensePlatePos]
                                }
                                
                                if useCurrentLocation{
                                    newParking.pLocation = locationHelper.currentAddress
                                }
                                else{
                                    newParking.pLocation = location
                                }
                                
                                if selection == nil{
                                    
                                    if await database.addParking(parking: newParking){
                                        //dismiss
                                        dismiss()
                                    }
                                    else{
                                        errorMessage = "Could not add Parking to the database"
                                        showAlert = true
                                    }
                                }
                                else{
                                    newParking.id = selection!.id
                                    newParking.pDateTime = selection!.pDateTime
                                    if await database.editParking(parking: newParking){
                                        //dismiss
                                        database.parkingList[database.parkingList.firstIndex { editParking in
                                            return editParking.id == selection!.id
                                        }!] = newParking
                                        dismiss()
                                    }
                                    else{
                                        errorMessage = "Could not edit Parking instance in the database"
                                        showAlert = true
                                    }
                                }
                                
                                
                            }
                            else{
                                showAlert = true
                            }
                        }
                        
                    }){
                        if selection == nil{
                            Text("Add Parking")
                        }
                        else{
                            Text("Edit Parking")
                        }
                        
                    }
                }.frame(maxWidth: .infinity ,alignment: .center)
                
            }
        }.alert(isPresented: $showAlert) {
            Alert(title: Text("Error Adding Parking"), message: Text(errorMessage), dismissButton: .cancel(Text("Okay")))
        }
    }
    
    func validated() async -> Bool{
        
        guard buildingCode != "" && suiteNum != "" && location != ""
        else{
            errorMessage = "Fields must by filled in"
            return false
        }
        
        if useNewLicensePlate{
            guard newLicensePlate.count >= 2 && newLicensePlate.count <= 8
            else{
                errorMessage = "License Plate must be between 2-8 alphanumeric charactors"
                return false
            }
            
            guard !database.parkingList.contains(where: { parking in
                print("plate: \(parking.plateID)")
                print("plateList: \(newLicensePlate)")
                print("new: \(parking.plateID == newLicensePlate)")
                if selection != nil{
                    if selection!.plateID == parking.plateID{
                        return false
                    }
                }
                return parking.plateID == newLicensePlate
            })
            else{
                errorMessage = "This License Plate has already been used"
                return false
            }
        }
        else{
            guard !database.parkingList.contains(where: { parking in
                print("plate: \(parking.plateID)")
                print("plateList: \(database.loggedInUser!.licensePlates[selectedLicensePlatePos])")
                print("old: \(parking.plateID == database.loggedInUser!.licensePlates[selectedLicensePlatePos])")
                if selection != nil{
                    if selection!.plateID == parking.plateID{
                        return false
                    }
                }
                return parking.plateID == database.loggedInUser!.licensePlates[selectedLicensePlatePos]
            })
            else{
                errorMessage = "This License Plate has already been used"
                return false
            }
        }
        
        
        
        guard buildingCode.count == 5
        else{
            errorMessage = "Building Code must be 5 alphanumeric charactors"
            return false
        }
        
        guard suiteNum.count >= 2 && suiteNum.count <= 5
        else{
            errorMessage = "Suite Number must be between 2-5 alphanumeric charactors"
            return false
        }
        
        print(location)
        guard await locationHelper.checkLocation(address: location)
        else{
            errorMessage = "Not a valid location"
            return false
        }
        
        return true
    }
    
}

struct AddParkingView_Previews: PreviewProvider {
    static var previews: some View {
        AddParkingView()
    }
}
