//
//  HMAStatusStyling.swift
//  HomeMaintenanceAssistant
//
//  Maps schedule status and record results onto theme colours and labels.
//  Lives in the view layer so models stay UIKit-free.
//

import UIKit

enum HMAStatusStyling {

    static func HMAcolor(for status: HMAScheduleStatus) -> UIColor {
        switch status {
        case .overdue:   return HMATheme.overdue
        case .dueSoon:   return HMATheme.dueSoon
        case .upcoming:  return HMATheme.completed
        case .neverDone: return HMATheme.secondaryText
        }
    }

    static func HMAcolor(for result: HMARecordResult) -> UIColor {
        switch result {
        case .completed:      return HMATheme.completed
        case .needsAttention: return HMATheme.overdue
        case .scheduled:      return HMATheme.accent
        }
    }

    static func HMAcolor(for difficulty: HMADifficulty) -> UIColor {
        switch difficulty {
        case .easy:     return HMATheme.completed
        case .moderate: return HMATheme.accent
        case .advanced: return HMATheme.overdue
        }
    }

    static func HMAicon(for result: HMARecordResult) -> String {
        switch result {
        case .completed:      return "checkmark.seal.fill"
        case .needsAttention: return "exclamationmark.triangle.fill"
        case .scheduled:      return "calendar.badge.clock"
        }
    }
}
