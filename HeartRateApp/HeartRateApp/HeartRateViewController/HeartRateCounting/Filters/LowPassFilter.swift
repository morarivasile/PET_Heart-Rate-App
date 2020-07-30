//
//  LowPassFilter.swift
//  PulseCounting
//
//  Created by Vasile Morari on 30/07/2020.
//

import Foundation

struct LowPassFilter: Filter {
    private(set) var value: Double
    
    private(set)var filterFactor: Double
    
    init(value: Double, filterFactor: Double) {
        self.value = value
        self.filterFactor = filterFactor
    }
    
    init(value: Double = 0.0, samepleRate: Double, cutoffFrequency: Double) {
        let dt = 1.0 / samepleRate
        let RC = 1.0 / cutoffFrequency
        
        self.value = value
        self.filterFactor = dt / (dt + RC)
    }
    
    mutating func update(newValue: Double) {
        value = value * filterFactor + newValue * (1.0 - filterFactor)
    }
}
