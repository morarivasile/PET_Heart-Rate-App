//
//  HeartRateViewController.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 17/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit
import AVFoundation
import Charts

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
    
    @IBOutlet weak private var progressView: UIProgressView!
    
    @IBOutlet weak private var actionButton: CameraButton!
    
    // MARK: - Public Properties
    
    var presenter: HeartRatePresenterProtocol?
    
    var state: HeartRateViewState = .stopped {
        didSet { updateView() }
    }
    
    // MARK: - VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Camera"
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
        switch state {
        case .started:
            hintLabel.isHidden = false
            hintLabel.text = "To start counting the heart rate place lightly the finger tip on camera lens"
            actionButton.cameraState = .started
            
            setFingerDetectionProgress(0.0, animated: false)
            setPulseDetectionProgress(0.0, animated: false)
        case .stopped:
            hintLabel.isHidden = true
            actionButton.cameraState = .stopped
            
            setFingerDetectionProgress(0.0, animated: false)
            setPulseDetectionProgress(0.0, animated: false)
        case .detectingFinger:
            hintLabel.isHidden = false
            hintLabel.text = "Detecting your pulse, please wait..."
            actionButton.cameraState = .started
        case .detectingPulse:
            hintLabel.isHidden = false
            hintLabel.text = "Counting heart rate, please keep holding the finger on camera lens"
            actionButton.cameraState = .started
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
}
