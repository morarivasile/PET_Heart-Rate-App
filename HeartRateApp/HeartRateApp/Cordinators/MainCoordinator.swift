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
        
        let presenter = HeartRatePresenter(
            sessionManager: VideoSessionManager(),
            torchManager: TorchManager()
        )
        
        viewController.presenter = presenter
        presenter.view = viewController
        
        navigationController.isNavigationBarHidden = true
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
