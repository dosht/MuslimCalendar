//
//  EventCardView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

struct EventCardView: View {
    @Binding
    var item: ScheduleItem
    
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
    
    var body: some View {
        ScrollView {
            HStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(.yellow).frame(width: 5, alignment: .leading)
                VStack {
                    TextField("", text: $item.title)
                        .font(.headline)
                    Spacer()
                    HStack {
                        Label("starts after fajr", systemImage: "calendar").foregroundColor(.primary)
                        Spacer()
                        Label(durationText, systemImage: "clock")
                            .labelStyle(.trailingIcon)
                    }
                    .font(.caption)
                }
                .padding()
            }
            .background(.thinMaterial)
        }
    }
}

struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}


extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: Self { Self() }
}

struct EventCardView_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var items: [ScheduleItem] = ScheduleItem.eventSample
        
        var body: some View {
            List($items) { $item in
                EventCardView(item: $item)
            }
        }
    }
    static var previews: some View {
        Preview()
    }
}
