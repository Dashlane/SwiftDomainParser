//
//  DomainParser.swift
//  DomainParser
//
//  Created by Jason Akakpo on 19/07/2018.
//  Copyright © 2018 Dashlane. All rights reserved.
//

import Foundation

enum DomainParserError: Error {
    case parsingError(details: Error?)
}

/// Uses the public suffix list
public struct DomainParser: DomainParserProtocol {
    
    let parsedRules: ParsedRules
    
    let onlyBasicRules: Bool
    
    let basicDomainParser: BasicDomainParser
    
    /// Parse the `public_suffix_list` file and build the set of Rules
    /// Parameters:
    ///   - QuickParsing: IF true, the `exception` and `wildcard` rules will be ignored
    public init(quickParsing: Bool = false) throws {
        let url = Bundle.current.url(forResource: "public_suffix_list", withExtension: "dat")!
        let data = try Data(contentsOf: url)
        
        try self.init(rulesData: data, quickParsing: quickParsing)
    }

    init(rulesData: Data, quickParsing: Bool = false) throws {
        parsedRules = try RulesParser().parse(raw: rulesData)
        basicDomainParser = BasicDomainParser(suffixes: parsedRules.basicRules)
        onlyBasicRules = quickParsing
    }

    public func parse(host: String) -> ParsedHost? {
        if onlyBasicRules {
            return basicDomainParser.parse(host: host)
        } else {
            return parseExceptionsAndWildCardRules(host: host) ?? basicDomainParser.parse(host: host)
        }
     }
    
    func parseExceptionsAndWildCardRules(host: String) -> ParsedHost? {
        let hostComponents = host.split(separator: ".")
        guard let lastLabelSubstring = hostComponents.last else {
            return nil
        }

        let lastLabel = String(lastLabelSubstring)
        var wildcardRulesForLabel: [Rule] = []
        wildcardRulesForLabel.append(contentsOf: parsedRules.wildcardRules[lastLabel] ?? [])
        wildcardRulesForLabel.append(contentsOf: parsedRules.wildcardRules["*"] ?? [])
        wildcardRulesForLabel.sort(by: { $0 > $1 })

        let isMatching: (Rule) -> Bool = { $0.isMatching(hostLabels: hostComponents) }
        let rule = parsedRules.exceptions[lastLabel]?.first(where: isMatching) ??
                   wildcardRulesForLabel.first(where: isMatching)

        return rule?.parse(hostLabels: hostComponents)
    }
}

private extension Bundle {

    static var current: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        class ClassInCurrentBundle {}
        return Bundle.init(for: ClassInCurrentBundle.self)
        #endif
    }
}
