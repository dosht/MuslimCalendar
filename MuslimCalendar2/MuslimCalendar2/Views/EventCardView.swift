//
//  EventCardView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

struct EventCardView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject
    var vm: EventViewModel
    
    init(item: Binding<ScheduleItem>) {
        self.vm = EventViewModel(item)
    }
    
    var body: some View {
        ScrollView {
            HStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(.yellow).frame(width: 5, alignment: .leading)
                VStack {
                    TextField("", text: $vm.item.title)
                        .font(.headline)
                    Spacer()
                    HStack {
                        Label("starts after fajr", systemImage: "calendar").foregroundColor(.primary)
                        Spacer()
                        Label(vm.durationText, systemImage: "clock")
                            .labelStyle(.trailingIcon)
                    }
                    .font(.caption)
                    Text("start: \(vm.item.start), sr: \(vm.item.startRelativeTo), end: \(vm.item.end), er: \(vm.item.endRelativeTo)")
                }
                .padding()
            }
            .background(.thinMaterial)
        }
        .onSubmit {
            vm.item.syncWrappedObject(viewContext)
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

#if DEBUG
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
#endif
