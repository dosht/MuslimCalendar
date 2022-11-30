//
//  SettingsView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 13.11.2022.
//

import SwiftUI

struct SettingsView: View {
    @Binding
    var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Text("Calendar")
                    Text("Calculation Method")
                }
                Spacer()
                Button {
                    updateCalendar()
                } label: {
                    Label("Re-Sync Calender", systemImage: "arrow.triangle.2.circlepath")
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresented.toggle()
                    } label: {
                        Text("Done").bold()
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: Binding.constant(true))
    }
}
