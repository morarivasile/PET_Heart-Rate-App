//
//  HeartRateViewController.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 17/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit
import AVFoundation

final class HeartRateViewController: UIViewController {
    
    private var torchManager: TorchManager = TorchManager()
    private var videoSessionManager: VideoSessionManager = VideoSessionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Camera"
        videoSessionManager.delegate = self
    }
    
    @IBAction func didTapOnCameraButton(_ sender: UIButton) {
        if videoSessionManager.isSessionRunning {
            videoSessionManager.stopSession()
            try? torchManager.toggleTorch(on: false)
        } else {
            videoSessionManager.startSession()
            
            videoSessionManager.startSession { (started) in
                if started {
                    try? self.torchManager.toggleTorch(on: true)
                }
            }
        }
    }
}

// MARK: - VideoSessionManagerDelegate
extension HeartRateViewController: VideoSessionManagerDelegate {
    func sessionManager(_ sessionManager: VideoSessionManager, didOutput pixelBuffer: CVPixelBuffer) {
        print("adf")
    }
}
