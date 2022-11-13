//
//  CityView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 13.11.2022.
//

import SwiftUI

struct CityView: View {
    @Binding
    var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Text("Search")
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

struct CityView_Previews: PreviewProvider {
    static var previews: some View {
        CityView(isPresented: Binding.constant(true))
    }
}
