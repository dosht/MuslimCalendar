//
//  ScheduleItemsView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

class ScheduleItemsViewModel: ObservableObject {
    // MARK: - Publisher(s)
    @Published
    var focusedItem: ScheduleItem?
    
    // MARK: - Intent(s)
    func focus(item: ScheduleItem?) {
        focusedItem = item
    }    
}

class ScheduleItemEditViewModel: ObservableObject {
    
}

struct ScheduleItemsView: View {
    @Binding
    var scheduleItems: [ScheduleItem]
    
    @FocusState
    var focusedItem: ScheduleItem?
    
    @ObservedObject
    var vm = ScheduleItemsViewModel()
        
    var body: some View {
        List {
            ForEach($scheduleItems) { $item in
                switch item.type {
                case .prayer:
                    PrayerCardView(item: $item)
                case .event:
                    EventCardView(item: $item)
                        .focused($focusedItem, equals: item)
                case .availableTime:
                    AvailableTimeCardView(item: $item)
                }
            }
        }
        .onChange(of: focusedItem, perform: vm.focus)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                ScheduleItemToolbarView(item: $vm.focusedItem)
            }
        }
        .listStyle(.plain)
    }
}

#if DEBUG
struct ScheduleItemsView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleItemsView(scheduleItems: Binding.constant(ScheduleItem.sample))
    }
}
#endif
