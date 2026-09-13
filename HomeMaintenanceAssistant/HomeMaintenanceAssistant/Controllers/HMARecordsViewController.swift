//
//  HMARecordsViewController.swift
//  HomeMaintenanceAssistant
//
//  Maintenance history grouped by month, with create / edit / delete.
//

import UIKit

final class HMARecordsViewController: UIViewController {

    private let viewModel = HMARecordsViewModel()
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Records"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = HMATheme.screenBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(HMAaddRecord))
        HMAsetupTable()
        HMAsetupEmpty()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        HMAreload()
    }

    private func HMAsetupTable() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HMARecordCell.self, forCellReuseIdentifier: HMARecordCell.reuseID)
        view.addSubview(tableView)
        tableView.HMApin(to: view.safeAreaLayoutGuide)
    }

    private func HMAsetupEmpty() {
        emptyLabel.text = "No maintenance records yet.\nTap + to log your first one."
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.font = HMATheme.roundedFont(15, weight: .medium)
        emptyLabel.textColor = HMATheme.secondaryText
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func HMAreload() {
        viewModel.HMAreload()
        let isEmpty = viewModel.sections.isEmpty
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        tableView.reloadData()
    }

    @objc private func HMAaddRecord() {
        let editor = HMARecordEditViewController(prefillTaskId: nil)
        present(UINavigationController(rootViewController: editor), animated: true)
    }

    private func HMAedit(_ record: HMARecord) {
        let editor = HMARecordEditViewController(existing: record)
        present(UINavigationController(rootViewController: editor), animated: true)
    }
}

extension HMARecordsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { viewModel.sections.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sections[section].records.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.sections[section].title
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let label = UILabel()
        label.text = viewModel.sections[section].title.uppercased()
        label.font = HMATheme.roundedFont(12, weight: .bold)
        label.textColor = HMATheme.secondaryText
        label.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: HMATheme.screenInset + 2),
            label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -6),
            label.topAnchor.constraint(equalTo: header.topAnchor, constant: 8)
        ])
        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HMARecordCell.reuseID, for: indexPath) as! HMARecordCell
        cell.HMAconfigure(record: viewModel.sections[indexPath.section].records[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HMAedit(viewModel.sections[indexPath.section].records[indexPath.row])
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let record = viewModel.sections[indexPath.section].records[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            self?.HMAconfirmDelete(record); done(true)
        }
        delete.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [delete])
    }

    private func HMAconfirmDelete(_ record: HMARecord) {
        let alert = UIAlertController(title: "Delete Record?",
                                      message: "This maintenance record will be permanently removed.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel.HMAdelete(record)
            self?.HMAreload()
        })
        present(alert, animated: true)
    }
}
