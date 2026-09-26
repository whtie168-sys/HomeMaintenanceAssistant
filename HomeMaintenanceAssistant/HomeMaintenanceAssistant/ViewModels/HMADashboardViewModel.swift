//
//  HMADashboardViewModel.swift
//  HomeMaintenanceAssistant
//
//  Aggregates schedule + record data into the dashboard's stat cards
//  and task lists. Reads from the database; holds no UIKit references.
//

import Foundation

struct HMADashboardStats {
    var dueCount = 0
    var overdueCount = 0
    var completedThisMonth = 0
    var recordCount = 0
    var areaCount = 0
}

struct HMADashboardTaskItem {
    let task: HMATask
    let status: HMAScheduleStatus
    let areaName: String
}

final class HMADashboardViewModel {

    private(set) var stats = HMADashboardStats()
    private(set) var upcoming: [HMADashboardTaskItem] = []
    private(set) var overdue: [HMADashboardTaskItem] = []

    private let db = HMADatabaseManager.shared

    func HMAreload() {
        let areas = db.HMAfetchAreas()
        let areaNames = Dictionary(uniqueKeysWithValues: areas.map { ($0.id, $0.name) })
        let tasks = db.HMAfetchTasks()
        let lastDone = db.HMAlastDoneByTask()
        let records = db.HMAfetchRecords()

        var built: [HMADashboardTaskItem] = []
        built.reserveCapacity(tasks.count)
        for task in tasks {
            let status = HMAScheduleEngine.HMAstatus(for: task, lastDone: lastDone[task.id])
            built.append(HMADashboardTaskItem(task: task,
                                              status: status,
                                              areaName: areaNames[task.areaId] ?? ""))
        }

        // Overdue, most overdue first.
        overdue = built
            .filter { if case .overdue = $0.status { return true } else { return false } }
            .sorted { HMAoverdueDays($0.status) > HMAoverdueDays($1.status) }

        // Upcoming = due soon, soonest first.
        upcoming = built
            .filter { if case .dueSoon = $0.status { return true } else { return false } }
            .sorted { HMAdueSoonDays($0.status) < HMAdueSoonDays($1.status) }

        // Stats
        var s = HMADashboardStats()
        s.dueCount = upcoming.count
        s.overdueCount = overdue.count
        s.recordCount = records.count
        s.areaCount = areas.count
        s.completedThisMonth = HMAcompletedThisMonth(records)
        stats = s
    }

    private func HMAcompletedThisMonth(_ records: [HMARecord]) -> Int {
        let cal = Calendar.current
        let now = Date()
        return records.filter { rec in
            rec.result == .completed &&
            cal.isDate(rec.date, equalTo: now, toGranularity: .month)
        }.count
    }

    private func HMAoverdueDays(_ status: HMAScheduleStatus) -> Int {
        if case .overdue(let d) = status { return d }
        return 0
    }

    private func HMAdueSoonDays(_ status: HMAScheduleStatus) -> Int {
        if case .dueSoon(let d) = status { return d }
        return Int.max
    }
}
