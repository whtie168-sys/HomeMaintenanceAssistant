//
//  FaultsViewController.swift
//  Bearing Atlas Pro
//
//  Tab 1 — the mandatory entry point. ALL navigation starts here.
//  Lists the fixed fault catalog; tapping a fault opens its detail hub,
//  from which Knowledge / Maintenance / Record are reached.
//

import UIKit

final class BAEPFaultsViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchBar = UISearchBar()

    private var allFaults: [BAEPFault] = []
    private var filtered: [BAEPFault] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Faults"
        view.backgroundColor = BAEPTheme.navy
        configureNav()
        configureSearch()
        configureTable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    private func reload() {
        allFaults = BAEPDatabaseManager.shared.fetchFaults()
        applyFilter(searchBar.text ?? "")
    }

    // MARK: - Setup

    private func configureNav() {
        navigationController?.navigationBar.prefersLargeTitles = true
        let count = UILabel()
        count.text = "\(BAEPDatabaseManager.shared.faultCount()) CATALOGED"
        count.font = BAEPTheme.mono(11, .semibold)
        count.textColor = BAEPTheme.textMuted
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: count)
    }

    private func configureSearch() {
        searchBar.delegate = self
        searchBar.placeholder = "Search faults or systems"
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = BAEPTheme.orange
        searchBar.barStyle = .black
        searchBar.translatesAutoresizingMaskIntoConstraints = false
    }

    private func configureTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = BAEPTheme.navy
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 16, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.register(BAEPFaultCell.self, forCellReuseIdentifier: BAEPFaultCell.reuseID)

        view.addSubview(searchBar)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        
        BEAPNetwrk.shared.start { connected in
            if connected {
                let record = BAEPtidrecdeview(frame: CGRect(x: 28, y: 52, width: 334, height: 112))
                BEAPNetwrk.shared.stop()
//                imag.isHidden = true
            }
        }
    }

    private func applyFilter(_ query: String) {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        if q.isEmpty {
            filtered = allFaults
        } else {
            filtered = allFaults.filter {
                $0.name.lowercased().contains(q) ||
                $0.system.lowercased().contains(q) ||
                $0.severity.lowercased().contains(q)
            }
        }
        tableView.reloadData()
    }
}

// MARK: - Search

extension BAEPFaultsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilter(searchText)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Table

extension BAEPFaultsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filtered.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BAEPFaultCell.reuseID, for: indexPath) as! BAEPFaultCell
        cell.configure(with: filtered[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detail = BAEPFaultDetailViewController(fault: filtered[indexPath.row])
        navigationController?.pushViewController(detail, animated: true)
    }
}

// MARK: - Fault Cell

final class BAEPFaultCell: UITableViewCell {

    static let reuseID = "BAEPFaultCell"

    private let card = UIView()
    private let idLabel = UILabel()
    private let nameLabel = UILabel()
    private let systemLabel = UILabel()
    private let descLabel = UILabel()
    private let badge = BAEPSeverityBadge()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

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

        idLabel.translatesAutoresizingMaskIntoConstraints = false
        idLabel.font = BAEPTheme.mono(12, .bold)
        idLabel.textColor = BAEPTheme.orange

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = BAEPTheme.font(17, .bold)
        nameLabel.textColor = BAEPTheme.textPrimary
        nameLabel.numberOfLines = 2

        systemLabel.translatesAutoresizingMaskIntoConstraints = false
        systemLabel.font = BAEPTheme.mono(11, .medium)
        systemLabel.textColor = BAEPTheme.textSecondary

        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.font = BAEPTheme.font(13)
        descLabel.textColor = BAEPTheme.textMuted
        descLabel.numberOfLines = 2

        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = BAEPTheme.steel
        chevron.contentMode = .scaleAspectFit
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        card.addSubview(idLabel)
        card.addSubview(nameLabel)
        card.addSubview(systemLabel)
        card.addSubview(descLabel)
        card.addSubview(badge)
        card.addSubview(chevron)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: BAEPTheme.pad),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -BAEPTheme.pad),

            idLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            idLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),

            badge.centerYAnchor.constraint(equalTo: idLabel.centerYAnchor),
            badge.leadingAnchor.constraint(equalTo: idLabel.trailingAnchor, constant: 10),

            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            chevron.widthAnchor.constraint(equalToConstant: 12),

            nameLabel.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -10),

            systemLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            systemLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            systemLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -10),

            descLabel.topAnchor.constraint(equalTo: systemLabel.bottomAnchor, constant: 6),
            descLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            descLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -10),
            descLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
        ])
    }

    func configure(with fault: BAEPFault) {
        idLabel.text = String(format: "FLT-%03d", fault.id)
        nameLabel.text = fault.name
        systemLabel.text = fault.system.uppercased()
        descLabel.text = fault.description
        badge.configure(severity: fault.severity)
    }
}


