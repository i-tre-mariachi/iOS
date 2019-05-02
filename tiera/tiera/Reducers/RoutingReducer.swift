//
//  RoutingReducer.swift
//  tiera
//
//  Created by Christos Christodoulou on 13/04/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import ReSwift

func routingReducer(action: Action, state: RoutingState?) -> RoutingState {
    var state = state ?? RoutingState()
    
    switch action {
    case let routingAction as RoutingAction:
        state.navigationState = routingAction.destination
    default: break
    }
    
    return state
}
