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

struct ProspectListingView: View {
    let filter: FilterType
    @Query var prospects: [Prospect]
    @Binding var selectedProspect: Set<Prospect>
    
    var body: some View {
        List(prospects, selection: $selectedProspect) { prospect in
            NavigationLink {
                EditProspectView(prospect: prospect) { updateProspect in
                    prospect.name = updateProspect.name
                    prospect.emailAddress = updateProspect.emailAddress
                }
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(prospect.name)
                            .font(.headline)
                        
                        Text(prospect.emailAddress)
                            .foregroundStyle(.secondary)
                        
                    }.swipeActions {
                        SwipeActionView(prospect: prospect)
                    }
                    .tag(prospect)
                    Spacer()
                    
                    Image(systemName: "person.crop.circle.fill.badge.checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(prospect.isContacted ? .green : .gray)
                }
            }
        }
    }
    
    init(filter: FilterType, sortOrder: [SortDescriptor<Prospect>], selectedProspect: Binding<Set<Prospect>>) {
        self.filter = filter
        _selectedProspect = selectedProspect
        if filter != .none {
            let showContactOnly = (filter == .contacted)
            _prospects = Query(filter: #Predicate {
                $0.isContacted == showContactOnly
            }, sort: sortOrder, animation: .default)
        } else {
            _prospects = Query(sort: sortOrder, animation: .default)
        }
    }
}

struct ProspectView: View {
    let filter: FilterType
    
    @State var sortOrder = [
        SortDescriptor(\Prospect.createAt),
        SortDescriptor(\Prospect.name),
    ]
    
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
            ProspectListingView(filter: filter, sortOrder: sortOrder, selectedProspect: $selectedProspect)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Menu("Sort by", systemImage: "arrow.up.arrow.down"){
                        Picker("Order", selection: $sortOrder){
                            Text("Sort by Name")
                                .tag(
                                    [
                                        SortDescriptor(\Prospect.name),
                                        SortDescriptor(\Prospect.createAt),
                                    ]
                                )
                            Text("Sort by Date")
                                .tag(
                                    [
                                        SortDescriptor(\Prospect.createAt),
                                        SortDescriptor(\Prospect.name),
                                    ]
                                )
                        }
                    }
                }
                
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
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else {return}
            let person = Prospect(name: details[0], emailAddress: details[1], isContacted: false, createdAt: Date.now)
            modelContext.insert(person)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }

}

#Preview {
    ProspectView(filter: .none)
        .modelContainer(for: Prospect.self)
}
