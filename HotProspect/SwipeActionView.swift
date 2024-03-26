//
//  SwipeActionView.swift
//  HotProspect
//
//  Created by ramsayleung on 2024-03-25.
//

import SwiftUI
import UserNotifications

struct SwipeActionView: View {
    @Environment(\.modelContext) var modelContext
    
    let prospect: Prospect
    var body: some View {
        Button("Delete", systemImage: "trash", role: .destructive){
            modelContext.delete(prospect)
        }
        
        if prospect.isContacted {
            Button("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark"){
                prospect.isContacted.toggle()
            }.tint(.blue)
        } else {
            Button("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark"){
                prospect.isContacted.toggle()
            }.tint(.green)
            
            Button("Send Notification", systemImage: "bell"){
                addNotification(prospect: prospect)
            }.tint(.orange)
        }
    }
    
    func addNotification(prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            //            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { setting in
            if setting.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) {success, error in
                    if success {
                        addRequest()
                    } else if let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}


#Preview {
    let prospect = Prospect(name: "Sample", emailAddress: "1@gmail.com", isContacted: false, createdAt: Date.now)
    return SwipeActionView(prospect: prospect)
            .modelContainer(for: Prospect.self)
}
