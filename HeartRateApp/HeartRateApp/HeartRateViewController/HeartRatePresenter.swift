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
    
    private var sessionManager: VideoSessionManagerProtocol
    private let torchManager: TorchManagerProtocol
    
    private lazy var fingerDetectionTimer: RepeatingTimerWrapperProtocol = RepeatingTimerWrapper(
        timeInterval: Constants.tickTimeInterval,
        totalCount: Constants.fingerTimerTotalInterval,
        delegate: self,
        runAction: fingerDetectionTimerAction
    )
    
    private lazy var pulseDetectionTimer: RepeatingTimerWrapperProtocol = RepeatingTimerWrapper(
        timeInterval: Constants.tickTimeInterval,
        totalCount: Constants.pulseTimerTotalIntervale,
        delegate: self,
        runAction: pulseDetectionTimerAction
    )
    
    private var isFingerDetected: Bool = false
    
    weak var view: HeartRateViewProtocol?
    
    init(sessionManager: VideoSessionManagerProtocol, torchManager: TorchManagerProtocol) {
        self.sessionManager = sessionManager
        self.torchManager = torchManager
        
        self.sessionManager.delegate = self
    }
}

// MARK: - Private
extension HeartRatePresenter {
    private func fingerDetectionTimerAction(time: TimeInterval) {
        DispatchQueue.main.async {
            self.view?.setFingerDetectionProgress(Float(time / Constants.fingerTimerTotalInterval), animated: false)
        }
    }
    
    private func pulseDetectionTimerAction(time: TimeInterval) {
        DispatchQueue.main.async {
            self.view?.setPulseDetectionProgress(Float(time / Constants.pulseTimerTotalIntervale), animated: false)
        }
    }
    
    private func stopFingerDetectionTimer(isFingerDetected: Bool) {
        self.fingerDetectionTimer.stop()
        self.isFingerDetected = isFingerDetected
        
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
        
        if pulseDetectionTimer.isStarted {
            // Get colors
        }
    }
}

// MARK: - CustomTimerDelegate
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
}

// MARK: - Constants
extension HeartRatePresenter {
    enum Constants {
        static let fingerTimerTotalInterval: TimeInterval = 3.0
        static let pulseTimerTotalIntervale: TimeInterval = 10.0
        static let tickTimeInterval: TimeInterval = 0.01
    }
}
