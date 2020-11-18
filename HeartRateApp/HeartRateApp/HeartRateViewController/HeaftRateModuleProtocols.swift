//
//  HeaftRateModuleProtocols.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 17/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit

protocol HeartRateViewProtocol: class {
    var state: HeartRateViewState { get set }
    
    func setActionButtonInteraction(_ isEnabled: Bool)
    
    func setFingerDetectionProgress(_ progress: Float, animated: Bool)
    func setPulseDetectionProgress(_ progress: Float, animated: Bool)
    func updateChart(values: [CGFloat])
    func updateHeartRateLabel(_ rate: String)
}

protocol HeartRatePresenterProtocol: class {
    func didTapActionButton()
}

protocol HeartRateInteractorProtocol: class {
    var isDetectingPulse: Bool { get }
    var isDetectingFinger: Bool { get }
    var isFingerDetected: Bool { get }
    var isCameraStarted: Bool { get }
    
    func startDetection(completion: ((Bool) -> Void)?)
    func stopDetection(completion: (() -> Void)?)
}

protocol HeartRateInteractorOutputProtocol: class {
    func didChangeState(_ state: HeartRateViewState)
    func didChangeFingerDetectionProgress(_ progress: Float)
    func didChangePulseDetectionProgress(_ progress: Float)
    func didChangePulseValues(_ values: [CGFloat])
    func didChangeHeartRate(_ heartRate: Double)
    func didHitVibrationTimer()
}
