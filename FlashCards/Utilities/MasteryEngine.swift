// MasteryEngine.swift
// FlashCards
// A modular spaced-repetition engine with pluggable strategies.

import Foundation

// MARK: - Grades
public enum CardGrade: Int, Codable, CaseIterable {
    case again = 0   // complete failure
    case hard = 1    // barely recalled
    case good = 2    // correct with some effort
    case easy = 3    // instant recall
}

// MARK: - Card State interfacing
public struct SRSState: Codable, Equatable {
    public var reviewCount: Int
    public var intervalDays: Double
    public var ease: Double
    public var difficulty: Double
    public var stability: Double
    public var lapses: Int
    public var lastGrade: CardGrade?
    public var lastReviewed: Date?
    public var nextReview: Date?
    public var suspended: Bool
    public var buriedUntil: Date?

    public init(reviewCount: Int = 0,
                intervalDays: Double = 0,
                ease: Double = 2.5,
                difficulty: Double = 0.3,
                stability: Double = 0.0,
                lapses: Int = 0,
                lastGrade: CardGrade? = nil,
                lastReviewed: Date? = nil,
                nextReview: Date? = nil,
                suspended: Bool = false,
                buriedUntil: Date? = nil) {
        self.reviewCount = reviewCount
        self.intervalDays = intervalDays
        self.ease = ease
        self.difficulty = difficulty
        self.stability = stability
        self.lapses = lapses
        self.lastGrade = lastGrade
        self.lastReviewed = lastReviewed
        self.nextReview = nextReview
        self.suspended = suspended
        self.buriedUntil = buriedUntil
    }
}

// MARK: - Protocol for strategies
public protocol SchedulerStrategy {
    func scheduleNext(from state: SRSState, grade: CardGrade, now: Date, observedRetrievability: Double?) -> SRSState
}

// MARK: - Default Strategy (Hybrid SM2/FSRS-inspired)
public final class DefaultScheduler: SchedulerStrategy {
    public init() {}

    // Tunable parameters
    private let minEase: Double = 1.3
    private let maxEase: Double = 2.7
    private let easeDeltaHard: Double = -0.10
    private let easeDeltaGood: Double = 0.0
    private let easeDeltaEasy: Double = 0.08

    private let baseStabilityGain: Double = 0.35
    private let hardPenalty: Double = 0.70
    private let againPenalty: Double = 0.40
    private let maxStability: Double = 5.0

    // Growth constraints
    private let maxGrowthPerReview: Double = 2.5
    private let maxIntervalDaysCap: Double = 365.0 // 1 year cap

    public func scheduleNext(from state: SRSState, grade: CardGrade, now: Date, observedRetrievability: Double?) -> SRSState {
        let s = state
        var ease = s.ease

        // Update ease based on grade
        switch grade {
        case .again:
            ease = max(minEase, ease + easeDeltaHard * 2)
        case .hard:
            ease = max(minEase, ease + easeDeltaHard)
        case .good:
            ease = min(maxEase, ease + easeDeltaGood)
        case .easy:
            ease = min(maxEase, ease + easeDeltaEasy)
        }

        // Update difficulty in [0,1] where lower = easier
        let targetDifficulty: Double
        switch grade {
        case .again: targetDifficulty = min(1.0, s.difficulty + 0.25)
        case .hard:  targetDifficulty = min(1.0, s.difficulty + 0.12)
        case .good:  targetDifficulty = max(0.0, s.difficulty - 0.08)
        case .easy:  targetDifficulty = max(0.0, s.difficulty - 0.18)
        }

        // Update stability (memory strength) — keep additive and bounded to avoid runaway
        var stability = max(0.0, s.stability)
        let stabilityGain = baseStabilityGain * (1.0 - targetDifficulty)
        switch grade {
        case .again:
            stability = max(0.05, stability * againPenalty)
        case .hard:
            stability = max(0.08, stability * hardPenalty + stabilityGain * 0.5)
        case .good:
            stability = stability + stabilityGain
        case .easy:
            stability = stability + stabilityGain * 1.2
        }
        stability = min(stability, maxStability)

        // Compute next interval in days using bounded growth
        let intervalDays: Double
        if s.reviewCount < 2 {
            // Learning steps: keep initial intervals small and predictable
            switch grade {
            case .again:
                intervalDays = 0.0 // will be scheduled in minutes below
            case .hard:
                intervalDays = 0.5 // ~12 hours
            case .good:
                intervalDays = 1.0
            case .easy:
                intervalDays = 3.0
            }
        } else {
            let base = max(1.0, s.intervalDays)
            // Raw growth influenced by ease and stability, but clamped
            var rawGrowth = 1.0 + (ease - 1.0) * 0.4 + stability * 0.10
            // Minimum growth per grade to avoid stagnation
            let minGrowth: Double
            switch grade {
            case .again:
                rawGrowth = 0.4 // shrink interval substantially
                minGrowth = 0.2
            case .hard:
                minGrowth = 1.05
            case .good:
                minGrowth = 1.20
            case .easy:
                minGrowth = 1.60
            }
            rawGrowth = max(minGrowth, min(rawGrowth, maxGrowthPerReview))
            intervalDays = min(maxIntervalDaysCap, base * rawGrowth)
        }

        // Lapses if failed
        let lapses = s.lapses + (grade == .again ? 1 : 0)

        // Prepare next state
        var next = s
        next.reviewCount = s.reviewCount + 1
        next.intervalDays = intervalDays
        next.ease = ease
        next.difficulty = targetDifficulty
        next.stability = stability
        next.lapses = lapses
        next.lastGrade = grade
        next.lastReviewed = now
        // Support sub-day intervals by using minutes when interval < 1 day
        if intervalDays < 1.0 {
            let minutes = max(1, Int(ceil(intervalDays * 24.0 * 60.0)))
            next.nextReview = Calendar.current.date(byAdding: .minute, value: minutes, to: now)
        } else {
            next.nextReview = Calendar.current.date(byAdding: .day, value: Int(ceil(intervalDays)), to: now)
        }
        next.suspended = s.suspended
        next.buriedUntil = nil

        return next
    }
}

// MARK: - Advanced Strategy (FSRS-inspired, professional-grade)
public final class AdvancedScheduler: SchedulerStrategy {
    public init() {}

    // Target retention and bounds
    private let targetRetention: Double = 0.90 // desired recall probability at next review
    private let minEase: Double = 1.2
    private let maxEase: Double = 2.8
    private let maxStability: Double = 3650.0 // up to ~10 years
    private let maxIntervalDaysCap: Double = 3650.0

    // Grade deltas for ease and difficulty
    private let easeDelta: [CardGrade: Double] = [
        .again: -0.20,
        .hard: -0.08,
        .good: 0.00,
        .easy: 0.06
    ]
    private let difficultyDelta: [CardGrade: Double] = [
        .again: +0.20,
        .hard: +0.10,
        .good: -0.06,
        .easy: -0.15
    ]

    // Multipliers guiding stability growth by grade
    private let gradeStabilityMultiplier: [CardGrade: Double] = [
        .again: 0.40,  // reset-like penalty
        .hard: 1.10,
        .good: 1.40,
        .easy: 1.80
    ]

    public func scheduleNext(from state: SRSState, grade: CardGrade, now: Date, observedRetrievability: Double?) -> SRSState {
        let s = state

        // Derive elapsed time since last review in days (for retrievability)
        let tDays: Double
        if let last = s.lastReviewed {
            tDays = max(0.0, now.timeIntervalSince(last) / 86400.0)
        } else {
            tDays = 0.0
        }

        // Update ease and difficulty first
        var ease = s.ease
        ease = min(maxEase, max(minEase, ease + (easeDelta[grade] ?? 0)))
        var difficulty = s.difficulty
        difficulty = min(1.0, max(0.0, difficulty + (difficultyDelta[grade] ?? 0)))

        // Compute current retrievability R in [0,1]
        // R(t) = exp( ln(targetRetention) * t / S ) with S>0. If S ~ 0 (new card), set R to targetRetention.
        let S = max(0.01, s.stability)
        let logTarget = log(targetRetention)
        let computedR: Double = s.reviewCount == 0 ? targetRetention : exp(logTarget * tDays / S)
        // Use observed retrievability (from response time) if provided; otherwise use computed
        let retrievability: Double = min(0.999, max(0.001, observedRetrievability ?? computedR))

        // Learning steps for first 1-2 reviews: predictable, small intervals to behave well on tiny decks
        let learningPhase = s.reviewCount < 2
        var newStability: Double
        var intervalDays: Double

        if grade == .again {
            // Lapse handling: strong penalty on stability, immediate relearn
            newStability = max(0.05, s.stability * 0.40)
            intervalDays = 0.0 // minutes later (handled below)
        } else if learningPhase {
            // Keep early steps consistent to avoid over-spacing small decks
            switch grade {
            case .hard:
                newStability = max(0.10, s.stability + (1.0 - difficulty) * 0.20)
                intervalDays = 0.5 // ~12h
            case .good:
                newStability = max(0.15, s.stability + (1.0 - difficulty) * 0.35)
                intervalDays = 1.0
            case .easy:
                newStability = max(0.20, s.stability + (1.0 - difficulty) * 0.50)
                intervalDays = 3.0
            default:
                newStability = max(0.05, s.stability * 0.40)
                intervalDays = 0.0
            }
        } else {
            // Review phase: FSRS-inspired update of stability using retrievability feedback
            // Lower R (closer to failure) should lead to higher learning from success, bounded
            let learningGain = (1.0 - difficulty) * (0.6 + 0.8 * max(0.0, 1.0 - retrievability))
            let multiplier = gradeStabilityMultiplier[grade] ?? 1.0
            newStability = min(maxStability, max(0.05, s.stability * (1.0 + learningGain * multiplier / 6.0)))

            // Solve for interval such that next review is at target retention
            // Using R(t) = exp( ln(targetRetention) * t / S_new ) => set R = targetRetention => t = S_new
            var proposed = newStability
            // Grade-specific adjustments (easy pushes further, hard pulls closer)
            switch grade {
            case .hard: proposed *= 0.85
            case .good: proposed *= 1.00
            case .easy: proposed *= 1.30
            case .again: proposed = 0.0
            }
            // Keep monotonic growth relative to previous interval
            let base = max(1.0, s.intervalDays)
            proposed = max(grade == .hard ? base * 1.05 : base * 1.15, proposed)
            intervalDays = min(maxIntervalDaysCap, proposed)
        }

        // Cap stability
        newStability = min(newStability, maxStability)

        // Build next state
        var next = s
        next.reviewCount = s.reviewCount + 1
        next.intervalDays = intervalDays
        next.ease = ease
        next.difficulty = difficulty
        next.stability = newStability
        next.lapses = s.lapses + (grade == .again ? 1 : 0)
        next.lastGrade = grade
        next.lastReviewed = now
        if intervalDays < 1.0 {
            let minutes = max(1, Int(ceil(intervalDays * 24.0 * 60.0)))
            next.nextReview = Calendar.current.date(byAdding: .minute, value: minutes, to: now)
        } else {
            next.nextReview = Calendar.current.date(byAdding: .day, value: Int(ceil(intervalDays)), to: now)
        }
        next.suspended = s.suspended
        next.buriedUntil = nil
        return next
    }
}

// MARK: - Engine façade
public final class MasteryEngine {
    public let strategy: SchedulerStrategy

    public init(strategy: SchedulerStrategy = AdvancedScheduler()) {
        self.strategy = strategy
    }

    public func nextState(from state: SRSState, grade: CardGrade, now: Date = Date()) -> SRSState {
        // Backwards-compatible API: no observed retrievability
        strategy.scheduleNext(from: state, grade: grade, now: now, observedRetrievability: nil)
    }

    public func nextState(from state: SRSState, grade: CardGrade, now: Date = Date(), observedRetrievability: Double?) -> SRSState {
        strategy.scheduleNext(from: state, grade: grade, now: now, observedRetrievability: observedRetrievability)
    }

    public func isDue(_ state: SRSState, at date: Date = Date()) -> Bool {
        guard !state.suspended else { return false }
        if let buried = state.buriedUntil, buried > date { return false }
        guard let due = state.nextReview else { return true }
        return due <= date
    }
}
