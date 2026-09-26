//
//  HMARecordsViewModel.swift
//  HomeMaintenanceAssistant
//
//  Backs the Records tab (grouped by month) and the create/edit form.
//

import Foundation

struct HMARecordSection {
    let title: String          // e.g. "June 2026"
    var records: [HMARecord]
}

final class HMARecordsViewModel {

    private let db = HMADatabaseManager.shared
    private(set) var sections: [HMARecordSection] = []

    func HMAreload() {
        let records = db.HMAfetchRecords()          // already sorted newest first
        var grouped: [String: [HMARecord]] = [:]
        var order: [String] = []
        for record in records {
            let key = HMAFormat.monthYear.string(from: record.date)
            if grouped[key] == nil {
                grouped[key] = []
                order.append(key)
            }
            grouped[key]?.append(record)
        }
        sections = order.map { HMARecordSection(title: $0, records: grouped[$0] ?? []) }
    }

    // MARK: - Mutations

    @discardableResult
    func HMAdelete(_ record: HMARecord) -> Bool {
        let ok = db.HMAdeleteRecord(id: record.id)
        if ok { HMAreload() }
        return ok
    }
}

// MARK: - Editor

/// Drives the create / edit form. Loads the picklist of tasks once.
final class HMARecordEditViewModel {

    struct HMATaskOption {
        let id: Int
        let title: String
        let areaName: String
    }

    private let db = HMADatabaseManager.shared

    /// nil when creating a new record.
    let existing: HMARecord?
    private(set) var taskOptions: [HMATaskOption] = []

    // Editable state
    var selectedTaskId: Int
    var date: Date
    var result: HMARecordResult
    var notes: String

    init(existing: HMARecord?) {
        self.existing = existing
        self.date = existing?.date ?? Date()
        self.result = existing?.result ?? .completed
        self.notes = existing?.notes ?? ""
        self.selectedTaskId = existing?.taskId ?? 0
    }

    func HMAloadOptions() {
        let areas = db.HMAfetchAreas()
        let areaNames = Dictionary(uniqueKeysWithValues: areas.map { ($0.id, $0.name) })
        taskOptions = db.HMAfetchTasks().map {
            HMATaskOption(id: $0.id, title: $0.title, areaName: areaNames[$0.areaId] ?? "")
        }
        if selectedTaskId == 0, let first = taskOptions.first {
            selectedTaskId = first.id
        }
    }

    var HMAselectedTaskTitle: String {
        taskOptions.first { $0.id == selectedTaskId }
            .map { "\($0.title) · \($0.areaName)" } ?? "Select a task"
    }

    var HMAisValid: Bool { selectedTaskId != 0 }

    @discardableResult
    func HMAsave() -> Bool {
        guard HMAisValid else { return false }
        if let existing = existing {
            return db.HMAupdateRecord(id: existing.id, date: date, result: result, notes: notes)
        } else {
            return db.HMAinsertRecord(taskId: selectedTaskId, date: date, result: result, notes: notes)
        }
    }
}
