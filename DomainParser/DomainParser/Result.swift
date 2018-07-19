//
//  Result.swift
//  DomainParser
//
//  Created by Jason Akakpo on 19/07/2018.
//  Copyright © 2018 Dashlane. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case error(Error)
}
