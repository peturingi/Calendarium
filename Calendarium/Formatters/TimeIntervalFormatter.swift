import Cocoa

class TimeIntervalFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        guard obj is TimeInterval else {
            return ""
        }
        
        return hhmmStringFromTimeInterval(interval: obj as! TimeInterval)
    }
    
    private func hhmmStringFromTimeInterval(interval: Double) -> String {
        let hours = (Int(interval) / 3600)
        let minutes = Int(interval / 60) - Int(hours * 60)
        return String(format: "%0.2dh %0.2dm",hours,minutes)
    }
}
