//
//  HeartRatePresenter.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 17/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

final class HeartRatePresenter {
    
    private var sessionManager: VideoSessionManagerProtocol
    private let torchManager: TorchManagerProtocol
    
    private lazy var lenseDetectionTimer: RepeatingTimerWrapperProtocol = RepeatingTimerWrapper(
        timeInterval: 0.01,
        totalCount: Constants.lenseTimerTotalInterval,
        delegate: self,
        runAction: lenseDetectionTimerAction
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
    private func lenseDetectionTimerAction(time: TimeInterval) {
        DispatchQueue.main.async {
            self.view?.setProgress(Float(time / Constants.lenseTimerTotalInterval), animated: true)
        }
    }
    
    private func stopLenseDetectionTimer(isFingerDetected: Bool) {
        self.lenseDetectionTimer.stop()
        self.isFingerDetected = isFingerDetected
        
        DispatchQueue.main.async {
            self.view?.setProgress(0.0, animated: true)
        }
    }
}

// MARK: - HeartRatePresenterProtocol
extension HeartRatePresenter: HeartRatePresenterProtocol {
    func didTapActionButton() {
        if sessionManager.isSessionRunning {
            sessionManager.stopSession()
            try? torchManager.toggleTorch(on: false)
            self.view?.updateView(isCameraStarted: false)
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
        guard let image = UIImage(pixelBuffer: pixelBuffer) else { return }
        guard let imageAverageColor = image.averageColor else { return }
        
        if imageAverageColor.isFingerOnLense {
            if !lenseDetectionTimer.isStarted && !isFingerDetected {
                lenseDetectionTimer.start()
            }
        } else {
            stopLenseDetectionTimer(isFingerDetected: false)
        }
    }
}

// MARK: - CustomTimerDelegate
extension HeartRatePresenter: RepeatingTimerWrapperDelegate {
    func didFinishCounting(_ timer: RepeatingTimerWrapperProtocol) {
        stopLenseDetectionTimer(isFingerDetected: true)
    }
}

// MARK: - Constants
extension HeartRatePresenter {
    enum Constants {
        static let lenseTimerTotalInterval: TimeInterval = 3.0
    }
}
