//
//  EventViewModel.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 27.10.2022.
//

import SwiftUI

class EventViewModel: ObservableObject {
    @Binding
    var item: ScheduleItem
    
    init(_ item: Binding<ScheduleItem>) {
        self._item = item
//        self._item = Published(wrappedValue: item.wrappedValue)
    }
    
    var durationText: String {
        let hour = item.duration.hour
        let minute = item.duration.minute
        var result = ""
        if let hour = hour, let minute = minute {
            result = "\(abs(hour))h, \(abs(minute))m"
        }
        else if let hour = hour {
            result = "\(abs(hour))h"
        }
        else if let minute = minute {
            result = "\(abs(minute))m"
        }
        return result
    }
    
    //MARK: - Intent(s)
    func reschedule(allocation: Allocation) {
        item.reschedule(allocation: allocation)
    }
}
