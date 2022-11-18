//
//  CityView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 13.11.2022.
//

import SwiftUI
import CoreLocation
import Combine

class CityViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Binding(s)
    @Binding var isPresented: Bool
    
    // MARK: - Publisher(s)
    @Published var cityName: String = ""
    
    init(_ isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }
    
    // MARK: - Intent(s)
    func done() {
        isPresented = false
    }
}

struct CityView: View {
    @ObservedObject var vm: CityViewModel
    
    init(isPresented: Binding<Bool>) {
        vm = CityViewModel(isPresented)
    }
    
    var body: some View {
        NavigationView {
            Text("Search")
            .navigationBarTitle("City", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        vm.done()
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
