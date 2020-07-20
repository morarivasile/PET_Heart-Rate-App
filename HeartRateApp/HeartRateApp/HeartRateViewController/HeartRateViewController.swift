//
//  HeartRateViewController.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 17/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit
import AVFoundation

final class HeartRateViewController: UIViewController {
    
    var presenter: HeartRatePresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Camera"
    }
    
    @IBAction func didTapOnCameraButton(_ sender: UIButton) {
        presenter?.didTapActionButton()
    }
}

// MARK: - HeartRateViewProtocol
extension HeartRateViewController: HeartRateViewProtocol {
    func updateGraph(with luminance: CGFloat) {
        print(luminance)
    }
}
