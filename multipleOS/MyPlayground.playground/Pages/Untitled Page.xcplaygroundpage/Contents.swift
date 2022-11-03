//import EventKit
//
//func requestPermissionAndCreateEventStore() -> EKEventStore {
//    let eventStore = EKEventStore()
//    switch EKEventStore.authorizationStatus(for: .event) {
//    case .notDetermined:
//        eventStore.requestAccess(to: .event, completion: { (success, error) in
//            if success {
//                print("success")
//            } else {
//                print("error while requesting permession \(String(describing: error?.localizedDescription))")
//            }
//        })
//    case .restricted:
//        print("restriced")
//    case .denied:
//        print("denied")
//    case .authorized:
//        print("authorized")
//    @unknown default:
//        print("unkown")
//    }
//    return eventStore
//}
//
//var muslimCalender: EKCalendar {
//    let calendars = ekEventStore.calendars(for: .event)
//    if let calendar = calendars.first(where: { cal in cal.title == "Muslim Calendar" }) {
//        return calendar
//    } else {
//        let source = ekEventStore.sources.first
//        let calendar = EKCalendar(for: .event, eventStore: ekEventStore)
//        calendar.source = source
//        calendar.title = "Muslim Calendar"
//        try! ekEventStore.saveCalendar(calendar, commit: true)
//        return calendar
//    }
//}
//
//extension Date {
//    var startOfDay: Date {
//        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
//    }
//    var endOfDay: Date {
//        return Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
//    }
//    var tomorrow: Date {
//        return Date(timeInterval: 1, since: endOfDay)
//    }
//}
//
//var ekEventStore = requestPermissionAndCreateEventStore()
//
//print("HI")
////let predicate = ekEventStore.predicateForEvents(withStart: Date().startOfDay, end: Date().endOfDay, calendars: [muslimCalender])
////let events = ekEventStore.events(matching: predicate)
//
//protocol LinkedListNode {
//    var value: Int { get }
//    var next: LinkedListNode? { get }
//}
//
////struct Node: LinkedListNode {
////    let value: Int
////    let next: LinkedListNode?
////    let n: Node
////}
////
////let x = Node(value: 2, next: Node(value: 4, next: nil))
////print(x)
//
//let index = Calendar.current.component(.weekday, from: Date()) // this returns an Int
//print(Calendar.current.weekdaySymbols[index - 1])
//
