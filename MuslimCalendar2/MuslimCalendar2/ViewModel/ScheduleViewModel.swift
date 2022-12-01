//
//  ScheduleViewModel.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI
import Combine

class ScheduleViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Publisher(s)
    @Published
    var items: [ScheduleItem] = []
    
    @Published
    var prayerItems: [ScheduleItem] = []
    
    @Published
    var eventItems: [ScheduleItem] = []

    @Published
    var day: WeekDay? = .Monday
    
    @Published
    var prayerCalculation: PrayerCalculation = PrayerCalculation.preview
    
    @Published
    var focusedItem: ScheduleItem?
    
    var scrollToItem: ScheduleItem? {
        let now = Date()
        let index = items.firstIndex { item in
            item.startTime <= now && item.endTime >= now
        }
        guard var index = index else { return nil }
        if index < items.count - 3 { index += 3 }
        let scrollToItem = items[index]
        return scrollToItem
    }
    
    var showKeyboardToolBar: Bool {
        get { focusedItem != nil }
        set { if !newValue { focusedItem = nil } }
    }
    
    @Published
    var editItem: ScheduleItem?
    
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
    
    func subscribe(items: Publishers.Sequence<[ScheduleItem], Never>) {
        items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                guard let self = self else { return }
                self.eventItems = self.eventItems + [item]
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Intent(s)
    func selectDay(day: WeekDay) {
        self.day = day
    }
    
    func loadEvents(_ events: [RelativeEvent]) {
        eventItems = events.map { $0.scheuledItem.updateTime(with: prayerCalculation) }
    }

    func addItem(item: ScheduleItem) {
        eventItems.append(item)
        Just(item).delay(for: 0.25, scheduler: RunLoop.main)
            .sink { [weak self] item in
                self?.focusedItem = item
            }
            .store(in: &cancellables)
    }

    func remove(items: [ScheduleItem]) {
        Just(items).delay(for: 0, scheduler: RunLoop.main)
            .sink { [weak self] items in
                guard let self = self else { return }
                let itemsSet = Set(items.map { $0.id })
                self.eventItems = self.eventItems.filter { item in !itemsSet.contains(item.id) }
            }
            .store(in: &cancellables)
    }
    
    func new() {
        editItem = ScheduleItem(title: "", startTime: Date().endOfDay, duration: 30*60, type: .event)
    }
    
    func edit(_ item: ScheduleItem) {
        editItem = item
    }
    
    func dismissEdit() {
        editItem = nil
    }
    
    func refresh(item: ScheduleItem) {
        eventItems = eventItems.filter { $0.id != item.id } + [item]
    }
    
    func updatePrayerItems(prayerCalculation: PrayerCalculation) {
        self.prayerItems = ScheduleItem.fromPrayerCaclculation(prayerCalculation)
    }
    
    func updateEventItems(prayerCalculation: PrayerCalculation) {
        self.eventItems = eventItems.map { $0.updateTime(with: prayerCalculation) }
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
                            let availableItem = ScheduleItem(title: "", startTime: a.endTime, duration: availableTime, type: .availableTime, startRelativeTo: a.endRelativeTo, endRelativeTo: b.startRelativeTo, start: a.end, end: b.start)
                            return [a, availableItem, b]
                        } else {
                            return [a, b]
                        }
                    }
            )
        ).sorted()
    }
}
