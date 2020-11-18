//
//  HeartRateViewController.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 17/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit
import AVFoundation

enum HeartRateViewState {
    case started
    case stopped
    case detectingFinger
    case detectingPulse
}

final class HeartRateViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak private var hintLabel: UILabel!
    
    @IBOutlet weak private var heartBeatRateLabel: UILabel!
    
    @IBOutlet weak private var progressView: UIProgressView!
    
    @IBOutlet weak private var actionButton: CameraButton!
    
    @IBOutlet weak private var graphView: GraphView! {
        didSet {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            
            graphView.viewType = .year
            
            graphView.inputData = [
                (formatter.date(from: "10/06/2020"), 50),
                (formatter.date(from: "16/03/2020"), 70),
                (formatter.date(from: "18/09/2020"), 40),
                (formatter.date(from: "18/10/2020"), 110),
                (formatter.date(from: "13/11/2020"), 30)
            ].compactMap { GraphView.InputData(date: $0.0!, value: $0.1)}
        }
    }
    
    // MARK: - Public Properties
    
    var presenter: HeartRatePresenterProtocol?
    
    var state: HeartRateViewState = .stopped {
        didSet { updateView() }
    }

    // MARK: - Private Properties
    
    private var hint: String? {
        switch state {
        case .started:
            return "HeartRateControllerStartedText".localized
        case .stopped:
            return nil
        case .detectingFinger:
            return "HeartRateControllerDetectingFingerText".localized
        case .detectingPulse:
            return "HeartRateControllerDetectingPulseText".localized
        }
    }
    
    private var actionButtonState: CameraButton.CameraState {
        switch state {
        case .started, .detectingFinger, .detectingPulse:
            return .started
        case .stopped:
            return .stopped
        }
    }
    
    // MARK: - VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "HeartRateControllerTitle".localized
        updateView()
    }
    
    // MARK: - IBActions
    
    @IBAction func didTapOnCameraButton(_ sender: UIButton) {
        presenter?.didTapActionButton()
    }
}

// MARK: - Private
extension HeartRateViewController {
    private func updateView() {
        
        hintLabel.text = hint
        hintLabel.isHidden = hint == nil
        
        actionButton.cameraState = actionButtonState
        
        switch state {
        case .started, .stopped:
            setFingerDetectionProgress(0.0, animated: false)
            setPulseDetectionProgress(0.0, animated: false)
        default: break
        }
    }
}

// MARK: - HeartRateViewProtocol
extension HeartRateViewController: HeartRateViewProtocol {
    func setActionButtonInteraction(_ isEnabled: Bool) {
        actionButton.isEnabled = isEnabled
    }
    
    func setFingerDetectionProgress(_ progress: Float, animated: Bool) {
        progressView.progressTintColor = .systemIndigo
        progressView.setProgress(progress, animated: animated)
    }
    
    func setPulseDetectionProgress(_ progress: Float, animated: Bool) {
        progressView.progressTintColor = .systemPink
        progressView.setProgress(progress, animated: animated)
    }
    
    func updateChart(values: [CGFloat]) {
        
    }
    
    func updateHeartRateLabel(_ rate: String) {
        heartBeatRateLabel.text = "\(rate) 🖤"
    }
}
