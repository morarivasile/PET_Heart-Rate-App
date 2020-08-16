//
//  MainCoordinator.swift
//  HeartRateApp
//
//  Created by Vasile Morari on 20/07/2020.
//  Copyright © 2020 Vasile Morari. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = HeartRateViewController.nibLoaded
        
        let interactor = HeartRateInteractor(
            sessionManager: VideoSessionManager(),
            torchManager: TorchManager(),
            fingerTimerTotalInterval: 3.0,
            pulseTimerTotalInterval: 15.0,
            tickTimeInterval: 0.01
        )
        
        let presenter = HeartRatePresenter(
            interactor: interactor,
            view: viewController
        )
        
        viewController.presenter = presenter
        interactor.output = presenter
        
        navigationController.isNavigationBarHidden = true
        navigationController.pushViewController(viewController, animated: true)
    }
}
