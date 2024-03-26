//
//  Prospect.swift
//  HotProspect
//
//  Created by ramsayleung on 2024-03-23.
//

import SwiftData
import Foundation

@Model
class Prospect {
    var name: String
    var emailAddress: String
    var isContacted: Bool
    var createAt: Date
    
    init(name: String, emailAddress: String, isContacted: Bool, createdAt: Date) {
        self.name = name
        self.emailAddress = emailAddress
        self.isContacted = isContacted
        self.createAt = createdAt
    }
}
