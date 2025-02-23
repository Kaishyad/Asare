//
//  newUser.swift
//  Asare
//
//  Created by Kaishya Desai on 05/02/2025.
//

import Foundation
import SwiftData

@Model
final class newUser {
    var username: String
    
    init(username: String) {
        self.username = username
    }
}
