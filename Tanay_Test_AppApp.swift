//
//  Tanay_Test_AppApp.swift
//  Shared
//
//  Created by Admin on 6/7/22.
//

import SwiftUI
import Firebase

@main
struct Tanay_Test_AppApp: App {

    init() {
        FirebaseApp.configure()
        
    }

    var body: some Scene {
        WindowGroup {
            ListFrame()
        }
    }
}
