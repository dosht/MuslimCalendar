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
            Form {
                Text("Calendar")
                Text("Calculation Method")
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
