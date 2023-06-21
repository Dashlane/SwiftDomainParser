//
//  RulesParser.swift
//  DomainParser
//
//  Created by Jason Akakpo on 04/09/2018.
//  Copyright © 2018 Dashlane. All rights reserved.
//

import Foundation


struct ParsedRules {
    /// Dictionary of rule arrays indexed by the last label of a rule.
    let exceptions: [String: [Rule]]
    /// Dictionary of rule arrays indexed by the last label of a rule.
    let wildcardRules: [String: [Rule]]
    /// Set of suffixes
    let basicRules: Set<String>
}

class RulesParser {

    /// Dictionary of rule arrays indexed by the last label of a rule.
    var exceptions = [String: [Rule]]()
    /// Dictionary of rule arrays indexed by the last label of a rule.
    var wildcardRules = [String: [Rule]]()
    /// Set of suffixes
    var basicRules = Set<String>()
    
    /// Parse the Data to extract an array of Rules. The array is sorted by importance.
    func parse(raw: Data) throws -> ParsedRules {
        guard let rulesText = String(data: raw, encoding: .utf8) else {
            throw DomainParserError.parsingError(details: nil)
        }
        rulesText
            .split(separator: "\n")
            .forEach(parseRule)

        // Sort the collections from big to small so that the highest priority rules are first.
        self.wildcardRules = self.wildcardRules.mapValues { (rules: [Rule]) in
            rules.sorted(by: { $0 > $1 })
        }
        self.exceptions = self.exceptions.mapValues { (rules: [Rule]) in
            rules.sorted(by: { $0 > $1 })
        }

        return ParsedRules.init(exceptions: exceptions,
                                wildcardRules: wildcardRules,
                                basicRules: basicRules)
    }

    private func parseRule(line: Substring) {
        if line.contains("*") {
            let rule = Rule(raw: line)
            wildcardRules[rule.getLastLabel(), default: []].append(rule)
        } else if line.starts(with: "!") {
            let rule = Rule(raw: line)
            exceptions[rule.getLastLabel(), default: []].append(rule)
        } else {
            basicRules.insert(String(line))
        }
    }
}
