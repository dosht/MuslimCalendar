//
//  ScheduleView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject
    var viewModel: ScheduleViewModel
    
    @FetchRequest(sortDescriptors: [])
    var relativeEvents: FetchedResults<RelativeEvent>
  
    var body: some View {
        NavigationView {
            VStack {
                ScheduleViewToolbar()
                ScheduleViewTitle()
                DaysView(selectedDay: $viewModel.day)
                    .onAppear {
                        viewModel.selectDay(day: Date().weekDay)
                        viewModel.loadEvents(Array(relativeEvents))
                    }
                ScheduleItemsView(scheduleItems: $viewModel.items)
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button {
                            
                        } label: {
                            HStack {
                                Label("", systemImage: "plus.circle.fill")
                                Text("Add Event").bold()
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

struct ScheduleViewToolbar: View {
    @State
    var showCity = false
    
    @State
    var showSettings = false
    
    var body: some View {
        HStack {
            Button {
                showCity.toggle()
            } label: {
                Label("Golcuk", systemImage: "mappin.and.ellipse")
                    .padding()
                    .foregroundColor(.blue)
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
    }
}

extension ScheduleViewModel {
    convenience init(prayerItems: [ScheduleItem]) {
        self.init()
        self.prayerItems = prayerItems
    }
}
#endif
