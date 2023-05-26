//
//  Date+Extension.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/26.
//

import Foundation

extension Date {
    var formatNowDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Taipei")
        
        let dateString = dateFormatter.string(from: self)
        
        return dateFormatter.date(from: dateString) ?? self
    }
}
