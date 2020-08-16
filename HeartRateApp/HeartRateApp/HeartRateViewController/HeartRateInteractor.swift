//
//  HeartRateInteractor.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 28/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

final class HeartRateInteractor {
    
    // MARK: - Managers
    
    private var sessionManager: VideoSessionManagerProtocol
    private let torchManager: TorchManagerProtocol
    
    private lazy var peakDetector: PeakDetector = {
        let detector = PeakDetector()
        detector.delegate = self
        return detector
    }()
    
    // MARK: - Timers
    
    private lazy var fingerDetectionTimer: RepeatingTimerWrapperProtocol = RepeatingTimerWrapper(
        timeInterval: tickTimeInterval,
        totalCount: fingerTimerTotalInterval,
        delegate: self
    )
    
    private lazy var pulseDetectionTimer: RepeatingTimerWrapperProtocol = RepeatingTimerWrapper(
        timeInterval: tickTimeInterval,
        totalCount: pulseTimerTotalInterval,
        delegate: self
    )
    
    private lazy var vibrationTimer: RepeatingTimerWrapperProtocol = RepeatingTimerWrapper(
        timeInterval: 2.0,
        totalCount: pulseTimerTotalInterval,
        delegate: self
    )
    
    // MARK: - Value holders
    
    private var _isFingerDetected: Bool = false
    
    private let fingerTimerTotalInterval: TimeInterval
    
    private let pulseTimerTotalInterval: TimeInterval
    
    private let tickTimeInterval: TimeInterval
    
    private var pulseValues: [CGFloat] = [] {
        didSet {
            if !(oldValue.isEmpty && pulseValues.isEmpty) {
                output?.didChangePulseValues(pulseValues)
            }
        }
    }
    
    // MARK: - Delegates
    
    weak var output: HeartRateInteractorOutputProtocol?
    
    // MARK: - Initializers
    
    init(sessionManager: VideoSessionManagerProtocol, torchManager: TorchManagerProtocol, fingerTimerTotalInterval: TimeInterval = 3.0, pulseTimerTotalInterval: TimeInterval = 10.0, tickTimeInterval: TimeInterval = 0.1) {
        self.sessionManager = sessionManager
        self.torchManager = torchManager
        
        self.fingerTimerTotalInterval = fingerTimerTotalInterval
        self.pulseTimerTotalInterval = pulseTimerTotalInterval
        self.tickTimeInterval = tickTimeInterval
        
        self.sessionManager.delegate = self
    }
}

// MARK: - Private
extension HeartRateInteractor {
    
    private func stopFingerDetectionTimer(isFingerDetected: Bool) {
        fingerDetectionTimer.stop()
        _isFingerDetected = isFingerDetected
    }
    
    private func stopPulseDetectionTimer() {
        pulseDetectionTimer.stop()
        vibrationTimer.stop()
    }
}

extension HeartRateInteractor: HeartRateInteractorProtocol {
    
    var isDetectingFinger: Bool {
        return fingerDetectionTimer.isStarted
    }
    
    var isDetectingPulse: Bool {
        return pulseDetectionTimer.isStarted
    }
    
    var isFingerDetected: Bool {
        return _isFingerDetected
    }
    
    var isCameraStarted: Bool {
        return sessionManager.isSessionRunning
    }
    
    func startDetection(completion: ((Bool) -> Void)?) {
        sessionManager.startSession { (started) in
            if started {
                try? self.torchManager.toggleTorch(on: true)
            }
            
            self.output?.didChangeState(started ? .started : .stopped)
            
            completion?(started)
        }
    }
    
    func stopDetection(completion: (() -> Void)?) {
        sessionManager.stopSession {
            try? self.torchManager.toggleTorch(on: false)
            
            // Stop timers
            self.stopFingerDetectionTimer(isFingerDetected: false)
            self.stopPulseDetectionTimer()
            
            self.output?.didChangeState(.stopped)
            
            completion?()
        }
    }
}

// MARK: - VideoSessionManagerDelegate
extension HeartRateInteractor: VideoSessionManagerDelegate {
    func sessionManager(_ sessionManager: VideoSessionManager, didOutput pixelBuffer: CVPixelBuffer) {
        guard let imageAverageColor = pixelBuffer.averageColor else { return }
        
        if imageAverageColor.isFingerOnLense {
            if !fingerDetectionTimer.isStarted && !isFingerDetected {
                fingerDetectionTimer.start()
                output?.didChangeState(.detectingFinger)
            }
        } else {
            stopFingerDetectionTimer(isFingerDetected: false)
            stopPulseDetectionTimer()
            output?.didChangeState(.started)
        }
        
        if isDetectingPulse {
            pulseValues.append(imageAverageColor.luminance)
            
            peakDetector.addValueToAnalyze(Double(imageAverageColor.luminance))
        } else {
            pulseValues = []
        }
    }
}

// MARK: - RepeatingTimerWrapperDelegate
extension HeartRateInteractor: RepeatingTimerWrapperDelegate {
    func didFinishCounting(_ timer: RepeatingTimerWrapperProtocol) {
        switch timer.identifier {
        case fingerDetectionTimer.identifier:
            stopFingerDetectionTimer(isFingerDetected: true)
            pulseDetectionTimer.start()
            vibrationTimer.start()
            output?.didChangeState(.detectingPulse)
        case pulseDetectionTimer.identifier:
            stopPulseDetectionTimer()
            output?.didChangeState(.started)
        default:
            return
        }
    }
    
    func didIterate(interval: TimeInterval, timer: RepeatingTimerWrapperProtocol) {
        switch timer.identifier {
        case fingerDetectionTimer.identifier:
            output?.didChangeFingerDetectionProgress(Float(interval / fingerTimerTotalInterval))
        case pulseDetectionTimer.identifier:
            output?.didChangePulseDetectionProgress(Float(interval / pulseTimerTotalInterval))
        case vibrationTimer.identifier:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        default:
            return
        }
    }
}

// MARK: - PeakDetectorDelegate
extension HeartRateInteractor: PeakDetectorDelegate {
    func peakDetector(_ detector: PeakDetector, didDetectPeakOfValue peakValue: Double, peakJump: Double) {
        
    }
    
    func peakDetector(_ detector: PeakDetector, didPerceiveHeartRate heartRate: Double) {
        output?.didChangeHeartRate(heartRate)
    }
}
