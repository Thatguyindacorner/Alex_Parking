//
//  UserProfileView.swift
//  Alex_Parking
//
//  Created by Alex Olechnowicz on 2023-03-28.
//

import SwiftUI

struct UserProfileView: View {
    
    @EnvironmentObject var database: DatabaseConnection
    
    @State var name = ""
    @State var phoneNum = ""
    @State var newLicense = ""
    
    @State var showAlert = false
    @State var errorTitle = ""
    @State var errorMessage = ""
    
    @State var addLicense: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        VStack(spacing: 25){
            Spacer()
            Text("Edit Profile").font(.title)
                .onAppear{
                name = database.loggedInUser!.name
                phoneNum = database.loggedInUser!.number
            }
            Form{
                TextField("Name", text: $name)
                TextField("Phone Number", text: $phoneNum)
                Section{
                    TextField("New license plate", text: $newLicense).disabled(!addLicense)
                    Toggle("Add a new license", isOn: $addLicense)
                }
                
                Button(action:{
                    
                    if validated(){
                        
                        var newUserInfo = UserModel()
                        
                        newUserInfo.email = database.loggedInUser!.email
                        newUserInfo.password = database.loggedInUser!.password
                        
                        newUserInfo.name = name
                        newUserInfo.number = phoneNum
                        
                        newUserInfo.id = database.loggedInUser!.id
                        newUserInfo.uid = database.loggedInUser!.uid
                        
                        newUserInfo.licensePlates = database.loggedInUser!.licensePlates
                        
                        if addLicense{
                            newUserInfo.licensePlates.append(newLicense)
                        }

                        //newUserInfo.parkings = database.loggedInUser!.parkings
                        
                        Task{
                            if await database.updateProfile(userInfo: newUserInfo){
                                dismiss()
                            }
                            else{
                                errorMessage = "Could not edit User's Profile in the database"
                                showAlert = true
                            }
                        }
                    }
                    else{
                        showAlert = true
                    }
                }){
                    Text("Update Profile Info")
                }
                
                Section{
                    Button(action:{
                        database.loggedInUser = nil
                        database.parkingList = []
                        dismiss()
                    }){
                        Text("Sign Out")
                    }
                }
                
                
            }
        }.alert(isPresented: $showAlert){
            Alert(title: Text("Error Editing Info"), message: Text(errorMessage), dismissButton: .cancel(Text("Okay")))
        }
    }
    
    func validated() -> Bool{
        
        guard name != "" && phoneNum != ""
        else{
            errorTitle = "Error trying to Edit Profile"
            errorMessage = "Fields must be filled in"
            return false
        }
        
        if addLicense{
            guard newLicense != ""
            else{
                errorTitle = "Error trying to Edit Profile"
                errorMessage = "Fields must be filled in"
                return false
            }
            
            guard !database.parkingList.contains(where: { parking in
                return parking.plateID == newLicense
            })
            else{
                errorMessage = "This License Plate is already in your saved list"
                return false
            }
        }
        
        return true
    }
    
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
