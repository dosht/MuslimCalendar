//
//  RulesView.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 21.05.2022.
//

import SwiftUI
import CoreData

struct RulesView: View {
    var body: some View {
        NavigationView {
            RulesListView()
        }
    }
}

struct RulesListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    init(referencedBy rule: Rule? = nil) {
        let fetchRequest = NSFetchRequest<Rule>(entityName: "Rule")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Rule.id, ascending: true),
            NSSortDescriptor(keyPath: \Rule.timeInterval, ascending: true)
        ]
        if let rule = rule {
            fetchRequest.predicate = NSPredicate(format: "reference = %@", argumentArray: [rule])
        }
//        fetchRequest.animation = .default
        _rules = FetchRequest(fetchRequest: fetchRequest)
    }
    
    @FetchRequest
    private var rules: FetchedResults<Rule>
    
    @State
    private var showAddRule = false
    
    var body: some View {
        List {
            ForEach(rules) { rule in
                NavigationLink {
                    Text(rule.name!)
                    RulesListView(referencedBy: rule)
                        .toolbar {
#if os(iOS)
                            ToolbarItem(placement: .navigationBarTrailing) {
                                EditButton()
                            }
#endif
                            ToolbarItem {
                                Button(action: { showAddRule = true }) {
                                    Label("Add Item", systemImage: "plus")
                                }
                            }
                        }.sheet(isPresented: $showAddRule) {
                            AddRule(referencedBy: rule)
                        }
                } label: {
                    Text(rule.name!)
                }
            }
        }
    }
}


struct AddRule: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let parentRule: Rule
    
    @State var name: String = ""
    @State var isAfter: Bool = true
    @State  var suggestedDuration: Durations = .half
    
    init(referencedBy rule: Rule) {
        parentRule = rule
    }
    var body: some View {
        Label("Add to \(parentRule.name!)", systemImage: "bolt.fill")
        Section {
            Form {
                Label("Add Event", systemImage: "bolt.fill").font(.largeTitle)
                VStack {
                    TextField("Name", text: $name)
                    Picker("Duration", selection: $suggestedDuration) {
                        ForEach(Durations.allCases) { duration in
                            Text(duration.rawValue.capitalized)
                                .tag(duration)
                        }
                    }
                    .pickerStyle(.segmented)
                    Toggle(isOn: $isAfter) {
                        Text("Before / After")
                    }
                    Divider()
                    Button(action: addRule) {
                        Label("Save", systemImage: "square.and.arrow.down.fill")
                    }
                }
            }
        }
    }
    
    func addRule() {
        let rule = Rule(context: viewContext)
        rule.name = name
        if isAfter {
            rule.timeInterval = Int64(suggestedDuration.timeInterval)
        } else {
            rule.timeInterval = -Int64(suggestedDuration.timeInterval)
        }
        rule.reference = parentRule
        try! viewContext.save()
        presentationMode.wrappedValue.dismiss()
    }
}

struct RulesView_Previews: PreviewProvider {
    static var previews: some View {
        RulesView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
