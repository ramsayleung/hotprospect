//
//  EditProspectView.swift
//  HotProspect
//
//  Created by ramsayleung on 2024-03-25.
//

import SwiftUI

struct EditProspectView: View {
    let prospect: Prospect
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var emailAddress = ""
    var onSave: (Prospect) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                }
                
                Section("Email Address"){
                    TextField("EmailAddress", text: $emailAddress)
                        .textContentType(.emailAddress)
                }
                
                Section("Created At") {
                    Text(prospect.createAt.formatted(date: .abbreviated, time: .shortened))
                }
            }.toolbar {
                Button("Save"){
                    let newProspect = prospect
                    newProspect.name = name
                    newProspect.emailAddress = emailAddress
                    onSave(newProspect)
                    dismiss()
                }
            }
        }
    }
    
    init(prospect: Prospect, onSave: @escaping (Prospect) -> Void) {
        self.prospect = prospect
        _name = State(initialValue: prospect.name)
        _emailAddress = State(initialValue: prospect.emailAddress)
        self.onSave = onSave
    }
}

#Preview {
    let prospect = Prospect(name: "Sample", emailAddress: "1@gmail.com", isContacted: false, createdAt: Date.now)
    return EditProspectView(prospect: prospect){ prospect in
        
    }
}
