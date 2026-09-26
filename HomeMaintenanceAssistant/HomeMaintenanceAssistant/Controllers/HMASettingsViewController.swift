//
//  HMASettingsViewController.swift
//  HomeMaintenanceAssistant
//
//  Theme preference, version info and an About section.
//

import UIKit

final class HMASettingsViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private enum HMARow {
        case theme
        case appVersion
        case dataVersion
        case about
    }
    private let sections: [(title: String, rows: [HMARow])] = [
        ("Appearance", [.theme]),
        ("Information", [.appVersion, .dataVersion]),
        ("About", [.about])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = HMATheme.screenBackground
        tableView.backgroundColor = HMATheme.screenBackground
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "setting")
        view.addSubview(tableView)
        tableView.HMApin(to: view.safeAreaLayoutGuide)
    }

    private var HMAappVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}

extension HMASettingsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "setting", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.textProperties.color = HMATheme.primaryText
        config.secondaryTextProperties.color = HMATheme.secondaryText
        cell.accessoryType = .none
        cell.selectionStyle = .none
        cell.backgroundColor = HMATheme.cardBackground

        switch sections[indexPath.section].rows[indexPath.row] {
        case .theme:
            config.text = "Theme"
            config.secondaryText = HMAthemeName()
            cell.accessoryView = HMAthemeSwitcher()
        case .appVersion:
            config.text = "App Version"
            config.secondaryText = HMAappVersion
        case .dataVersion:
            config.text = "Data Version"
            config.secondaryText = HMADatabaseManager.shared.dataVersion
        case .about:
            config.text = "About Home Maintenance Assistant"
            config.secondaryText = "Offline planner & record manager for home upkeep."
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default
        }
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if case .about = sections[indexPath.section].rows[indexPath.row] {
            navigationController?.pushViewController(HMAAboutViewController(), animated: true)
        }
    }

    // MARK: - Theme switching

    private func HMAthemeName() -> String {
        switch HMAThemePreference.current {
        case .system: return "Match System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    private func HMAthemeSwitcher() -> UIView {
        let control = UISegmentedControl(items: ["Auto", "Light", "Dark"])
        control.selectedSegmentTintColor = HMATheme.accent
        switch HMAThemePreference.current {
        case .system: control.selectedSegmentIndex = 0
        case .light: control.selectedSegmentIndex = 1
        case .dark: control.selectedSegmentIndex = 2
        }
        control.addTarget(self, action: #selector(HMAthemeChanged(_:)), for: .valueChanged)
        control.frame = CGRect(x: 0, y: 0, width: 190, height: 30)
        return control
    }

    @objc private func HMAthemeChanged(_ sender: UISegmentedControl) {
        let pref: HMAThemePreference
        switch sender.selectedSegmentIndex {
        case 1: pref = .light
        case 2: pref = .dark
        default: pref = .system
        }
        HMAThemePreference.HMAapply(pref, to: view.window)
        tableView.reloadData()
    }
}

// MARK: - Theme preference

enum HMAThemePreference: String {
    case system, light, dark

    private static let key = "hma.theme.preference"

    static var current: HMAThemePreference {
        HMAThemePreference(rawValue: UserDefaults.standard.string(forKey: key) ?? "") ?? .system
    }

    static func HMAapply(_ pref: HMAThemePreference, to window: UIWindow?) {
        UserDefaults.standard.set(pref.rawValue, forKey: key)
        let style: UIUserInterfaceStyle
        switch pref {
        case .system: style = .unspecified
        case .light: style = .light
        case .dark: style = .dark
        }
        window?.overrideUserInterfaceStyle = style
    }

    static func HMArestore(to window: UIWindow?) {
        HMAapply(current, to: window)
    }
}

// MARK: - About

final class HMAAboutViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"
        view.backgroundColor = HMATheme.screenBackground

        let scroll = UIScrollView()
        view.addSubview(scroll)
        scroll.HMApin(to: view.safeAreaLayoutGuide)

        let title = UILabel()
        title.text = "Home Maintenance Assistant"
        title.font = HMATheme.titleFont(22, weight: .heavy)
        title.textColor = HMATheme.primaryText
        title.numberOfLines = 0

        let body = UILabel()
        body.numberOfLines = 0
        body.font = HMATheme.roundedFont(15, weight: .regular)
        body.textColor = HMATheme.secondaryText
        body.text = """
        Home Maintenance Assistant helps homeowners, renters and property \
        managers stay on top of routine upkeep — completely offline.

        Browse maintenance areas, follow step-by-step task procedures with \
        tools and safety notes, and keep a private history of completed work.

        All data is stored locally on your device. No account, no network \
        connection and no tracking are required.
        """

        let stack = UIStackView(arrangedSubviews: [title, body])
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: HMATheme.screenInset),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -HMATheme.screenInset)
        ])
    }
}
