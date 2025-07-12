import Foundation
import SwiftData

@Model
final class User {
    var firstName: String
    
    init(firstName: String) {
        self.firstName = firstName
    }
}
