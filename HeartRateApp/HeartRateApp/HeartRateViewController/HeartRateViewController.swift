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

final class HeartRateViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak private var hintLabel: UILabel!
    
    @IBOutlet weak private var progressView: UIProgressView!
    
    @IBOutlet weak private var actionButton: CameraButton!
    
    // MARK: - Public Properties
    
    var presenter: HeartRatePresenterProtocol?
    
    // MARK: - VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Camera"
    }
    
    // MARK: - IBActions
    
    @IBAction func didTapOnCameraButton(_ sender: UIButton) {
        presenter?.didTapActionButton()
    }
}

// MARK: - HeartRateViewProtocol
extension HeartRateViewController: HeartRateViewProtocol {
    func updateView(isCameraStarted: Bool) {
        actionButton.cameraState = isCameraStarted ? .started : .stopped
        hintLabel.isHidden = !isCameraStarted
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
