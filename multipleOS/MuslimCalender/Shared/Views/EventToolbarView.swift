
//  EventToolbar.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 26.08.2022.
//

import SwiftUI

struct EventToolbarView: View {
    @ObservedObject
    var viewModel: EventToolbarViewModel
    
    init(zip2Event: Binding<Zip2Event?>) {
        viewModel = EventToolbarViewModel(zip2Event: zip2Event)
    }
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    print("clock")
                } label: {
                    Label("", systemImage: "clock")
                }
                .padding()
                Button {
                    print("calendar")
                } label: {
                    Label("", systemImage: "calendar")
                }
                .padding()
                Button {
                    print("alarm")
                } label: {
                    Label("", systemImage: "alarm")
                }
                .padding()
                Button {
                    print("flag")
                } label: {
                    Label("", systemImage: "flag")
                }
                .padding()
            }
            .padding()
            .foregroundColor(.black)
            .font(.title3)
        }
    }
}

//struct EventToolbar_Previews: PreviewProvider {
//    static var previews: some View {
//
//    }
//}
