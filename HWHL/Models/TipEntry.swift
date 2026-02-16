import Foundation
import SwiftData

@Model
final class TipEntry {
    var title: String
    var body: String
    var phase: String // CyclePhase rawValue
    var category: String
    var lastShownDate: Date?

    init(title: String, body: String, phase: String, category: String, lastShownDate: Date? = nil) {
        self.title = title
        self.body = body
        self.phase = phase
        self.category = category
        self.lastShownDate = lastShownDate
    }
}
