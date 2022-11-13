//
//  BackGroundTask.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 13.11.2022.
//

import Foundation
import BackgroundTasks

func registerUpdateCalendarBGT() {
    BGTaskScheduler.shared.register(forTaskWithIdentifier: "team.aiops.updateCalendar", using: nil, launchHandler: updateCalendarBGT)
}

func updateCalendarBGT(task: BGTask) {
    
    scheduleUpdateCalendarBGT()
    task.setTaskCompleted(success: true)
}

func scheduleUpdateCalendarBGT() {
    let task = BGProcessingTaskRequest(identifier: "team.aiops.updateCalendar")
    task.earliestBeginDate = Date().tomorrow
        do {
          try BGTaskScheduler.shared.submit(task)
        } catch {
          print("Unable to submit task: \(error.localizedDescription)")
        }
}
