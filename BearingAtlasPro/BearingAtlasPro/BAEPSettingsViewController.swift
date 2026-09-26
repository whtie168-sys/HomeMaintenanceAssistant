//
//  SettingsViewController.swift
//  Bearing Atlas Pro
//
//  Tab 5 — system information and offline data summary.
//  Read-only stats traceable to faults/records. No external/online features.
//

import UIKit

final class BAEPSettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = BAEPTheme.navy
        navigationController?.navigationBar.prefersLargeTitles = true
        build()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStats()
    }

    private let statsCard = UIView()
    private var faultsRow: BAEPDataRow?
    private var recordsRow: BAEPDataRow?
    private let statsStack = UIStackView()

    private func build() {
        let scroll = BAEPDetailScrollContainer()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        scroll.contentStack.addArrangedSubview(headerCard())

        // Live data summary
        statsCard.applyCardStyle()
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        statsStack.axis = .vertical
        statsStack.spacing = 12
        statsCard.addSubview(statsStack)
        NSLayoutConstraint.activate([
            statsStack.topAnchor.constraint(equalTo: statsCard.topAnchor, constant: 14),
            statsStack.bottomAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: -14),
            statsStack.leadingAnchor.constraint(equalTo: statsCard.leadingAnchor, constant: 14),
            statsStack.trailingAnchor.constraint(equalTo: statsCard.trailingAnchor, constant: -14),
        ])
        scroll.contentStack.addArrangedSubview(sectionLabel("DATA SUMMARY"))
        scroll.contentStack.addArrangedSubview(statsCard)

        // System info
        scroll.contentStack.addArrangedSubview(sectionLabel("SYSTEM"))
        let info = UIView()
        info.applyCardStyle()
        let infoStack = UIStackView(arrangedSubviews: [
            BAEPDataRow(key: "Version", value: appVersion()),
            line(),
            BAEPDataRow(key: "Storage", value: "SQLite (Local)"),
            line(),
            BAEPDataRow(key: "Network", value: "Disabled", valueColor: BAEPTheme.statusGreen),
            line(),
            BAEPDataRow(key: "Mode", value: "100% Offline"),
        ])
        infoStack.translatesAutoresizingMaskIntoConstraints = false
        infoStack.axis = .vertical
        infoStack.spacing = 12
        info.addSubview(infoStack)
        NSLayoutConstraint.activate([
            infoStack.topAnchor.constraint(equalTo: info.topAnchor, constant: 14),
            infoStack.bottomAnchor.constraint(equalTo: info.bottomAnchor, constant: -14),
            infoStack.leadingAnchor.constraint(equalTo: info.leadingAnchor, constant: 14),
            infoStack.trailingAnchor.constraint(equalTo: info.trailingAnchor, constant: -14),
        ])
        scroll.contentStack.addArrangedSubview(info)

        scroll.contentStack.addArrangedSubview(
            BAEPSectionBlock(title: "About",
                             content: "Industrial Motor IQ is a closed, data-driven engineering reference system. Every screen follows the locked workflow: Fault → Knowledge → Maintenance → Record."))
    }

    private func headerCard() -> UIView {
        let card = UIView()
        card.applyCardStyle(surface: BAEPTheme.navySurface)
        let icon = UIImageView(image: UIImage(systemName: "gearshape.2.fill"))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = BAEPTheme.orange
        icon.contentMode = .scaleAspectFit
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "INDUSTRIAL MOTOR IQ"
        title.font = BAEPTheme.font(20, .heavy)
        title.textColor = BAEPTheme.textPrimary
        let sub = UILabel()
        sub.translatesAutoresizingMaskIntoConstraints = false
        sub.text = "Fault-Centered Knowledge System"
        sub.font = BAEPTheme.mono(12, .medium)
        sub.textColor = BAEPTheme.textMuted
        card.addSubview(icon)
        card.addSubview(title)
        card.addSubview(sub)
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            icon.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 40),
            icon.heightAnchor.constraint(equalToConstant: 40),
            title.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 14),
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            sub.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 14),
            sub.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            sub.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
        ])
        return card
    }

    private func refreshStats() {
        statsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let faults = BAEPDatabaseManager.shared.faultCount()
        let records = BAEPDatabaseManager.shared.recordCount()
        statsStack.addArrangedSubview(BAEPDataRow(key: "Cataloged Faults", value: "\(faults)",
                                                  valueColor: BAEPTheme.orange))
        statsStack.addArrangedSubview(line())
        statsStack.addArrangedSubview(BAEPDataRow(key: "Saved Records", value: "\(records)",
                                                  valueColor: BAEPTheme.orange))
    }

    private func sectionLabel(_ text: String) -> UIView {
        let container = UIView()
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = text
        l.font = BAEPTheme.mono(12, .bold)
        l.textColor = BAEPTheme.textMuted
        container.addSubview(l)
        NSLayoutConstraint.activate([
            l.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            l.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 2),
            l.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        return container
    }

    private func line() -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = BAEPTheme.steelLine
        v.heightAnchor.constraint(equalToConstant: BAEPTheme.hairline).isActive = true
        return v
    }

    private func appVersion() -> String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return "v\(v)"
    }
}
