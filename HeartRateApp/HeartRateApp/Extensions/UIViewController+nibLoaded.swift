//
//  UIViewController+NibLoaded.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 17/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit

extension UIViewController {
    class var nibLoaded: Self {
        return Self.init(nibName: String(describing: Self.self), bundle: nil)
    }
}
