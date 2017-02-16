//
//  String+Alphanumeric.swift
//  LevelDesigner
//
//  Created by Edmund Mok on 2/2/17.
//  Copyright © 2017 nus.cs3217.a0101010. All rights reserved.
//

import Foundation

/**
 This extension for String provides an isAlphanumeric
 computed property to check if the string is alphanumeric or not.
 */
extension String {

    var isAlphanumeric: Bool {
        // non-empty and is alphanumeric
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

}
