//
//  AppRouter.swift
//  tiera
//
//  Created by Christos Christodoulou on 13/04/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import ReSwift

/// here we define all the destinations
enum RoutingDestination: String {
    case home = "HomeVC"
    case schedule = "ScheduleVC"
}

final class AppRouter {
    
    let navigationController: UINavigationController
    
    init(window: UIWindow) {
        navigationController = UINavigationController()
        window.rootViewController = navigationController
        // 1
        store.subscribe(self) {
            $0.select {
                $0.routingState
            }
        }
    }
    
    // 2
    fileprivate func pushViewController(identifier: String, animated: Bool) {
        let viewController = instantiateViewController(identifier: identifier)
        let newViewControllerType = type(of: viewController)
        if let currentVc = navigationController.topViewController {
            let currentViewControllerType = type(of: currentVc)
            if currentViewControllerType == newViewControllerType {
                return
            }
        }
        
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    private func instantiateViewController(identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
}

// MARK: - StoreSubscriber
// 3
extension AppRouter: StoreSubscriber {
    func newState(state: RoutingState) {
        // 4
        let shouldAnimate = navigationController.topViewController != nil
        // 5
        pushViewController(identifier: state.navigationState.rawValue, animated: shouldAnimate)
    }
}
