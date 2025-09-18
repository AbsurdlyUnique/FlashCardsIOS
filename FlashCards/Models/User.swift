import Foundation
import SwiftData

@available(iOS 17.0, *)
@Model
final class User {
    var firstName: String
    // Global response-time calibration (EMA)
    var rtGlobalEMA: Double?
    var rtAlpha: Double?
    var createdAt: Date?
    var updatedAt: Date?
    
    init(firstName: String) {
        self.firstName = firstName
        self.rtGlobalEMA = 0.0
        self.rtAlpha = 0.2
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
