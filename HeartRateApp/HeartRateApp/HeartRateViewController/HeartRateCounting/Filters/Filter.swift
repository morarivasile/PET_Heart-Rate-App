//
//  Filter.swift
//  PulseCounting
//
//  Created by Vasile Morari on 30/07/2020.
//

import Foundation

protocol Filter {
    /// Current signal value
    var value: Double { get }
    
    /// A scaling factor in the range 0.0..<1.0 that determines
    /// how resistant the value is to change
    var filterFactor: Double { get }
    
    /// Update the value useing filterFactor to attenuate changes
    mutating func update(newValue: Double)
}

