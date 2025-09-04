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
    func scheduleNext(from state: SRSState, grade: CardGrade, now: Date) -> SRSState
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

    public func scheduleNext(from state: SRSState, grade: CardGrade, now: Date) -> SRSState {
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

// MARK: - Engine façade
public final class MasteryEngine {
    public let strategy: SchedulerStrategy

    public init(strategy: SchedulerStrategy = DefaultScheduler()) {
        self.strategy = strategy
    }

    public func nextState(from state: SRSState, grade: CardGrade, now: Date = Date()) -> SRSState {
        strategy.scheduleNext(from: state, grade: grade, now: now)
    }

    public func isDue(_ state: SRSState, at date: Date = Date()) -> Bool {
        guard !state.suspended else { return false }
        if let buried = state.buriedUntil, buried > date { return false }
        guard let due = state.nextReview else { return true }
        return due <= date
    }
}
