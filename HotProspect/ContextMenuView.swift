//
//  ContextMenuView.swift
//  HotProspect
//
//  Created by ramsayleung on 2024-03-21.
//

import SwiftUI

struct ContextMenuView: View {
    @State private var backgroundColor = Color.red
    var body: some View {
        Text("Hello, world!")
            .padding()
            .background(backgroundColor)
        
        Text("Change Color")
            .padding()
            .contextMenu {
                Button("Red", systemImage: "checkmark.circle.fill", role: .destructive){
                    backgroundColor = Color.red
                }
                Button("Green"){
                    backgroundColor = Color.green
                }
                Button("Blue"){
                    backgroundColor = Color.blue
                }
            }
    }
}

#Preview {
    ContextMenuView()
}
