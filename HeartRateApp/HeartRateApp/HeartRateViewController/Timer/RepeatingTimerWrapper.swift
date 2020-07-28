//
//  RepeatingTimerWrapper.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 22/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import Foundation

protocol RepeatingTimerWrapperDelegate: class {
    func didIterate(interval: TimeInterval, timer: RepeatingTimerWrapperProtocol)
    func didFinishCounting(_ timer: RepeatingTimerWrapperProtocol)
}

protocol RepeatingTimerWrapperProtocol: Identifiable {
    var isStarted: Bool { get }
    
    func start()
    func stop()
}

final class RepeatingTimerWrapper: RepeatingTimerWrapperProtocol {
    
    typealias RunAction = (TimeInterval) -> Void
    
    private(set) lazy var timer: RepeatingTimer = RepeatingTimer(timeInterval: timeInterval)
    
    private(set) var totalCount: TimeInterval
    
    private(set) var timeInterval: TimeInterval
    
    private(set) var runCount: TimeInterval = 0
    
    var identifier: UUID = UUID()
    
    var isStarted: Bool {
        return runCount != 0
    }
    
    weak var delegate: RepeatingTimerWrapperDelegate?
    
    init(timeInterval: TimeInterval = 1.0, totalCount: TimeInterval, delegate: RepeatingTimerWrapperDelegate? = nil) {
        self.totalCount = totalCount
        self.delegate = delegate
        self.timeInterval = timeInterval
        
        self.timer.eventHandler = runTimerAction
    }
    
    func start() {
        runCount = 0
        timer.resume()
    }
    
    func stop() {
        runCount = 0
        timer.suspend()
    }
    
    private func runTimerAction() {
        runCount += timeInterval
        if runCount >= totalCount {
            delegate?.didFinishCounting(self)
            stop()
        }
        
        delegate?.didIterate(interval: runCount, timer: self)
    }
}
