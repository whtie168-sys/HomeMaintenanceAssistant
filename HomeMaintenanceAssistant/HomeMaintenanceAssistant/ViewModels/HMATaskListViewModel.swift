//
//  HMATaskListViewModel.swift
//  HomeMaintenanceAssistant
//
//  Backs the Tasks tab and the per-Area task list. Supports search and
//  difficulty filtering, and annotates each task with schedule status.
//

import Foundation

struct HMATaskListItem {
    let task: HMATask
    let status: HMAScheduleStatus
    let areaName: String
}

final class HMATaskListViewModel {

    /// nil = all areas (Tasks tab); set = single Area detail.
    private let areaId: Int?
    private let db = HMADatabaseManager.shared

    private var allItems: [HMATaskListItem] = []
    private(set) var items: [HMATaskListItem] = []

    var searchText: String = "" { didSet { HMAapplyFilters() } }
    var difficultyFilter: HMADifficulty? { didSet { HMAapplyFilters() } }

    init(areaId: Int? = nil) {
        self.areaId = areaId
    }

    func HMAreload() {
        let areas = db.HMAfetchAreas()
        let areaNames = Dictionary(uniqueKeysWithValues: areas.map { ($0.id, $0.name) })
        let tasks = db.HMAfetchTasks(areaId: areaId)
        let lastDone = db.HMAlastDoneByTask()

        allItems = tasks.map { task in
            HMATaskListItem(task: task,
                            status: HMAScheduleEngine.HMAstatus(for: task, lastDone: lastDone[task.id]),
                            areaName: areaNames[task.areaId] ?? "")
        }
        HMAapplyFilters()
    }

    private func HMAapplyFilters() {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        items = allItems.filter { item in
            let matchesQuery = query.isEmpty
                || item.task.title.lowercased().contains(query)
                || item.task.detail.lowercased().contains(query)
                || item.areaName.lowercased().contains(query)
            let matchesDifficulty = difficultyFilter == nil
                || item.task.difficulty == difficultyFilter
            return matchesQuery && matchesDifficulty
        }
    }
}
