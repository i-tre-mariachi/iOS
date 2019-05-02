//
//  HomeState.swift
//  tiera
//
//  Created by Christos Christodoulou on 14/04/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import ReSwift

struct HomeState: StateType {
    var homeTitles: [String] ///Think about the name #homeTitles it might be better to be renamed to something else
    
    init() {
       homeTitles = ["Make Coffee","Schedule Coffee"] ///currently
    }
}
