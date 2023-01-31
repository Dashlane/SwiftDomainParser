//
//  DomainParserProtocol.swift
//  DomainParser
//
//  Created by Rayane Kurrimboccus on 31/01/2023.
//  Copyright © 2023 Dashlane. All rights reserved.
//

import Foundation

public protocol DomainParserProtocol {
    func parse(host: String) -> ParsedHost?
}

public struct FakeDomainParser: DomainParserProtocol {
    public init(){}
    public func parse(host: String) -> ParsedHost? {
        return nil
    }
}
