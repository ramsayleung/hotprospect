//
//  HotProspectApp.swift
//  HotProspect
//
//  Created by ramsayleung on 2024-03-20.
//

import SwiftUI
import SwiftData

@main
struct HotProspectApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.modelContainer(for: Prospect.self)
    }
        
}
