import Foundation
import SwiftData

@Model
final class CycleRecord {
    var periodStartDate: Date
    var periodEndDate: Date?
    var cycleLength: Int?
    var notes: String?
    var source: DataSource

    enum DataSource: String, Codable {
        case healthKit
        case manual
        case imported
    }

    init(
        periodStartDate: Date,
        periodEndDate: Date? = nil,
        cycleLength: Int? = nil,
        notes: String? = nil,
        source: DataSource = .manual
    ) {
        self.periodStartDate = periodStartDate
        self.periodEndDate = periodEndDate
        self.cycleLength = cycleLength
        self.notes = notes
        self.source = source
    }
}
