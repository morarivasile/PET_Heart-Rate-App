//
//  HeaftRateModuleProtocols.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 17/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit

protocol HeartRateViewProtocol: class {
//    func updateGraph(with luminanceValues: [CGFloat])
    func updateView(isCameraStarted: Bool)
    func setProgress(_ progress: Float, animated: Bool)
}

protocol HeartRatePresenterProtocol: class {
    func didTapActionButton()
}
