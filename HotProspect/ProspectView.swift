//
//  ProspectView.swift
//  HotProspect
//
//  Created by ramsayleung on 2024-03-23.
//

import SwiftUI
import SwiftData
import CodeScanner

enum FilterType {
    case none, contacted, uncontacted
}

struct ProspectView: View {
    let filter: FilterType
    @Query(sort: \Prospect.name) var prospects: [Prospect]
    @Environment(\.modelContext) var modelContext
    @State private var isShowingScanner = false
    @State private var selectedProspect = Set<Prospect>()
    
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
            List(prospects, selection: $selectedProspect){ prospect in
                VStack(alignment: .leading) {
                    Text(prospect.name)
                        .font(.headline)
                    
                    Text(prospect.emailAddress)
                        .foregroundStyle(.secondary)
                }.swipeActions {
                    Button("Delete", systemImage: "trash", role: .destructive){
                        modelContext.delete(prospect)
                    }
                    
                    if prospect.isContacted {
                        Button("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark"){
                            prospect.isContacted.toggle()
                        }.tint(.blue)
                    }else {
                        Button("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark"){
                            prospect.isContacted.toggle()
                        }.tint(.green)
                    }
                }
                .tag(prospect)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Scan", systemImage: "qrcode.viewfinder") {
                        isShowingScanner = true
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
                if !selectedProspect.isEmpty {
                    ToolbarItem(placement: .bottomBar){
                        Button("Delete Selected", role: .destructive, action: deleteSelected)
                    }
                }
            }
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Justin\nthisis@gmail.com", completion: handleScan)
            }
        }
    }
    
    func deleteSelected() {
        for prospect in selectedProspect {
            modelContext.delete(prospect)
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        // more code to come
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else {return}
            let person = Prospect(name: details[0], emailAddress: details[1], isContacted: false)
            modelContext.insert(person)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
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
