//
//  AppReducer.swift
//  tiera
//
//  Created by Christos Christodoulou on 13/04/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

///There’s only one main Reducer function, but just as with state, reducers should be divided between sub-reducers.
import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {
    return AppState(
        routingState: routingReducer(action: action, state: state?.routingState),
        homeState: HomeReducer(action: action, state: state?.homeState)
    )
    
}
