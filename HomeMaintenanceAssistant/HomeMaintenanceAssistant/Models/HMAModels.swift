//
//  HMAModels.swift
//  HomeMaintenanceAssistant
//
//  Plain value types mirroring the SQLite schema.
//

import Foundation

// MARK: - Difficulty

enum HMADifficulty: String, CaseIterable {
    case easy = "Easy"
    case moderate = "Moderate"
    case advanced = "Advanced"

    var HMAorder: Int {
        switch self {
        case .easy: return 0
        case .moderate: return 1
        case .advanced: return 2
        }
    }

    static func HMAfrom(_ raw: String?) -> HMADifficulty {
        HMADifficulty(rawValue: raw ?? "") ?? .easy
    }
}

// MARK: - Frequency

/// Recommended cadence for a maintenance task, stored as a day interval
/// so scheduling math stays simple and fully offline.
enum HMAFrequency: String, CaseIterable {
    case monthly = "Every Month"
    case quarterly = "Every 3 Months"
    case biannual = "Every 6 Months"
    case annual = "Every Year"
    case seasonal = "Seasonally"

    var HMAdays: Int {
        switch self {
        case .monthly: return 30
        case .quarterly: return 90
        case .biannual: return 182
        case .annual: return 365
        case .seasonal: return 90
        }
    }

    static func HMAfrom(_ raw: String?) -> HMAFrequency {
        HMAFrequency(rawValue: raw ?? "") ?? .quarterly
    }
}

// MARK: - Area

struct HMAArea {
    let id: Int
    let name: String
    /// SF Symbol name used for the area glyph.
    let icon: String
}

// MARK: - Task

struct HMATask {
    let id: Int
    let areaId: Int
    let title: String
    let detail: String
    let difficulty: HMADifficulty
    let frequency: HMAFrequency
    /// Estimated time in minutes.
    let estimatedMinutes: Int
    let tools: String
    let safety: String
    /// Newline-separated ordered steps.
    let procedure: String

    var HMAprocedureSteps: [String] {
        procedure
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    var HMAestimatedTimeText: String {
        if estimatedMinutes >= 60 {
            let h = estimatedMinutes / 60
            let m = estimatedMinutes % 60
            return m == 0 ? "\(h) hr" : "\(h) hr \(m) min"
        }
        return "\(estimatedMinutes) min"
    }
}

// MARK: - Maintenance result

enum HMARecordResult: String, CaseIterable {
    case completed = "Completed"
    case needsAttention = "Needs Attention"
    case scheduled = "Scheduled"
}

// MARK: - Record

struct HMARecord {
    var id: Int
    var taskId: Int
    /// Stored as epoch seconds in SQLite.
    var date: Date
    var result: HMARecordResult
    var notes: String

    // Joined display fields (populated by queries, not persisted directly).
    var taskTitle: String = ""
    var areaName: String = ""
}

// MARK: - Schedule status (derived, never stored)

enum HMAScheduleStatus {
    case overdue(byDays: Int)
    case dueSoon(inDays: Int)
    case upcoming(inDays: Int)
    case neverDone
}
