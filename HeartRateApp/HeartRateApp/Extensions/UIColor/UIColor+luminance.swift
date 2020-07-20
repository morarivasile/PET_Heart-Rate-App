//
//  UIColor+luminance.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 20/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit

extension UIColor {
    
    var luminance: CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        return (0.299 * red) + (0.587 * green) + (0.114 * blue)
    }
    
    var isLight: Bool {
        return luminance >= 0.6
    }
    
}
