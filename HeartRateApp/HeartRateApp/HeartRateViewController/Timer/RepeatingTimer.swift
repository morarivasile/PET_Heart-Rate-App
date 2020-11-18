//
//  RepeatingTimer.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 22/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import Foundation

class RepeatingTimer {
    
    var timeInterval: TimeInterval
    
    private var timer: DispatchSourceTimer?
    
    var eventHandler: (() -> Void)?
    
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    deinit {
        timer = nil
    }
    
    func start() {
        timer = initTimer()
        timer?.resume()
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
    }
    
    private func initTimer() -> DispatchSourceTimer {
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now(), repeating: timeInterval)
        t.setEventHandler(handler: eventHandler)
        return t
    }
}
