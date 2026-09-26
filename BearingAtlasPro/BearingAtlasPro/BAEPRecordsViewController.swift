//
//  RecordsViewController.swift
//  Bearing Atlas Pro
//
//  Tab 4 — read-only log of completed workflow closures.
//  Every record references a fault_id and is created from a fault session.
//

import UIKit

final class BAEPRecordsViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private var records: [BAEPServiceRecord] = []
    private var faultNames: [Int: String] = [:]
    private var faultSeverity: [Int: String] = [:]
    private let emptyState = BAEPEmptyStateView(
        symbol: "tray",
        title: "No Records Yet",
        message: "Records are created by closing a fault workflow. Open a fault to begin.")

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Records"
        view.backgroundColor = BAEPTheme.navy
        navigationController?.navigationBar.prefersLargeTitles = true
        configureTable()
        configureEmpty()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    private func reload() {
        let faults = BAEPDatabaseManager.shared.fetchFaults()
        faultNames = Dictionary(uniqueKeysWithValues: faults.map { ($0.id, $0.name) })
        faultSeverity = Dictionary(uniqueKeysWithValues: faults.map { ($0.id, $0.severity) })
        records = BAEPDatabaseManager.shared.fetchRecords()
        emptyState.isHidden = !records.isEmpty
        tableView.isHidden = records.isEmpty
        tableView.reloadData()
    }

    private func configureTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = BAEPTheme.navy
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 110
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
        tableView.register(BAEPRecordCell.self, forCellReuseIdentifier: BAEPRecordCell.reuseID)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func configureEmpty() {
        emptyState.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyState)
        NSLayoutConstraint.activate([
            emptyState.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyState.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyState.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyState.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

extension BAEPRecordsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        records.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BAEPRecordCell.reuseID, for: indexPath) as! BAEPRecordCell
        let r = records[indexPath.row]
        cell.configure(record: r,
                       faultName: faultNames[r.faultId] ?? "Unknown Fault",
                       severity: faultSeverity[r.faultId] ?? "")
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            guard let self = self else { done(false); return }
            let id = self.records[indexPath.row].id
            BAEPDatabaseManager.shared.deleteRecord(id: id)
            self.reload()
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

// MARK: - Record Cell

final class BAEPRecordCell: UITableViewCell {

    static let reuseID = "BAEPRecordCell"

    private let card = UIView()
    private let motorLabel = UILabel()
    private let faultLabel = UILabel()
    private let dateLabel = UILabel()
    private let statusDot = UIView()
    private let resultLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        build()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func build() {
        card.translatesAutoresizingMaskIntoConstraints = false
        card.applyCardStyle()
        contentView.addSubview(card)

        motorLabel.translatesAutoresizingMaskIntoConstraints = false
        motorLabel.font = BAEPTheme.font(17, .bold)
        motorLabel.textColor = BAEPTheme.textPrimary
        motorLabel.numberOfLines = 1

        faultLabel.translatesAutoresizingMaskIntoConstraints = false
        faultLabel.font = BAEPTheme.mono(11, .medium)
        faultLabel.textColor = BAEPTheme.orange
        faultLabel.numberOfLines = 1

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = BAEPTheme.mono(11)
        dateLabel.textColor = BAEPTheme.textMuted

        statusDot.translatesAutoresizingMaskIntoConstraints = false
        statusDot.layer.cornerRadius = 4

        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        resultLabel.font = BAEPTheme.mono(12, .bold)

        card.addSubview(motorLabel)
        card.addSubview(faultLabel)
        card.addSubview(dateLabel)
        card.addSubview(statusDot)
        card.addSubview(resultLabel)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: BAEPTheme.pad),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -BAEPTheme.pad),

            motorLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            motorLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            motorLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            faultLabel.topAnchor.constraint(equalTo: motorLabel.bottomAnchor, constant: 4),
            faultLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            faultLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            statusDot.topAnchor.constraint(equalTo: faultLabel.bottomAnchor, constant: 10),
            statusDot.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            statusDot.widthAnchor.constraint(equalToConstant: 8),
            statusDot.heightAnchor.constraint(equalToConstant: 8),

            resultLabel.centerYAnchor.constraint(equalTo: statusDot.centerYAnchor),
            resultLabel.leadingAnchor.constraint(equalTo: statusDot.trailingAnchor, constant: 6),

            dateLabel.centerYAnchor.constraint(equalTo: statusDot.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            statusDot.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
        ])
    }

    func configure(record: BAEPServiceRecord, faultName: String, severity: String) {
        motorLabel.text = record.motorName
        faultLabel.text = "\(String(format: "FLT-%03d", record.faultId))  ·  \(faultName.uppercased())"
        dateLabel.text = record.date
        resultLabel.text = record.result.uppercased()
        let c = color(forResult: record.result)
        statusDot.backgroundColor = c
        resultLabel.textColor = c
    }

    private func color(forResult result: String) -> UIColor {
        switch result.lowercased() {
        case "resolved":  return BAEPTheme.statusGreen
        case "pending":   return BAEPTheme.statusAmber
        case "escalated": return BAEPTheme.statusRed
        default:          return BAEPTheme.steel
        }
    }
}
