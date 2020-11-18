//
//  String+Localization.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 18/11/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
