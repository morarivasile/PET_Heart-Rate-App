//
//  Identifiable.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 28/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import Foundation

protocol Identifiable {
    var identifier: UUID { get set }
}
