import Cocoa
import EventKit
import EventKit.EKTypes

class ViewController: NSViewController {
    
    let CELL_REUSE_IDENTIFIER = "EntryCell"
    
    @objc dynamic var entries = [Entry]()
    @IBOutlet var tb: NSTableView!
    @IBOutlet var entriesArrayController: NSArrayController!
    @IBOutlet var totalTimeFormatter: TimeIntervalFormatter!
    
    @objc dynamic var sum: String! = "Total:"
    
    var store: EKEventStore!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        store = EKEventStore()
        store.requestAccess(to: EKEntityType.event, completion:
            {(granted, error) in
                if !granted {
                    print("Access to store not granted")
                }
        })
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchEvents),
                                               name: .EKEventStoreChanged,
                                               object: store)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateTotalDuration),
                                               name: .EKEventStoreChanged,
                                               object: store)
        fetchEvents()
        updateTotalDuration()
    }

    
    @objc func fetchEvents() {
        func sameMonth(a: Date, b: Date) -> Bool {
            let equalMonths: Bool = NSCalendar.current.compare(a, to: b, toGranularity: .month) == .orderedSame
            let equalYears: Bool = NSCalendar.current.compare(a, to: b, toGranularity: .year) == .orderedSame
            return equalMonths && equalYears
        }
        
        let calendars:Array<EKCalendar> = store.calendars(for: .event)
        let calendar = calendars.first(where: {$0.title == "log"}) ?? EKCalendar()
        
        let oneMonthAgo = NSDate(timeIntervalSinceNow: -365*24*3600)
        let oneMonthAfter = NSDate(timeIntervalSinceNow: +30*24*3600)
        let predicate: NSPredicate = store.predicateForEvents(withStart: oneMonthAgo as Date,
                                                              end: oneMonthAfter as Date,
                                                              calendars: [calendar])
        
        entries.removeAll()
        for event: EKEvent in store.events(matching: predicate) {
            let entry = Entry(event: event)
            
            // Insert seperator entry between months.
            /*
             if let last = self.entries.last as? Entry, !sameMonth(a: last.From, b: entry.From) {
                self.entries.append(Seperator())
            }
             */
            
            self.entries.append(entry)
        }
        
        tb.reloadData()
    }
    
    @objc func updateTotalDuration() {
        let totalDuration = entries.map({$0.duration()}).reduce(0, +)
        self.sum = self.totalTimeFormatter.string(for: totalDuration)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}
