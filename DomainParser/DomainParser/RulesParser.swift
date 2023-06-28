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
    func parse(raw: Data, sortRules: Bool) throws -> ParsedRules {
        guard let rulesText = String(data: raw, encoding: .utf8) else {
            throw DomainParserError.ruleParsingError(message: "Can't parse rules data. Is it in UTF-8 format?")
        }

        let allRules = rulesText.split(separator: "\n")
        try allRules.forEach(parseRule)

        if (sortRules) {
            // Sort the collections from big to small so that the highest priority rules are first.
            self.wildcardRules = self.wildcardRules.mapValues { (rules: [Rule]) in
                rules.sorted(by: { $0 > $1 })
            }
            self.exceptions = self.exceptions.mapValues { (rules: [Rule]) in
                rules.sorted(by: { $0 > $1 })
            }
        }

        return ParsedRules.init(exceptions: self.exceptions,
                                wildcardRules: self.wildcardRules,
                                basicRules: self.basicRules)
    }

    private func parseRule(line: Substring) throws {
        if line.contains("*") {
            let rule = Rule(raw: line)

            guard case .text(let lastLabelText) = rule.parts.last else {
                let msg = "Last label of PSL rule must be text (Rule: \(line))"
                throw DomainParserError.ruleParsingError(message: msg)
            }

            self.wildcardRules[lastLabelText, default: []].append(rule)

        } else if line.starts(with: "!") {
            let rule = Rule(raw: line)

            guard case .text(let lastLabelText) = rule.parts.last else {
                let msg = "Last label of PSL rule must be text (Rule: \(line))"
                throw DomainParserError.ruleParsingError(message: msg)
            }

            self.exceptions[lastLabelText, default: []].append(rule)

        } else {
            self.basicRules.insert(String(line))
        }
    }
}
