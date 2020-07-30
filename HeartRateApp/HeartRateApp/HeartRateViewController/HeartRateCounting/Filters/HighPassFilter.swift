//
//  HighPassFilter.swift
//  PulseCounting
//
//  Created by Vasile Morari on 30/07/2020.
//

import Foundation

struct HighPassFilter: Filter {
    private(set) var value: Double
    
    private(set)var filterFactor: Double
    
    private(set) var lastValue: Double = 0.0
    
    init(value: Double = 0.0, filterFactor: Double) {
        self.value = value
        self.filterFactor = filterFactor
    }
    
    init(value: Double = 0.0, sampleRate: Double, cutoffFrequency: Double) {
        let dt = 1.0 / sampleRate
        let RC = 1.0 / cutoffFrequency
        
        self.value = value
        self.filterFactor = RC / (dt + RC)
    }
    
    mutating func update(newValue: Double) {
        value = filterFactor * (newValue + value - lastValue)
        lastValue = newValue
    }
}
