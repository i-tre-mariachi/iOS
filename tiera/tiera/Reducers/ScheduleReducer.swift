//
//  ScheduleReducer.swift
//  tiera
//
//  Created by Christos Christodoulou on 29/04/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import ReSwift
import CoreBluetooth

private struct ScheduleReducerConstants {
    static let userDefaultsScheduleKey = "currentScheduleKey"
}

private typealias C = ScheduleReducerConstants



func ScheduleReducer(action: Action, state: ScheduleState?) -> ScheduleState {
    return ScheduleState()
}

//TODO: add the bluetooth calls here

//func categoriesReducer(action: Action, state: CategoriesState?) -> CategoriesState {
//    var currentCategory: Category = .pop
//    // 1
//    if let loadedCategory = getCurrentCategoryStateFromUserDefaults() {
//        currentCategory = loadedCategory
//    }
//    var state = state ?? CategoriesState(currentCategory: currentCategory)
//
//    switch action {
//    case let changeCategoryAction as ChangeCategoryAction:
//        // 2
//        let newCategory = state.categories[changeCategoryAction.categoryIndex]
//        state.currentCategorySelected = newCategory
//        saveCurrentCategoryStateToUserDefaults(category: newCategory)
//
//    default: break
//    }
//
//    return state
//}
//
//// 3
//private func getCurrentCategoryStateFromUserDefaults() -> Category? {
//    let userDefaults = UserDefaults.standard
//    let rawValue = userDefaults.string(forKey: C.userDefaultsCategoryKey)
//    if let rawValue = rawValue {
//        return Category(rawValue: rawValue)
//    } else {
//        return nil
//    }
//}
//
//// 4
//private func saveCurrentCategoryStateToUserDefaults(category: Category) {
//    let userDefaults = UserDefaults.standard
//    userDefaults.set(category.rawValue, forKey: C.userDefaultsCategoryKey)
//    userDefaults.synchronize()
//}
