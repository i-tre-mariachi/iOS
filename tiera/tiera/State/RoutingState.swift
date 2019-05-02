//
//  RoutingState.swift
//  tiera
//
//  Created by Christos Christodoulou on 13/04/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//
///RoutingState contains navigationState, which represents the current destination on screen.
import ReSwift

struct RoutingState: StateType {
    var navigationState: RoutingDestination
    
    init(navigationState: RoutingDestination = .home) {
        self.navigationState = navigationState
    }
}
