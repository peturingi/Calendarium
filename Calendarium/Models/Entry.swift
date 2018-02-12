import Cocoa
import EventKit

class Entry: NSObject {
    
    static let LEFT: Character? = nil
    static let RIGHT: Character! = ":"
    
    @objc public var client: String!
    @objc public var details: String!
    @objc public var from: Date!
    @objc public var to: Date!

    @objc public func duration() -> TimeInterval {
        let interval = self.to.timeIntervalSince(self.from)
        assert(interval >= 0)
        return interval
    }

    init(event: EKEvent) {
        assert(event.startDate <= event.endDate)
        
        let client_and_description = Entry.parse(event.title)
        self.client = client_and_description.client
        self.details = client_and_description.description
        self.from = event.startDate
        self.to = event.endDate
    }
    
    /*
    Parses an event's description into a Client and Description.
    Example: The string in the following lines becomes parsed to {Client="My Client", Description = " Fixed a few bugs."}.
    [My Client] Fixed a few bugs.
    */
    private static func parse(_ input: String) -> (client: String, description: String) {
        
        // Is client marked?
        guard LEFT == nil || input.first == LEFT, let projectRightIndex = input.index(of: RIGHT) else {
            return (client: "", description: input)
        }
    
        let projectLeftIndex = LEFT == nil
            ? input.startIndex
            : input.index(after: input.startIndex)
        let client = input[..<projectRightIndex][projectLeftIndex...]
        
        let descriptionLeftIndex = input.index(after: projectRightIndex)
        let description = input[descriptionLeftIndex...].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        return (client: String(client), description: String(description))
    }

}
