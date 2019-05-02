//
//  DefaultsKeys.swift
//  tiera
//
//  Created by Christos Christodoulou on 13/03/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import SwiftyUserDefaults

extension DefaultsKeys {
    static let isFirstLaunch = DefaultsKey<Bool>("isFirstLaunch", defaultValue: true)
    static let isScheduledAt = DefaultsKey<Date?>("isScheduledAt")
    static let isTieraPrepared = DefaultsKey<Bool>("isTieraPrepared", defaultValue: false)

    static let username = DefaultsKey<String?>("username")
    
    static let coffeeCounter = DefaultsKey<Int>("coffeeCounter")
    static let coffeeCleanTrayCounter = DefaultsKey<Int>("coffeeCleanTrayCounter")
    static let coffeePreparationCounter = DefaultsKey<Int>("coffeePreparationCounter")

    static let coffeeDose = DefaultsKey<String>("coffeeDose")
    
    static let batteryLevel = DefaultsKey<String>("batteryLevel") //The battery level and the date that was last measured it
    static let batteryLevelDate = DefaultsKey<String>("batteryLevelDate")
}
