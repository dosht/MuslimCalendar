//
//  TimeInterval.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 25.10.2022.
//

import Foundation

extension TimeInterval {
    var hour: Int? {
        toOptional(Int(self / 60 / 60))
    }
    
    var minute: Int? {
        toOptional(Int(self / 60) - (hour ?? 0) * 60)
    }
    
    private func toOptional(_ value: Int) -> Int? {
        if value == 0 {
            return nil
        }
        return value
    }
}
