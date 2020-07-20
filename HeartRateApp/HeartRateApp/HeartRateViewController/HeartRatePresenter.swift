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
    
    private var luminanceValues: [CGFloat] = []
    
    weak var view: HeartRateViewProtocol?
    
    init(sessionManager: VideoSessionManagerProtocol, torchManager: TorchManagerProtocol) {
        self.sessionManager = sessionManager
        self.torchManager = torchManager
        
        self.sessionManager.delegate = self
    }
}

// MARK: - HeartRatePresenterProtocol
extension HeartRatePresenter: HeartRatePresenterProtocol {
    func didTapActionButton() {
        if sessionManager.isSessionRunning {
            sessionManager.stopSession()
            try? torchManager.toggleTorch(on: false)
        } else {
            sessionManager.startSession { (started) in
                if started {
                    try? self.torchManager.toggleTorch(on: true)
                }
            }
        }
    }
}

// MARK: - VideoSessionManagerDelegate
extension HeartRatePresenter: VideoSessionManagerDelegate {
    func sessionManager(_ sessionManager: VideoSessionManager, didOutput pixelBuffer: CVPixelBuffer) {
        guard let image = UIImage(pixelBuffer: pixelBuffer) else { return }
        guard let imageAverageColor = image.averageColor else { return }
        
        let luminance = imageAverageColor.luminance
        
        luminanceValues.append(luminance)
        
        DispatchQueue.main.async {
            self.view?.updateGraph(with: self.luminanceValues)
        }
    }
}
