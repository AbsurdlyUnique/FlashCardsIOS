import Foundation
import SwiftData

@available(iOS 17.0, *)
struct SRSMapper {
    static func state(from card: Card) -> SRSState {
        SRSState(
            reviewCount: card.reviewCount,
            intervalDays: card.interval,
            ease: card.easeFactor,
            difficulty: card.difficulty,
            stability: card.stability,
            lapses: card.lapses,
            lastGrade: card.lastGradeRaw.flatMap { CardGrade(rawValue: $0) },
            lastReviewed: card.lastReviewed,
            nextReview: card.nextReview,
            suspended: card.suspended,
            buriedUntil: card.buriedUntil
        )
    }

    static func apply(_ newState: SRSState, to card: Card) {
        card.reviewCount = newState.reviewCount
        card.interval = newState.intervalDays
        card.easeFactor = newState.ease
        card.difficulty = newState.difficulty
        card.stability = newState.stability
        card.lapses = newState.lapses
        card.lastReviewed = newState.lastReviewed
        card.nextReview = newState.nextReview
        card.suspended = newState.suspended
        card.buriedUntil = newState.buriedUntil
        card.lastGradeRaw = newState.lastGrade?.rawValue
        card.updatedAt = Date()
    }
}
