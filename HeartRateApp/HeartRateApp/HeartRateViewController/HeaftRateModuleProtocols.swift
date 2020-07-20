//
//  HeaftRateModuleProtocols.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 17/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit

protocol HeartRateViewProtocol: class {
    func updateGraph(with luminance: CGFloat)
}

protocol HeartRatePresenterProtocol: class {
    func didTapActionButton()
}
