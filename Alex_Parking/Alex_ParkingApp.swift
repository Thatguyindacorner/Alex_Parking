//
//  Alex_ParkingApp.swift
//  Alex_Parking
//
//  Created by Alex Olechnowicz on 2023-03-28.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      DatabaseConnection.shared.linked = true
    return true
  }
}

@main
struct Alex_ParkingApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let database = DatabaseConnection.shared
    
    var body: some Scene {
        WindowGroup {
            LoginView().environmentObject(database)
            //ContentView()
        }
    }
}
