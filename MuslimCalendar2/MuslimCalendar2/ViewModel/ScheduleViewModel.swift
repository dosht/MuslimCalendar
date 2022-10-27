//
//  ScheduleViewModel.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI
import Combine

@MainActor
class ScheduleViewModel: ObservableObject {
    // MARK: - Publisher(s)
    @Published
    var items: [ScheduleItem] = []
    
    @Published
    var prayerItems: [ScheduleItem] = []
    
    @Published
    var eventItems: [ScheduleItem] = []

    @Published
    var day: WeekDay? = .Monday
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $prayerItems
            .combineLatest($eventItems)
            .receive(on: DispatchQueue.main)
            .map(ScheduleViewModel.combineEvents)
            .map(ScheduleViewModel.addAvailableItems)
            .sink { [weak self] items in
                guard let self = self else { return }
                self.items = items
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Intent(s)
    func selectDay(day: WeekDay) {
        self.day = day
    }
    
    func loadItems() {
        self.eventItems = ScheduleItem.createSample(day: day).filter { $0.type == .event }
    }

    func addItem(item: ScheduleItem) {
        eventItems.append(item)
    }

    func remove(items: [ScheduleItem]) {
        let itemsSet = Set(items.map { $0.id })
        eventItems = eventItems.filter { item in !itemsSet.contains(item.id) }
    }
    
    func refresh(item: ScheduleItem) {
        eventItems = eventItems.filter { $0.id != item.id } + [item]
    }
    
    func updatePrayerItems(prayerCalculation: PrayerCalculation) {
        self.prayerItems = ScheduleItem.fromPrayerCaclculation(prayerCalculation)
    }
    // MARK: - Static Helper(s)
    static func combineEvents(prayerItems: [ScheduleItem], eventItems: [ScheduleItem]) -> [ScheduleItem] {
        (prayerItems + eventItems).sorted()
    }
    
    static func addAvailableItems(items: [ScheduleItem]) -> [ScheduleItem] {
        Array(
            Set(
                zip(items.dropLast(), items.dropFirst())
                    .flatMap { (a, b) -> [ScheduleItem] in
                        let availableTime = b.startTime.timeIntervalSince(a.endTime)
                        if availableTime > 0 {
                            let availableItem = ScheduleItem(title: "", startTime: a.endTime, duration: availableTime, type: .availableTime)
                            return [a, availableItem, b]
                        } else {
                            return [a, b]
                        }
                    }
            )
        ).sorted()
    }
}
