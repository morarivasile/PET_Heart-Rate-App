//
//  CameraButton.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 22/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit

final class CameraButton: UIButton {
    
    enum CameraState {
        case started
        case stopped
    }
    
    var cameraState: CameraState = .stopped {
        didSet { updateUI() }
    }
    
    var title: String {
        switch cameraState {
        case .started: return "STOP"
        case .stopped: return "START"
        }
    }
    
    var bgColor: UIColor {
        switch cameraState {
        case .started: return .white
        case .stopped: return .systemPink
        }
    }
    
    var titleColor: UIColor {
        switch cameraState {
        case .started: return .systemPink
        case .stopped: return .white
        }
    }
    
    var borderWidth: CGFloat {
        switch cameraState {
        case .started: return 1
        case .stopped: return 0
        }
    }
    
    var borderColor: UIColor {
        switch cameraState {
        case .started: return .systemPink
        case .stopped: return .clear
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        updateUI()
    }
    
    private func updateUI() {
        setTitle(title, for: .normal)
        backgroundColor = bgColor
        setTitleColor(titleColor, for: .normal)
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.cornerRadius = 10.0
    }
}

