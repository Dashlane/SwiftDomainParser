//
//  BasicDomainParser.swift
//  DomainParser
//
//  Created by Jason Akakpo on 04/09/2018.
//  Copyright © 2018 Dashlane. All rights reserved.
//

import Foundation


/// This class can parse a hostname only according to basic suffix rules (no wildcards or exceptions).
/// Examples of valid rules: **com**, **co.uk**, **ide.kyoto.jp**
public struct BasicDomainParser: DomainParserProtocol {
    
    let suffixes: Set<String>
    init(suffixes: Set<String>) {
        self.suffixes = suffixes
    }

    public func parse(host: String) -> ParsedHost? {
        let lowercasedHost = host.lowercased()
        let hostComponents = lowercasedHost.split(separator: ".")
        var hostSlices = ArraySlice(hostComponents)
        
        var candidateSuffix = ""
        
        /// Check if the host ends with a suffix in the set
        /// For instance for : api.dashlane.co.uk
        /// First check if dashlane.co.uk is a known suffix, if not check if co.uk is, etc
        repeat {
            guard !hostSlices.isEmpty else { return nil }
            candidateSuffix = hostSlices.joined(separator: ".")
            hostSlices = hostSlices.dropFirst()
        } while !suffixes.contains(candidateSuffix)
        
        /// The domain is the suffix with one more component
        let domainRange = (hostSlices.startIndex - 2)..<hostComponents.endIndex
        let domain = domainRange.startIndex >= 0 ? hostComponents[domainRange].joined(separator: ".") : nil
        return ParsedHost(publicSuffix: candidateSuffix,
                          domain: domain)
    }
}
