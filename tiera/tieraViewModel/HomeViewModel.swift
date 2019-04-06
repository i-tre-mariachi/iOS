//
//  HomeViewModel.swift
//  tieraViewModel
//
//  Created by Christos Christodoulou on 24/03/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

import Foundation
import tieraCommon
import tieraModel


///Provides data to the screen and extract date from the screen
///Then we can validate and pass them to the Model where it can be persistence
///Values will populated here when user taps on its action from the screen

public final class HomeViewModel {

    public var progressLabel: String
    public var startCoffeeButtonLabel: String
    public var scheduleCoffeeButtonLabel: String
    
    public init(progressLabel: String, startCoffeeButtonLabel: String, scheduleCoffeeButtonLabel: String) {
        ///assign default values
        self.progressLabel = progressLabel
        self.startCoffeeButtonLabel = startCoffeeButtonLabel
        self.scheduleCoffeeButtonLabel = scheduleCoffeeButtonLabel
    }
}
