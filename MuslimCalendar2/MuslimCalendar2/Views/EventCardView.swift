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
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous).fill(.yellow).frame(width: 5, alignment: .leading)
            VStack(alignment: .leading) {
                TextField("", text: $item.title)
                    .font(.headline)
                Spacer()
                HStack(spacing: 4) {
                    Label("starts after fajr", systemImage: "calendar").foregroundColor(.primary)
                    Spacer()
                    Label("30 m", systemImage: "clock")
                        .labelStyle(.trailingIcon)
                }
                .font(.caption)
            }
            .padding()
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
