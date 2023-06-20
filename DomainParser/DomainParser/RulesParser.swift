//
//  RulesParser.swift
//  DomainParser
//
//  Created by Jason Akakpo on 04/09/2018.
//  Copyright © 2018 Dashlane. All rights reserved.
//

import Foundation


struct ParsedRules {
    let exceptions: Dictionary<String, Array<Rule>>
    let wildcardRules: Dictionary<String, Array<Rule>>
    let basicRules: Set<String>
}

class RulesParser {
    
    var exceptions = Dictionary<String, Array<Rule>>()
    var wildcardRules = Dictionary<String, Array<Rule>>()
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
        let ruleComparator = { (r1: Rule, r2: Rule) -> Bool in r1 > r2 }
        let sortRulesTransform = { (rules: Array<Rule>) -> Array<Rule> in rules.sorted(by: ruleComparator) }
        self.wildcardRules = self.wildcardRules.mapValues(sortRulesTransform)
        self.exceptions = self.exceptions.mapValues(sortRulesTransform)

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
