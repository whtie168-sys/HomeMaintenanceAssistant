//
//  HMAFormatters.swift
//  HomeMaintenanceAssistant
//
//  Shared date / status presentation helpers (UIKit-free).
//

import Foundation

enum HMAFormat {

    static let mediumDate: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    static let monthYear: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f
    }()

    static func HMArelativeDue(_ status: HMAScheduleStatus) -> String {
        switch status {
        case .overdue(let d):
            return d == 1 ? "Overdue by 1 day" : "Overdue by \(d) days"
        case .dueSoon(let d):
            if d == 0 { return "Due today" }
            return d == 1 ? "Due tomorrow" : "Due in \(d) days"
        case .upcoming(let d):
            return "Due in \(d) days"
        case .neverDone:
            return "Not yet logged"
        }
    }
}
