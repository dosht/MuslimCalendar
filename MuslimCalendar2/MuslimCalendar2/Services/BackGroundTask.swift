//
//  BackGroundTask.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 13.11.2022.
//

import Foundation
import BackgroundTasks
import CoreData

func registerUpdateCalendarBGT() {
    BGTaskScheduler.shared.register(forTaskWithIdentifier: "team.aiops.updateCalendar", using: nil, launchHandler: updateCalendarBGT)
}

func updateCalendarBGT(task: BGTask) {
    updateCalendar()
    scheduleUpdateCalendarBGT()
    task.setTaskCompleted(success: true)
}

func updateCalendar() {
    let locationService = LocationService()
    locationService.allowsBackgroundLocationUpdates = true
    guard let location = locationService.currentLocation else { return }
    guard let prayerCalculation = calculatePrayerTimes(forDay: Date(), forLocation: location) else { return }
    let context = PersistenceController.shared.container.viewContext
    let reuqest = NSFetchRequest<RelativeEvent>(entityName: "RelativeEvent")
    guard let relativeEvents = try? context.fetch(reuqest) else { return }
    let eventKitService = EventKitService()
    let events = relativeEvents.map { $0.scheuledItem.updateTime(with: prayerCalculation) }
    events.forEach { item in
        eventKitService.delete(eventOf: item)
        let ekEvent = eventKitService.createOrUpdate(eventOf: item, prayerCacluation: prayerCalculation)
        item.wrappedObject?.ekEventIdentifier = ekEvent?.eventIdentifier
    }
    try? context.save()
}

func scheduleUpdateCalendarBGT() {
    let task = BGProcessingTaskRequest(identifier: "team.aiops.updateCalendar")
    task.earliestBeginDate = Date().addingTimeInterval(10) // Date().tomorrow.startOfDay
        do {
          try BGTaskScheduler.shared.submit(task)
        } catch {
          print("Unable to submit task: \(error.localizedDescription)")
        }
}
