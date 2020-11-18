//
//  UIColor+isFingerOnLense.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 20/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit

extension UIColor {
    var isFingerOnLense: Bool {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        
        getHue(&hue, saturation: &saturation, brightness: nil, alpha: nil)
        
        return (hue < 25 || hue > 340) && (saturation > 0.5)
    }
}
