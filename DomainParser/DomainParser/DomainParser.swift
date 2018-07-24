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
public struct DomainParser {
    private let rules: [Rule]

    /// Parse the `public_suffix_list` file and build the set of Rules
    public init() throws {
        let url = Bundle.current.url(forResource: "public_suffix_list", withExtension: "dat")!
        let data = try Data(contentsOf: url)
        rules = try RulesParser.parse(raw: data)
    }

    public func parse(host: String) -> ParsedHost? {
        let hostComponents = host.components(separatedBy: ".")
        let rule = rules.first { $0.isMatching(hostLabels: hostComponents) }
        return rule?.parse(hostLabels: hostComponents)
    }
}

private extension Bundle {

    static var current: Bundle {
        class ClassInCurrentBundle {}
        return Bundle.init(for: ClassInCurrentBundle.self)
    }
}

/// Helper
private struct RulesParser {

    /// Parse the Data to extract an array of Rules. The array is sorted by importance.
    static func parse(raw: Data) throws -> [Rule] {
        guard let rulesText = String(data: raw, encoding: .utf8) else {
            throw DomainParserError.parsingError(details: nil)
        }
        return rulesText
            .components(separatedBy: .newlines)
            .compactMap(parseRule)
            .sorted()
            .reversed()
    }

    private static func parseRule(line: String) -> Rule? {
        /// From `publicsuffix.org/list/` Each line is only read up to the first whitespace; entire lines can also be commented using //.
        guard let trimmedLine = line.components(separatedBy: .whitespaces).first,
            !trimmedLine.isComment && !trimmedLine.isEmpty else { return nil }
        return Rule(raw: trimmedLine)

    }
}

private extension String {

    /// A line starting by "//" is a comment and should be ignored
    var isComment: Bool {
        return self.starts(with: C.commentMarker)
    }
}
