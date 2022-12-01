//
//  ScheduleView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var viewModel: ScheduleViewModel
    @EnvironmentObject var eventKitService: EventKitService
    
    @FetchRequest(sortDescriptors: [])
    var relativeEvents: FetchedResults<RelativeEvent>
  
    var body: some View {
        GeometryReader { geo in
//            NavigationView {
                VStack {
                    ScheduleViewToolbar()
                    ScheduleViewTitle()
                        DaysView(selectedDay: $viewModel.day, geo: geo)
                        .onAppear {
                            viewModel.selectDay(day: Date().weekDay)
                            viewModel.loadEvents(Array(relativeEvents))
                            // TODO: Improve this and move it to the view model
                            for var item in viewModel.eventItems {
                                if let ekEvent = eventKitService.findEvent(of: item) {
                                    item.loadEkEvent(ekEvent: ekEvent)
                                    viewModel.refresh(item: item)
                                    
                                }
                            }
                        }
                    ScheduleItemsView(scheduleItems: $viewModel.items)
                }
                //            .toolbar {
                //                ToolbarItem(placement: .bottomBar) {
                //                    HStack {
                //                        Button {
                //                            viewModel.new()
                //                        } label: {
                //                            HStack {
                //                                Label("", systemImage: "plus.circle.fill")
                //                                Text("Add Event").bold()
                //                            }
                //                        }
                //                        Spacer()
                //                    }
                //                }
                //            }
//            }
        }
    }
}

struct ScheduleViewToolbar: View {
    @EnvironmentObject var placemarkService: PlacemarkService
    
    @State var showCity = false
    @State var showSettings = false
    
    var body: some View {
        HStack {
            Button {
                showCity.toggle()
            } label: {
                if cityTitle == nil {
                    ProgressView()
                        .padding()
                } else {
                    Label(cityTitle!, systemImage: "mappin.and.ellipse")
                        .padding()
                        .foregroundColor(.blue)
                }
            }
            .popover(isPresented: $showCity, attachmentAnchor: .point(.top), arrowEdge: .top) {
                CityView(isPresented: $showCity)
            }

            Spacer()
            Button {
                showSettings.toggle()
            } label: {
                Label("", systemImage: "ellipsis.circle")
                    .font(.title2)
                    .padding()
                    .foregroundColor(.blue)
            }
            .popover(isPresented: $showSettings, attachmentAnchor: .point(.top), arrowEdge: .top) {
                SettingsView(isPresented: $showSettings)
            }
        }
    }
    
    var cityTitle: String? {
        if let city = placemarkService.placemark?.locality, let state = placemarkService.placemark?.administrativeArea {
            return "\(state), \(city)"
        } else {
            return nil
        }
    }
}

struct ScheduleViewTitle: View {
    var body: some View {
        HStack {
            Text("Day Schedule").padding(.leading, 15).font(.title)
            Spacer()
        }
    }
}

#if DEBUG
struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
            .environmentObject(ScheduleViewModel(prayerItems: ScheduleItem.prayerRealisticSample))
            .environmentObject(EventKitService())
            .environmentObject(PlacemarkService())
    }
}

extension ScheduleViewModel {
    convenience init(prayerItems: [ScheduleItem]) {
        self.init()
        self.prayerItems = prayerItems
    }
}
#endif
