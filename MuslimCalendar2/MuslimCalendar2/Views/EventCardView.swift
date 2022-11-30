//
//  EventCardView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

struct EventCardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var itemColors: [Int:Color] = [
        -1: .gray,
         0: .green,
         1: .yellow
    ]

    @ObservedObject var vm: EventViewModel
    @EnvironmentObject var svm: ScheduleViewModel
    @EnvironmentObject var ekEventService: EventKitService
    var dateFormatter = DateFormatter()
    
    init(item: Binding<ScheduleItem>) {
        self.vm = EventViewModel(item)
        dateFormatter.timeStyle = .short
    }
    
    var body: some View {
        ScrollView {
            HStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(itemColors[vm.dueState]!).frame(width: 5, alignment: .leading)
                VStack {
                    HStack {
                        TextField("", text: $vm.item.title)
                            .font(.headline)
                            .submitLabel(.done)
                        Label(vm.item.selectedAlert.shortText, systemImage: "alarm")
                            .labelStyle(.trailingIcon)
                            .font(.caption)
                    }
                    Spacer()
                    HStack {
                        HStack {
                            Label(dateFormatter.string(from: vm.item.startTime), systemImage: "calendar").foregroundColor(.primary)
                            Text(dateFormatter.string(from: vm.item.endTime)).opacity(0.5)
                        }
                        Spacer()
                        Label(vm.durationText, systemImage: "clock")
                            .labelStyle(.trailingIcon)
                    }
                    .font(.caption)
                    #if DEBUG
//                    Text("start: \(vm.item.start), sr: \(vm.item.startRelativeTo), end: \(vm.item.end), er: \(vm.item.endRelativeTo)")
                    #endif
                }
            .padding()
            }
            .background(.thinMaterial)
        }
        .listRowSeparator(.hidden)
        .onSubmit {
            //TODO: Move this to the view model
            let ekEvent = ekEventService.createOrUpdate(eventOf: vm.item, prayerCacluation: svm.prayerCalculation)
            vm.item.wrappedEkEvent = ekEvent
            vm.item.syncWrappedObject(viewContext)
            svm.refresh(item: vm.item)
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
