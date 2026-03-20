import Foundation
import SwiftData

@Model
final class SleepEntry {
    var bedtime: Date
    var wakeTime: Date
    var notes: String

    var duration: TimeInterval {
        wakeTime.timeIntervalSince(bedtime)
    }

    var durationFormatted: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    init(bedtime: Date, wakeTime: Date, notes: String = "") {
        self.bedtime = bedtime
        self.wakeTime = wakeTime
        self.notes = notes
    }
}
