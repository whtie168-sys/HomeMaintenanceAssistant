//
//  HMAScheduleEngine.swift
//  HomeMaintenanceAssistant
//
//  Pure scheduling math shared by the view models. Given a task's frequency
//  and its last completed date, derives whether it is overdue / due soon.
//

import Foundation

enum HMAScheduleEngine {

    /// Window (in days) before the due date that counts as "due soon".
    static let dueSoonWindow = 14

    static func HMAstatus(for task: HMATask, lastDone: Date?) -> HMAScheduleStatus {
        guard let lastDone = lastDone else { return .neverDone }
        let due = lastDone.addingTimeInterval(Double(task.frequency.HMAdays) * 86_400)
        let secondsLeft = due.timeIntervalSinceNow
        let daysLeft = Int((secondsLeft / 86_400).rounded())
        if daysLeft < 0 {
            return .overdue(byDays: -daysLeft)
        } else if daysLeft <= dueSoonWindow {
            return .dueSoon(inDays: daysLeft)
        } else {
            return .upcoming(inDays: daysLeft)
        }
    }

    /// Next due date for a task, or nil if it has never been completed.
    static func HMAnextDue(for task: HMATask, lastDone: Date?) -> Date? {
        guard let lastDone = lastDone else { return nil }
        return lastDone.addingTimeInterval(Double(task.frequency.HMAdays) * 86_400)
    }
}
