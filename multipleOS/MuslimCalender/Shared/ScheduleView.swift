//
//  CalendarView.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 23.05.2022.
//

import SwiftUI

struct ScheduleView: View {
    var body: some View {
        GeometryReader { geo in
            NavigationView {
                VStack(spacing: 1) {
                    HStack {
                        DaysView(day: "Sun", geo: geo)
                        DaysView(day: "Mon", geo: geo)
                        DaysView(day: "Tue", geo: geo, selected: true)
                        DaysView(day: "Wed", geo: geo)
                        DaysView(day: "Thu", geo: geo)
                        DaysView(day: "Fri", geo: geo)
                        DaysView(day: "Sat", geo: geo)
                    }
                    List {
        //                Section(header: Text("Fajr events")) {
        //                    Text("Quran")
        //                    Text("Fajr Prayer")
        //                    Text("Zikr")
        //                }
        //                Section(header: Text("Sunrise events")) {
        //                    Text("Sunrise")
        //                }
        //
                        Section(header: Text("Fajr")) {
//                        PrayerTimeView(prayerName: "Fajr")
                            //.font(font(from: geo.size))
                        CardView(title: "Fajr Prayer")
                        CardView(title: "Quran")
                            CardView(title: "Zikr")
                        }
                        Section(header: Text("Sunrise ☀️")) {
//                        PrayerTimeView(prayerName: "Sunrise ☀️")
                        CardView(title: "Sport")
                        }
                        AvailableTimeView(availableTime: 5)
                        
                        Section(header: Text("Duhr")) {
                            AvailableTimeView(availableTime: 3)
                        }
//                        PrayerTimeView(prayerName: "Dhur")
//                        PrayerTimeView(prayerName: "Asr")
//                        PrayerTimeView(prayerName: "Maghrib")
//                        PrayerTimeView(prayerName: "Isha")
                        
//                        }
                    }.listStyle(.inset)
                }.navigationTitle(Text("Title"))
            }
        }
    }
    private func font(from size: CGSize) -> Font{
        Font.system(size: min(size.height, size.width) * 0.04)
    }
}

struct DaysView: View {
    let day: String
    let geo: GeometryProxy
    var selected: Bool = false
    var body: some View {
            HStack(spacing: 1) {
                let diamiter = CGFloat(40)
                ZStack {
                    let shape = Circle()
                    if selected {
                        shape.fill(.yellow).frame(width: diamiter, height: diamiter, alignment: .leading)
                    } else {
                        shape.fill(.regularMaterial).frame(width: diamiter, height: diamiter, alignment: .leading)
                    }
//                    shape.stroke(lineWidth: CGFloat(2))
                    if selected {
                        Text(day).foregroundColor(.black)
                    } else {
                        Text(day)
                    }
                }
                
        }
    }
}

struct CardView: View {
    var title: String
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous).fill(.yellow).frame(width: 5, alignment: .leading)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Spacer()
                HStack(spacing: 4) {
                    Label("4", systemImage: "person.3").foregroundColor(.primary)
                    Spacer()
                    Label("30", systemImage: "clock")
                        .labelStyle(.trailingIcon)
                        
                }
                .font(.caption)
            }
            .padding()
//            .background(.white)
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

struct AvailableTimeView: View {
    let availableTime: Int
    var body: some View {
        GeometryReader { geo in
            Text("\(availableTime) Hours").frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            Label("", systemImage: "plus.circle.fill")
                .foregroundColor(.secondary).frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
                .font(.title)
        }.padding(20).background(.regularMaterial)
    }
}

struct PrayerTimeView: View {
    let prayerName: String
    var body: some View {
        Text(prayerName)
    }
}

extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: Self { Self() }
}



struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ScheduleView()
                .previewInterfaceOrientation(.landscapeLeft)
            ScheduleView()
                .previewInterfaceOrientation(.portraitUpsideDown).preferredColorScheme(.dark)
        }
    }
}
