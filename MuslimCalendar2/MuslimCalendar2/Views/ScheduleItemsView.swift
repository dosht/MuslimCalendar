//
//  ScheduleItemsView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

struct ScheduleItemsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var scheduleItems: [ScheduleItem]
    
    @FocusState var focusedItem: ScheduleItem?
    
    @EnvironmentObject var vm: ScheduleViewModel
    @EnvironmentObject var ekEventService: EventKitService
        
    var body: some View {
        ScrollViewReader { scrollProxy in
            List {
                //            ForEach(Array($scheduleItems.enumerated()), id: \.0) { index, $item in
                ForEach(Array($scheduleItems).dropFirst().dropLast()) { $item in
                    switch item.type {
                    case .prayer:
                        PrayerCardView(item: $item)
                            .deleteDisabled(true)
                    case .event:
                        EventCardView(item: $item)
                            .id(item.id)
                            .focused($focusedItem, equals: item)
//                            .swipeActions(edge: .leading) {
//                                Button {
//                                    vm.edit(item)
//                                } label: {
//                                    Label("Complete", systemImage: "checkmark")
//                                }
//                                .tint(Color(UIColor.systemGreen))
//                                Button {
//                                    vm.edit(item)
//                                } label: {
//                                    Label("Details", systemImage: "ellipsis")
//                                }
//                                .tint(Color(UIColor.systemGray))
//                            }
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    if item == focusedItem {
                                        if #available(iOS 16.0, *) {
                                            ScheduleItemToolbarView(item: $item, allocation: scheduleItems.allocation(of: item))
                                        } else {
                                            EmptyView()
                                        }
                                    } else {
                                        EmptyView()
                                    }
                                }
                            }
                    case .availableTime:
                        AvailableTimeCardView(item: $item)
                            .deleteDisabled(true)
                    }
                }
                .onDelete { indexSet in
                    let items = indexSet.map { scheduleItems[$0 + 1] /* Adding one because we drop the first element */ }
                    vm.remove(items: items)
                    for var item in items {
                        ekEventService.delete(eventOf: item)
                        item.deleteWrappedObect(viewContext)
                    }
                }
                .onReceive(vm.$focusedItem) { item in
                    scrollTo(item, scrollProxy)
                    if #unavailable(iOS 16.0) {
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.25) {
                            scrollTo(item, scrollProxy)
                        }
                    }
                }
                .onAppear {
                    scrollTo(vm.scrollToItem, scrollProxy)
                }
            }
        }
//        .toolbar {
//            ToolbarItemGroup(placement: .keyboard) {
//                ScheduleItemToolbarView(item: $vm.focusedItem)
//            }
//        }
        .sync($vm.focusedItem, $focusedItem)
        .sheet(item: $vm.editItem, onDismiss: {
            print("\(vm.editItem)")
        } , content: { item in
            EventDetailView(item: item)
        })
        .onAppear {
            ekEventService.requestPermissionAndCreateEventStore()
        }
//        .onChange(of: focusedItem, perform: vm.focus)
        .listStyle(.plain)
    }
    
    private func scrollTo(_ item: ScheduleItem?, _ scrollProxy: ScrollViewProxy) {
        guard let item = item else { return }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.25) {
            withAnimation {
                scrollProxy.scrollTo(item.id)
            }
        }
    }
}

#if DEBUG
struct ScheduleItemsView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleItemsView(scheduleItems: Binding.constant(ScheduleItem.sample))
            .environmentObject(ScheduleViewModel())
            .environmentObject(EventKitService())
    }
}
#endif
