//
//  VideoSessionManagerDelegate.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 17/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import AVFoundation

@objc protocol VideoSessionManagerDelegate: class {
    
    /**
     This method delivers the pixel buffer of the current frame seen by the device's camera.
     */
    @objc optional func sessionManager(_ sessionManager: VideoSessionManager, didOutput pixelBuffer: CVPixelBuffer)
    
    /**
     This method initimates that the session was interrupted.
     */
    @objc optional func sessionWasInterrupted(_ sessionManager: VideoSessionManager, canResumeManually resumeManually: Bool)
    
    /**
     This method initimates that the session interruption has ended.
     */
    @objc optional func sessionInterruptionEnded(_ sessionManager: VideoSessionManager)
    
    /**
     This method initimates that a session runtime error occured.
     */
    @objc optional func sessionRunTimeErrorOccured(_ sessionManager: VideoSessionManager)
    
    /**
     This method initimates that the camera permissions have been denied.
     */
    @objc optional func cameraPermissionsDenied(_ sessionManager: VideoSessionManager)
}
