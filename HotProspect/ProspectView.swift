//
//  ProspectView.swift
//  HotProspect
//
//  Created by ramsayleung on 2024-03-23.
//

import SwiftUI
import SwiftData

enum FilterType {
    case none, contacted, uncontacted
}

struct ProspectView: View {
    let filter: FilterType
    @Query(sort: \Prospect.name) var prospects: [Prospect]
    @Environment(\.modelContext) var modelContext
    
    var title: String {
        switch filter {
        case .none:
            "Everyone"
        case .contacted:
            "Contacted"
        case .uncontacted:
            "Uncontacted"
        }
    }
    
    var body: some View {
        NavigationStack {
            List(prospects){ prospect in
                VStack(alignment: .leading) {
                    Text(prospect.name)
                        .font(.headline)
                    
                    Text(prospect.emailAddress)
                        .foregroundStyle(.secondary)
                }
            }
                .navigationTitle(title)
                .toolbar {
                    Button("Scan", systemImage: "qrcode.viewfinder") {
                        let prospect = Prospect(name: "Paul Hudson", emailAddress: "ramsayleung@gmail.com", isContacted: false)
                        modelContext.insert(prospect)
                    }
                }
        }
    }
    
    init(filter: FilterType) {
        self.filter = filter
        if filter != .none {
            let showContactOnly = (filter == .contacted)
            _prospects = Query(filter: #Predicate {
                $0.isContacted == showContactOnly
            }, sort: [SortDescriptor(\Prospect.name)])
        }
    }
}

#Preview {
    ProspectView(filter: .none)
        .modelContainer(for: Prospect.self)
}
