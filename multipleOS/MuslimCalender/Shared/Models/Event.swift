//
//  Event.swift
//  MuslimCalender (iOS)
//
//  Created by Mustafa Abdelhamıd on 15.08.2022.
//

import Foundation
import SwiftUI


protocol ScheduleItemProtocol: Identifiable, Hashable {
    var title: String { get set }
    
}

extension ScheduleItemProtocol {
    var id: Self { self }
}

struct ScheduleItemTest: ScheduleItemProtocol, Identifiable {
    var title: String
    
    
}

struct ScheduleItems: View {
    @State
    var test: [ScheduleItemTest] = [ScheduleItemTest(title: "title 1"), ScheduleItemTest(title: "title 2")]
    
    var body: some View {
        VStack {
            List {
                ForEach($test) { $item in
                    TextField("", text: $item.title)
                }
            }
            List($test) { $item in
                TextField("", text: $item.title)
            }
        }
    }
}

struct ScheduledEvent_Preview: PreviewProvider {
    static var previews: some View {
        ScheduleItems()
    }
}
