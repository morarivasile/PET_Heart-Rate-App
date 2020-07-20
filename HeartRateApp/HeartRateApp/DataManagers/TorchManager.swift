//
//  TorchManager.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 17/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import AVFoundation

protocol TorchManagerProtocol {
    var isTorchEnabled: Bool { get }
    
    func toggleTorch(on: Bool) throws
}

final class TorchManager: TorchManagerProtocol {
    
    private var device: AVCaptureDevice?
    
    var isTorchEnabled: Bool {
        return device?.torchMode == .on
    }
    
    init(device: AVCaptureDevice) {
        self.device = device
    }
    
    init() {
        self.device = AVCaptureDevice.default(for: .video)
    }
    
    func toggleTorch(on: Bool) throws {
        guard let device = device else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                throw ToggleError.torchCouldNotBeUsed
            }
        } else {
            throw ToggleError.torchNotAvailable
        }
    }
    
    enum ToggleError: Error, LocalizedError {
        case torchNotAvailable
        case torchCouldNotBeUsed
        
        var errorDescription: String? {
            switch self {
            case .torchNotAvailable: return "Torch is not available"
            case .torchCouldNotBeUsed: return "Torch could not be used"
            }
        }
    }
}
