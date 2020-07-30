//
//  HeartRatePresenter.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 17/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import Foundation
import UIKit

final class HeartRatePresenter {
    var interactor: HeartRateInteractorProtocol
    weak var view: HeartRateViewProtocol?
    
    init(interactor: HeartRateInteractorProtocol, view: HeartRateViewProtocol?) {
        self.interactor = interactor
        self.view = view
    }
}

// MARK: - HeartRatePresenterProtocol
extension HeartRatePresenter: HeartRatePresenterProtocol {
    func didTapActionButton() {
        view?.setActionButtonInteraction(false)
        
        if interactor.isCameraStarted {
            interactor.stopDetection {
                DispatchQueue.main.async {
                    self.view?.setActionButtonInteraction(true)
                }
            }
        } else {
            interactor.startDetection { (success) in
                DispatchQueue.main.async {
                    self.view?.setActionButtonInteraction(true)
                }
            }
        }
    }
}

// MARK: - HeartRateInteractorOutputProtocol
extension HeartRatePresenter: HeartRateInteractorOutputProtocol {
    func didChangeState(_ state: HeartRateViewState) {
        DispatchQueue.main.async {
            self.view?.state = state
        }
    }
    
    func didChangeFingerDetectionProgress(_ progress: Float) {
        DispatchQueue.main.async {
            self.view?.setFingerDetectionProgress(progress, animated: false)
        }
    }
    
    func didChangePulseDetectionProgress(_ progress: Float) {
        DispatchQueue.main.async {
            self.view?.setPulseDetectionProgress(progress, animated: false)
        }
    }
    
    func didChangePulseValues(_ values: [CGFloat]) {
        DispatchQueue.main.async {
            self.view?.updateChart(values: values)
        }
    }
}
