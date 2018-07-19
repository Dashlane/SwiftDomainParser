//
//  RuleLabel.swift
//  DomainParser
//
//  Created by Jason Akakpo on 19/07/2018.
//  Copyright © 2018 Dashlane. All rights reserved.
//

import Foundation

/// There is two kind of labels in a rule, wildcard and text
enum RuleLabel {
    case text(String)
    case wildcard

    init(fromComponent component: String) {
        self =  component == Constant.wildcardComponent ? .wildcard : .text(component)
    }

    /// Return true if self matches the given label
    func isMatching(label: String) -> Bool {
        switch self {
        case let .text(text):
            return text == label
        case .wildcard:
            return true
        }
    }
}
