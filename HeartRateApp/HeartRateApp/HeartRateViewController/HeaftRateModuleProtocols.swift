//
//  HeaftRateModuleProtocols.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 17/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit

protocol HeartRateViewProtocol: class {
    func updateView(isCameraStarted: Bool)
    
    func setFingerDetectionProgress(_ progress: Float, animated: Bool)
    func setPulseDetectionProgress(_ progress: Float, animated: Bool)
}

protocol HeartRatePresenterProtocol: class {
    func didTapActionButton()
}
