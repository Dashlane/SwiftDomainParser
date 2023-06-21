//
//  ParsedHost.swift
//  DomainParser
//
//  Created by Jason Akakpo on 19/07/2018.
//  Copyright © 2018 Dashlane. All rights reserved.
//

import Foundation

public struct ParsedHost {

    /// E.g. "com", "co.uk"
    public let publicSuffix: String

    /// (Registrable) domain excluding subdomains. E.g. "github.com", "amazon.co.uk"
    public let domain: String?

}

extension ParsedHost: Equatable {

    public static func == (lhs: ParsedHost, rhs: ParsedHost) -> Bool {
        return (lhs.publicSuffix == rhs.publicSuffix && lhs.domain == rhs.domain)
    }

}
