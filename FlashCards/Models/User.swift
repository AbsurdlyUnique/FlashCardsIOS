import Foundation
import SwiftData

@available(iOS 17.0, *)
@Model
final class User {
    var firstName: String
    
    init(firstName: String) {
        self.firstName = firstName
    }
}
