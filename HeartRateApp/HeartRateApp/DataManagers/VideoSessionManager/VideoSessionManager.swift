//
//  VideoSessionManager.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 17/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import AVFoundation

final class VideoSessionManager: NSObject {
    
    private lazy var captureDevice = AVCaptureDevice.default(for: .video)
    
    var isSessionRunning: Bool {
        return captureSession?.isRunning ?? false
    }
    
    private var videoInput: AVCaptureDeviceInput? {
        if let device = captureDevice {
            return try? AVCaptureDeviceInput(device: device)
        } else {
            return nil
        }
    }
    
    private lazy var videoDataOutput: AVCaptureVideoDataOutput = {
        let output = AVCaptureVideoDataOutput()
        let sampleBufferQueue = DispatchQueue(label: "sampleBufferQueue")
        
        output.setSampleBufferDelegate(self, queue: sampleBufferQueue)
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey) : kCMPixelFormat_32BGRA]
        
        return output
    }()
    
    private(set) lazy var captureSession: AVCaptureSession? = {
        guard let captureDevice = captureDevice else { return nil }
        
        let session = AVCaptureSession()
        
        if let input = videoInput, session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        
        return session
    }()
    
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private(set) var frameInterval: Int = 1
    private var seenFrames: Int = 0
    
    weak var delegate: VideoSessionManagerDelegate?
    
    init(frameInterval: Int = 1) {
        self.frameInterval = frameInterval
    }
    
    func setFrameInterval(_ frameInterval: Int) {
        self.frameInterval = frameInterval
    }
}

// MARK: - Session Start and End methods
extension VideoSessionManager {
    /**
     This method starts the AVCaptureSession
     **/
    func startSession(completion: ((Bool) -> Void)? = nil) {
        configurePermissions { (granted) in
            if granted {
                self.seenFrames = 0
                self.addObservers()
                self.captureSession?.startRunning()
            } else {
                self.delegate?.cameraPermissionsDenied?(self)
            }
            
            completion?(granted)
        }
    }
    
    /**
     This method stops a running an AVCaptureSession.
     */
    func stopSession() {
        removeObservers()
        sessionQueue.async {
            if self.captureSession?.isRunning ?? false {
                self.captureSession?.stopRunning()
            }
        }
    }
    
    /**
     This method resumes an interrupted AVCaptureSession.
     */
    func resumeInterruptedSession(withCompletion completion: @escaping (Bool) -> Void) {
        sessionQueue.async {
            self.startSession()
            
            DispatchQueue.main.async {
                completion(self.isSessionRunning)
            }
        }
    }
}

// MARK: - Session Configuration Methods.
extension VideoSessionManager {
    /**
     This method requests for camera permissions and handles the configuration of the session and stores the result of configuration.
     */
    private func configurePermissions(completion: @escaping (Bool) -> ()) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            self.sessionQueue.suspend()
            
            self.requestCameraAccess(completion: { (granted) in
                
                self.sessionQueue.resume()
                completion(granted)
            })
        case .denied:
            completion(false)
        default:
            break
        }
    }
    
    /**
     This method requests for camera permissions.
     */
    private func requestCameraAccess(completion: @escaping (Bool) -> ()) {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            completion(granted)
        }
    }
}

// MARK: - Notification Observer Handling
extension VideoSessionManager {
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeErrorOccured(notification:)), name: NSNotification.Name.AVCaptureSessionRuntimeError, object: captureSession)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted(notification:)), name: NSNotification.Name.AVCaptureSessionWasInterrupted, object: captureSession)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: NSNotification.Name.AVCaptureSessionInterruptionEnded, object: captureSession)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureSessionRuntimeError, object: captureSession)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureSessionWasInterrupted, object: captureSession)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureSessionInterruptionEnded, object: captureSession)
    }
    
    // MARK: Notification Observers
    @objc private func sessionWasInterrupted(notification: Notification) {
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
           let reasonIntegerValue = userInfoValue.integerValue,
           let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            
            var canResumeManually = false
            if reason == .videoDeviceInUseByAnotherClient {
                canResumeManually = true
            } else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                canResumeManually = false
            }
            
            delegate?.sessionWasInterrupted?(self, canResumeManually: canResumeManually)
        }
    }
    
    @objc private func sessionInterruptionEnded(notification: Notification) {
        delegate?.sessionInterruptionEnded?(self)
        
    }
    
    @objc private func sessionRuntimeErrorOccured(notification: Notification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else {
            return
        }
        
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.startSession()
                } else {
                    DispatchQueue.main.async {
                        self.delegate?.sessionRunTimeErrorOccured?(self)
                    }
                }
            }
        } else {
            delegate?.sessionRunTimeErrorOccured?(self)
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension VideoSessionManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    /** This method delegates the CVPixelBuffer of the frame seen by the camera currently.
     */
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Because lowering the capture device's FPS looks ugly in the preview,
        // we capture at full speed but only call the delegate at its desired
        // frame rate. If frameInterval is 1, we run at the full frame rate.
        
        seenFrames += 1
        guard seenFrames >= frameInterval else { return }
        seenFrames = 0
        
        // Converts the CMSampleBuffer to a CVPixelBuffer.
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        guard let imagePixelBuffer = pixelBuffer else { return }
        
        // Delegates the pixel buffer to the ViewController.
        delegate?.sessionManager?(self, didOutput: imagePixelBuffer)
    }
}
