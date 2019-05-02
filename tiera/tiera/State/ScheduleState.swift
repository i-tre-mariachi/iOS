//
//  ScheduleState.swift
//  tiera
//
//  Created by Christos Christodoulou on 29/04/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import ReSwift

//enum Category: String {
//    case pop = "Pop"
//    case electronic = "Electronic"
//    case rock = "Rock"
//    case metal = "Metal"
//    case rap = "Rap"
//}

//struct CategoriesState: StateType {
//    let categories: [Category]
//    var currentCategorySelected: Category
//
//    init(currentCategory: Category) {
//        categories = [ .pop, .electronic, .rock, .metal, .rap]
//        currentCategorySelected = currentCategory
//    }
//}

struct ScheduleState: StateType {
    
    var scheduleTitles: [String] ///Think about the name #homeTitles it might be better to be renamed to something else
    
    init() {
        scheduleTitles = ["Begin"] ///currently to save and start the BT process
    }
}
