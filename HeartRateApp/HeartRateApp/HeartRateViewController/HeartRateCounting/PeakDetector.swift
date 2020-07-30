//
//  PeakDetector.swift
//  PulseCounting
//
//  Created by Vasile Morari on 30/07/2020.
//

import Foundation

protocol PeakDetectorDelegate: class {
    func peakDetector(_ detector: PeakDetector, didDetectPeakOfValue peakValue: Double, peakJump: Double)
    func peakDetector(_ detector: PeakDetector, didPerceiveHeartRate heartRate: Double)
}

final class PeakDetector {
    
    private var noiseFilter: LowPassFilter = LowPassFilter(samepleRate: 120, cutoffFrequency: 45)
    private var middleFilter: LowPassFilter = LowPassFilter(samepleRate: 120, cutoffFrequency: 15)
    private var shiftFilter: HighPassFilter = HighPassFilter(sampleRate: 120, cutoffFrequency: 20)
    
    private var isOver: Bool = false
    private var isBelow: Bool = true
    private var isCollectingHistory: Bool = true
    
    private var intervals: [Double] = []
    private var lastInterval: TimeInterval = 0.0
    private var lastPeakDate: Date?
    
    
    weak var delegate: PeakDetectorDelegate?
    
    func addValueToAnalyze(_ value: Double) {
        shiftFilter.update(newValue: value)
        noiseFilter.update(newValue: value)
        middleFilter.update(newValue: value)
        
        if noiseFilter.value > middleFilter.value && isBelow {
            
            collectHistory()
            
            let peakJumpValue: Double = noiseFilter.value - middleFilter.value
            
            delegate?.peakDetector(self, didDetectPeakOfValue: value, peakJump: peakJumpValue)
            
            isOver = true
            isBelow = false
        }
        
        if noiseFilter.value < middleFilter.value, isOver {
            isBelow = true
            isOver = false
        }
    }
}

// MARK: - Private
extension PeakDetector {
    
    private func collectHistory() {
        
        if let lastPeakDate = lastPeakDate, isCollectingHistory {
            let currentInterval = abs(lastPeakDate.timeIntervalSinceNow)
            
            let percentDifference = percentOfDifferenceBetween(
                firstArg: lastInterval,
                secondArg: currentInterval
            )
            
            if percentDifference < Constants.maxPercentOfDifference {
                intervals.append(currentInterval)
            } else {
                intervals.removeAll()
            }
            
            lastInterval = currentInterval
            
            if intervals.count == Constants.intervalsToAnalyze {
                isCollectingHistory = false
                analyzeHistory()
                return
            }
        }
        
        lastPeakDate = Date()
    }
    
    private func analyzeHistory() {
        let sum = intervals.reduce(0, +)
        let timerForBeat = sum / Double(Constants.intervalsToAnalyze)
        let beatsPerMinute = 60.0 / timerForBeat
        
        if beatsPerMinute > Constants.minPossibleRate || beatsPerMinute < Constants.maxPossibleRate {
            delegate?.peakDetector(self, didPerceiveHeartRate: beatsPerMinute)
        }
        
        isCollectingHistory = true
        intervals.removeAll()
    }
    
    private func percentOfDifferenceBetween(firstArg: Double, secondArg: Double) -> Double {
        let absVariance = abs(firstArg - secondArg)
        return (absVariance * 100) / firstArg
    }
    
}

extension PeakDetector {
    enum Constants {
        static let maxPercentOfDifference: Double = 25.0
        static let minPossibleRate: Double = 25.0
        static let maxPossibleRate: Double = 200.0
        static let intervalsToAnalyze: Int = 2
    }
}
