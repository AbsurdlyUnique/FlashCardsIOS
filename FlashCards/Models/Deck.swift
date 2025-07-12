import Foundation
import SwiftData

@available(iOS 17.0, *)
@Model
public final class Deck {
    public var id: UUID
    public var title: String
    public var deckDescription: String?
    public var cards: [Card]
    public var progress: Double
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(title: String, deckDescription: String? = nil) {
        self.id = UUID()
        self.title = title
        self.deckDescription = deckDescription
        self.cards = []
        self.progress = 0.0
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

@available(iOS 17.0, *)
@Model
public final class Card {
    public var id: UUID
    public var question: String
    public var answer: String
    public var hint: String?
    public var lastReviewed: Date?
    public var nextReview: Date?
    public var reviewCount: Int
    public var interval: Double
    public var easeFactor: Double
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(question: String, answer: String, hint: String? = nil) {
        self.id = UUID()
        self.question = question
        self.answer = answer
        self.hint = hint
        self.lastReviewed = nil
        self.nextReview = nil
        self.reviewCount = 0
        self.interval = 1.0
        self.easeFactor = 2.5
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
