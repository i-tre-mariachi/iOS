//
//  String.swift
//  tieraCommon
//
//  Created by Christos Christodoulou on 14/03/2019.
//  Copyright © 2019 Christos Christodoulou. All rights reserved.
//

extension String {
    /// Capitalizes the first letter.
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    /// Capitalizes the first letter.
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    /// Converts `self` to a date.
    ///
    /// - parameters:
    ///   - format: The format of the date that is in the `String`.
    ///   - locale: The locale of that we want the date to be in. Defaults to `current`.
    public func date(format: String, locale: Locale = Locale.current) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        guard let intermediateDate = formatter.date(from: self) else {
            return nil
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: intermediateDate)
        let finalDate = calendar.date(from:components)
        return finalDate
    }
}
