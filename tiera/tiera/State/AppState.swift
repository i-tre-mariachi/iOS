//
//  AppState.swift
//  tiera
//
//  Created by Christos Christodoulou on 13/04/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import ReSwift

/// This structure will define the entire state of the app
struct AppState: StateType {
    
    let routingState: RoutingState /// this is a sub-state
    let homeState: HomeState
    
}
