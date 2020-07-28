//
//  HeartRatePresenter.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 17/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import Foundation
import AVFoundation

final class HeartRatePresenter {
    
    // MARK: - Get only properties
    
    var isDetectingFinger: Bool {
        return fingerDetectionTimer.isStarted
    }
    
    var isDetectingPulse: Bool {
        return pulseDetectionTimer.isStarted
    }
    
    var isFingerDetected: Bool {
        return _isFingerDetected
    }
    
    // MARK: - Managers
    
    private var sessionManager: VideoSessionManagerProtocol
    private let torchManager: TorchManagerProtocol
    
    // MARK: - Timers
    
    private lazy var fingerDetectionTimer: RepeatingTimerWrapperProtocol = RepeatingTimerWrapper(
        timeInterval: Constants.tickTimeInterval,
        totalCount: Constants.fingerTimerTotalInterval,
        delegate: self
    )
    
    private lazy var pulseDetectionTimer: RepeatingTimerWrapperProtocol = RepeatingTimerWrapper(
        timeInterval: Constants.tickTimeInterval,
        totalCount: Constants.pulseTimerTotalIntervale,
        delegate: self
    )
    
    // MARK: - Value holders
    
    private var _isFingerDetected: Bool = false
    
    // MARK: - Delegates
    
    weak var view: HeartRateViewProtocol?
    
    // MARK: - Initializers
    
    init(sessionManager: VideoSessionManagerProtocol, torchManager: TorchManagerProtocol) {
        self.sessionManager = sessionManager
        self.torchManager = torchManager
        
        self.sessionManager.delegate = self
    }
}

// MARK: - Private
extension HeartRatePresenter {
    private func stopFingerDetectionTimer(isFingerDetected: Bool) {
        fingerDetectionTimer.stop()
        _isFingerDetected = isFingerDetected
        
        DispatchQueue.main.async {
            self.view?.setFingerDetectionProgress(0.0, animated: false)
        }
    }
    
    private func stopPulseDetectionTimer() {
        self.pulseDetectionTimer.stop()
        
        DispatchQueue.main.async {
            self.view?.setPulseDetectionProgress(0.0, animated: false)
        }
    }
}

// MARK: - HeartRatePresenterProtocol
extension HeartRatePresenter: HeartRatePresenterProtocol {
    func didTapActionButton() {
        if sessionManager.isSessionRunning {
            sessionManager.stopSession()
            try? torchManager.toggleTorch(on: false)
            view?.updateView(isCameraStarted: false)
            stopFingerDetectionTimer(isFingerDetected: false)
            stopPulseDetectionTimer()
        } else {
            sessionManager.startSession { (started) in
                if started {
                    try? self.torchManager.toggleTorch(on: true)
                }
                
                self.view?.updateView(isCameraStarted: started)
            }
        }
    }
}

// MARK: - VideoSessionManagerDelegate
extension HeartRatePresenter: VideoSessionManagerDelegate {
    func sessionManager(_ sessionManager: VideoSessionManager, didOutput pixelBuffer: CVPixelBuffer) {
        guard let imageAverageColor = pixelBuffer.averageColor else { return }
        
        if imageAverageColor.isFingerOnLense {
            if !fingerDetectionTimer.isStarted && !isFingerDetected {
                fingerDetectionTimer.start()
            }
        } else {
            stopFingerDetectionTimer(isFingerDetected: false)
            stopPulseDetectionTimer()
        }
        
        if isDetectingPulse {
            // Get colors
        }
    }
}

// MARK: - RepeatingTimerWrapperDelegate
extension HeartRatePresenter: RepeatingTimerWrapperDelegate {
    func didFinishCounting(_ timer: RepeatingTimerWrapperProtocol) {
        switch timer.identifier {
        case fingerDetectionTimer.identifier:
            stopFingerDetectionTimer(isFingerDetected: true)
            pulseDetectionTimer.start()
        case pulseDetectionTimer.identifier:
            stopPulseDetectionTimer()
        default:
            return
        }
    }
    
    func didIterate(interval: TimeInterval, timer: RepeatingTimerWrapperProtocol) {
        switch timer.identifier {
        case fingerDetectionTimer.identifier:
            DispatchQueue.main.async {
                self.view?.setFingerDetectionProgress(Float(interval / Constants.fingerTimerTotalInterval), animated: false)
            }
        case pulseDetectionTimer.identifier:
            DispatchQueue.main.async {
                self.view?.setPulseDetectionProgress(Float(interval / Constants.pulseTimerTotalIntervale), animated: false)
            }
        default:
            return
        }
    }
}

// MARK: - Constants
extension HeartRatePresenter {
    enum Constants {
        static let fingerTimerTotalInterval: TimeInterval = 3.0
        static let pulseTimerTotalIntervale: TimeInterval = 10.0
        static let tickTimeInterval: TimeInterval = 0.01
    }
}
