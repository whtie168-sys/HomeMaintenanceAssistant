//
//  HMATaskListViewController.swift
//  HomeMaintenanceAssistant
//
//  Shared list screen for the Tasks tab (all tasks) and Area detail
//  (one area). Supports search and a difficulty filter.
//

import UIKit

final class HMATaskListViewController: UIViewController {

    private let viewModel: HMATaskListViewModel
    private let showsArea: Bool
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchController = UISearchController(searchResultsController: nil)
    private let filterControl = UISegmentedControl(items: ["All", "Easy", "Moderate", "Advanced"])

    init(area: HMAArea? = nil) {
        self.viewModel = HMATaskListViewModel(areaId: area?.id)
        self.showsArea = (area == nil)
        super.init(nibName: nil, bundle: nil)
        self.title = area?.name ?? "Tasks"
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = HMATheme.screenBackground
        HMAsetupSearch()
        HMAsetupFilter()
        HMAsetupTable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.HMAreload()
        tableView.reloadData()
    }

    private func HMAsetupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search tasks"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func HMAsetupFilter() {
        filterControl.selectedSegmentIndex = 0
        filterControl.selectedSegmentTintColor = HMATheme.accent
        filterControl.addTarget(self, action: #selector(HMAfilterChanged), for: .valueChanged)
    }

    private func HMAsetupTable() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 56))
        filterControl.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(filterControl)
        NSLayoutConstraint.activate([
            filterControl.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: HMATheme.screenInset),
            filterControl.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -HMATheme.screenInset),
            filterControl.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ])

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 110
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = header
        tableView.register(HMATaskCell.self, forCellReuseIdentifier: HMATaskCell.reuseID)
        view.addSubview(tableView)
        tableView.HMApin(to: view.safeAreaLayoutGuide)
        header.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
    }

    @objc private func HMAfilterChanged() {
        switch filterControl.selectedSegmentIndex {
        case 1: viewModel.difficultyFilter = .easy
        case 2: viewModel.difficultyFilter = .moderate
        case 3: viewModel.difficultyFilter = .advanced
        default: viewModel.difficultyFilter = nil
        }
        tableView.reloadData()
    }
}

extension HMATaskListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        max(viewModel.items.count, 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HMATaskCell.reuseID, for: indexPath) as! HMATaskCell
        cell.HMAconfigure(item: viewModel.items[indexPath.row], showArea: showsArea)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = viewModel.items[indexPath.row].task
        navigationController?.pushViewController(HMATaskDetailViewController(task: task), animated: true)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard viewModel.items.isEmpty else { return nil }
        let label = UILabel()
        label.text = "No tasks match your search."
        label.textColor = HMATheme.secondaryText
        label.font = HMATheme.roundedFont(15, weight: .medium)
        label.textAlignment = .center
        return label
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        viewModel.items.isEmpty ? 60 : 0
    }
}

extension HMATaskListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchText = searchController.searchBar.text ?? ""
        tableView.reloadData()
    }
}
