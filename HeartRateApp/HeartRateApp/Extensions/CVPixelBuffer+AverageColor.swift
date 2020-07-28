//
//  CVPixelBuffer+AverageColor.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 28/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit

extension CVPixelBuffer {
    var averageColor: UIColor? {
        return UIImage(pixelBuffer: self)?.averageColor
    }
}
