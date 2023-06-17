//
//  ParsedHost.swift
//  DomainParser
//
//  Created by Jason Akakpo on 19/07/2018.
//  Copyright © 2018 Dashlane. All rights reserved.
//

import Foundation

public struct ParsedHost {

    public let publicSuffix: String
    /// Domain excluding subdomains
    public let domain: String?

}

extension ParsedHost: Equatable {

    public static func == (lhs: ParsedHost, rhs: ParsedHost) -> Bool {
        return (lhs.publicSuffix == rhs.publicSuffix && lhs.domain == rhs.domain)
    }

}
