//
//  Object.swift
//  Boot
//
//  Created by Lefebvre, Louis on 10/31/25.
//

import Foundation

enum Location {
    case local
    case cloud
}

struct Object: Identifiable {
    let id = UUID()
    
    var name: String
    
    var location: Location = .local
}

extension Object: Equatable {
    static func == (lhs: Object, rhs: Object) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.location == rhs.location
    }
}
