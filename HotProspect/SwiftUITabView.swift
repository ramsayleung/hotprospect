//
//  SwiftUITabView.swift
//  HotProspect
//
//  Created by ramsayleung on 2024-03-20.
//

import SwiftUI

struct SwiftUITabView: View {
    @State private var selectedTab = "One"
    @State private var output = ""
    var body: some View {
        TabView(selection: $selectedTab) {
            Button("Show Tab 2"){
                selectedTab = "Two"
            }
            .tabItem { Label("One", systemImage: "star") }
            .tag("One")
            Text("Tab2")
                .tabItem { Label("Two", systemImage: "circle") }
                .tag("Two")
        }
        
        Text(output)
            .task {
                await fetchReadings()
            }
    }
    
    func fetchReadings() async {
        let fetchTask = Task {
            let url = URL(string: "https://hws.dev/readings.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let readings = try JSONDecoder().decode([Double].self, from: data)
            return "Found \(readings.count) readings"
        }
        
        let result = await fetchTask.result
        switch result {
        case .success(let str):
            output = str
        case .failure(let error):
            output = "Error: \(error.localizedDescription)"
        }
    }
}

#Preview {
    SwiftUITabView()
}
