//
//  UIImage+Initializers.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 20/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit
import VideoToolbox

extension UIImage {
    convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        
        guard let newImage = cgImage else {
            return nil
        }
        
        self.init(cgImage: newImage)
    }
}
