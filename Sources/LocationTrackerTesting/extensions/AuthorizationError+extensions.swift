//
//  AuthorizationError+extensions.swift
//
//
//  Created by Thibaud David on 04/03/2024.
//

import Foundation
import LocationTracker

extension AuthorizationError: Equatable {
    public static func == (lhs: AuthorizationError, rhs: AuthorizationError) -> Bool {
        switch (lhs, rhs) {
        case (.locationDenied, .locationDenied),
            (.backgroundLocationDenied, .backgroundLocationDenied):
            return true
            
        case (.unexpected(let err1 as NSError), .unexpected(let err2 as NSError)):
            return err1.domain == err2.domain && err1.code == err2.code

        case (.locationDenied, _),
             (.backgroundLocationDenied, _),
             (.unexpected, _):
            return false
        }
    }
}
