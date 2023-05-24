//
//  DatabaseConnection.swift
//  Alex_Parking
//
//  Created by Alex Olechnowicz on 2023-03-28.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class DatabaseConnection: ObservableObject{
    
    static var shared = DatabaseConnection()
    
    var linked: Bool = false
    
    var db: Firestore?{
        get{
            if linked{
                return Firestore.firestore()
            }
            else{
                return nil
            }
        }
    }
    
    @Published var loggedInUser: UserModel? = nil
    
    @Published var parkingList: [Parking] = []
    
    func signUp(newUser: UserModel) async -> Bool{
        
        guard db != nil
        else{
            print("No connection to database. May be no internet connection")
            return false
        }
        
        do{
            let authDataResult = try await Auth.auth().createUser(withEmail: newUser.email, password: newUser.password)
            let uid = authDataResult.user.uid
            
            newUser.uid = uid
            
            try db!.collection("parkingUsers").document(uid).setData(from: newUser)
            //try db!.collection("parkingUsers").document(uid).collection("parkings")
            print("user successfully created")
            
            DispatchQueue.main.sync {
                self.loggedInUser = newUser
            }
            
        }
        catch{
            print("could not create user")
            return false
        }
        
        print("returning true")
        return true
    }
    
    func logIn(userCredentials: UserModel) async -> Bool{
        
        guard db != nil
        else{
            print("No connection to database. May be no internet connection")
            return false
        }
        
        do{
            let authDataResult = try await Auth.auth().signIn(withEmail: userCredentials.email, password: userCredentials.password)
            let uid = authDataResult.user.uid
            
            print("user logged in")
            
            let activeUser = try await db!.collection("parkingUsers").document(uid).getDocument(as: UserModel.self)
            
            DispatchQueue.main.sync {
                self.loggedInUser = activeUser
                print("done active")
            }
            
            let parkings = try await db!.collection("parkingUsers").document(uid).collection("parkings").getDocuments()
            
            print("number of parkings: \(parkings.documents.count)")
            print("parkings: \(self.parkingList)")
            
            try DispatchQueue.main.sync {
                
                for parking in parkings.documents{
                    let newParking = try parking.data(as: Parking.self)
                    newParking.id = parking.documentID
                    self.parkingList.append(newParking)
                    
                }
                
                print("number of parkings after: \(self.parkingList)")
            }
            print("user data pulled")
        }
        catch{
            print("could not sign in and pull user data")
            return false
        }
        
        print("returning true")
        return true
    }
    
    func addParking(parking: Parking) async -> Bool{
        guard db != nil
        else{
            print("No connection to database. May be no internet connection")
            return false
        }
        
        let userDoc = db!.collection("parkingUsers").document(loggedInUser!.uid)
        
        do{
            //try await userDoc.updateData(["parkings": loggedInUser!.parkings])
            let ref = userDoc.collection("parkings").document()
            try ref.setData(from: parking)
            
            parking.id = ref.documentID
            
            DispatchQueue.main.sync {
                self.parkingList.append(parking)
                print(self.parkingList.count)
            }
            print("added")
        }
        catch{
            print("cant do this")
            return false
        }
        return true
    }
    
    func editParking(parking: Parking) async -> Bool{
        guard db != nil
        else{
            print("No connection to database. May be no internet connection")
            return false
        }
        
        let userDoc = db!.collection("parkingUsers").document(loggedInUser!.uid)
        
        do{
            //try await userDoc.updateData(["parkings": loggedInUser!.parkings])
            try userDoc.collection("parkings").document(parking.id!).setData(from: parking.self)
        
            print("edited")
        }
        catch{
            print("cant do this")
            return false
        }
        return true
    }
    
    func deleteParking(parking: Parking) async -> Bool{
        guard db != nil
        else{
            print("No connection to database. May be no internet connection")
            return false
        }
        
        let userDoc = db!.collection("parkingUsers").document(loggedInUser!.uid)
        
        do{
            //try await userDoc.updateData(["parkings": loggedInUser!.parkings])
            try await userDoc.collection("parkings").document(parking.id!).delete()
        
            print("deleted from database")
            
            DispatchQueue.main.sync {
                self.parkingList.remove(at: self.parkingList.firstIndex(where: { p in
                    return p.plateID == parking.plateID
                })!)
            }
            
            print("deleted from UI")
            
            
        }
        catch{
            print("cant do this")
            return false
        }
        return true
    }
    
    func updateProfile(userInfo: UserModel) async -> Bool{
        guard db != nil
        else{
            print("No connection to database. May be no internet connection")
            return false
        }
        
        let userDoc = db!.collection("parkingUsers").document(userInfo.uid)
        
        do{
            //try await userDoc.updateData(["parkings": loggedInUser!.parkings])
            try userDoc.setData(from: userInfo.self)
        
            DispatchQueue.main.sync {
                self.loggedInUser = userInfo
            }
            
            print("edited")
        }
        catch{
            print("cant do this")
            return false
        }
        return true
    }
    
}
