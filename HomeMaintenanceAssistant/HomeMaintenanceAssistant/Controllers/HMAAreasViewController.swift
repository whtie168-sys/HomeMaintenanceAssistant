//
//  HMAAreasViewController.swift
//  HomeMaintenanceAssistant
//
//  Lists maintenance areas; tapping one drills into its task list.
//

import UIKit

final class HMAAreasViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private var areas: [HMAArea] = []
    private var taskCounts: [Int: Int] = [:]

    /// Called on iPad when an area is selected, to drive the detail column.
    var HMAonSelectArea: ((HMAArea) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Areas"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = HMATheme.screenBackground
        HMAsetupTable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        HMAreload()
    }

    private func HMAsetupTable() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HMAAreaCell.self, forCellReuseIdentifier: HMAAreaCell.reuseID)
        tableView.contentInset.top = 8
        view.addSubview(tableView)
        tableView.HMApin(to: view.safeAreaLayoutGuide)
    }

    private func HMAreload() {
        areas = HMADatabaseManager.shared.HMAfetchAreas()
        taskCounts.removeAll()
        for area in areas {
            taskCounts[area.id] = HMADatabaseManager.shared.HMAfetchTasks(areaId: area.id).count
        }
        tableView.reloadData()
    }
}

extension HMAAreasViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        areas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HMAAreaCell.reuseID, for: indexPath) as! HMAAreaCell
        let area = areas[indexPath.row]
        cell.HMAconfigure(area: area, taskCount: taskCounts[area.id] ?? 0)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let area = areas[indexPath.row]
        if let handler = HMAonSelectArea {
            handler(area)
        } else {
            let vc = HMATaskListViewController(area: area)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
