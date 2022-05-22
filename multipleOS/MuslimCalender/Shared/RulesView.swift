//
//  RulesView.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 21.05.2022.
//

import SwiftUI
import CoreData

struct RulesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Rule.id, ascending: true),
            NSSortDescriptor(keyPath: \Rule.timeInterval, ascending: true)
    ], animation: .default)
    private var rules: FetchedResults<Rule>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(rules) { rule in
                    NavigationLink {
                        Text(rule.name!)
                    } label: {
                        Text(rule.name!)
                    }
                }
            }
        }
    }
}

struct RulesView_Previews: PreviewProvider {
    static var previews: some View {
        RulesView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
