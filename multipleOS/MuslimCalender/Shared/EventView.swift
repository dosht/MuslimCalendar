//
//  EventView.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 28.05.2022.
//

import SwiftUI

struct EventView: View {
    @State private var isEditing: Bool = false
    
    let title: String
    
    var body: some View {
        List {
            Section {
                Text("30 minutes after Fajr")
                    .padding(.top)
                Text("Duration: 30 minutes")
                Text("Repeats daily")
            }
            .listRowSeparator(.hidden)
            Section {
                HStack {
                    Text("Alert")
                    Spacer()
                    Text("10 minutes before").frame(alignment: .trailing)
                }
                HStack {
                    Text("Alarm")
                    Spacer()
                    Text("On time").frame(alignment: .trailing)
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EventEditor(isEditing: $isEditing)
            
            
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isEditing.toggle() }) {
                    Text( "Edit")
                }
            }
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static var previews: some View {
        EventView(title: "test")
    }
}
