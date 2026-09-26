//
//  FaultDetailViewController.swift
//  Bearing Atlas Pro
//
//  The flow hub. Reached only from the Faults list.
//  Shows fault metadata and launches Knowledge, Maintenance, and Record
//  for THIS fault — enforcing Fault → Knowledge → Maintenance → Record.
//

import UIKit
import Network

final class BAEPFaultDetailViewController: UIViewController {

    private let fault: BAEPFault

    init(fault: BAEPFault) {
        self.fault = fault
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fault Detail"
        view.backgroundColor = BAEPTheme.navy
        navigationItem.largeTitleDisplayMode = .never
        build()
    }

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

        scroll.contentStack.addArrangedSubview(makeHeaderCard())

        // Metadata readout block
        let meta = UIView()
        meta.applyCardStyle()
        let rows = UIStackView(arrangedSubviews: [
            BAEPDataRow(key: "Fault ID", value: String(format: "FLT-%03d", fault.id)),
            divider(),
            BAEPDataRow(key: "System", value: fault.system),
            divider(),
            BAEPDataRow(key: "Severity", value: fault.severity.uppercased(),
                        valueColor: BAEPTheme.color(forSeverity: fault.severity)),
        ])
        rows.translatesAutoresizingMaskIntoConstraints = false
        rows.axis = .vertical
        rows.spacing = 12
        meta.addSubview(rows)
        NSLayoutConstraint.activate([
            rows.topAnchor.constraint(equalTo: meta.topAnchor, constant: 14),
            rows.bottomAnchor.constraint(equalTo: meta.bottomAnchor, constant: -14),
            rows.leadingAnchor.constraint(equalTo: meta.leadingAnchor, constant: 14),
            rows.trailingAnchor.constraint(equalTo: meta.trailingAnchor, constant: -14),
        ])
        scroll.contentStack.addArrangedSubview(meta)

        scroll.contentStack.addArrangedSubview(
            BAEPSectionBlock(title: "Description", content: fault.description))

        // Flow header
        scroll.contentStack.addArrangedSubview(flowLabel())

        // Navigation actions — the only routes onward
        scroll.contentStack.addArrangedSubview(
            flowButton(title: "Knowledge", subtitle: "Overview, causes, symptoms, inspection",
                       symbol: "book.closed.fill", step: "01",
                       action: #selector(openKnowledge)))
        scroll.contentStack.addArrangedSubview(
            flowButton(title: "Maintenance", subtitle: "Tools, safety, steps, expected result",
                       symbol: "wrench.and.screwdriver.fill", step: "02",
                       action: #selector(openMaintenance)))
        scroll.contentStack.addArrangedSubview(
            flowButton(title: "Create Record", subtitle: "Close the workflow for this fault",
                       symbol: "checkmark.seal.fill", step: "03",
                       action: #selector(openRecord)))

    }

    private func makeHeaderCard() -> UIView {
        let card = UIView()
        card.applyCardStyle(surface: BAEPTheme.navySurface)

        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = BAEPTheme.color(forSeverity: fault.severity)
        bar.layer.cornerRadius = 2

        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.text = fault.name
        name.font = BAEPTheme.font(24, .heavy)
        name.textColor = BAEPTheme.textPrimary
        name.numberOfLines = 0

        let badge = BAEPSeverityBadge()
        badge.configure(severity: fault.severity)

        card.addSubview(bar)
        card.addSubview(name)
        card.addSubview(badge)
        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            bar.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            bar.widthAnchor.constraint(equalToConstant: 4),
            bar.heightAnchor.constraint(equalToConstant: 28),

            name.leadingAnchor.constraint(equalTo: bar.trailingAnchor, constant: 12),
            name.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            name.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),

            badge.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            badge.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 10),
            badge.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])
        return card
    }

    private func flowLabel() -> UIView {
        let container = UIView()
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "DIAGNOSTIC WORKFLOW"
        l.font = BAEPTheme.mono(12, .bold)
        l.textColor = BAEPTheme.textMuted
        container.addSubview(l)
        NSLayoutConstraint.activate([
            l.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            l.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 2),
            l.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        return container
    }

    private func divider() -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = BAEPTheme.steelLine
        v.heightAnchor.constraint(equalToConstant: BAEPTheme.hairline).isActive = true
        return v
    }

    private func flowButton(title: String, subtitle: String, symbol: String,
                            step: String, action: Selector) -> UIView {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.applyCardStyle()
        btn.addTarget(self, action: action, for: .touchUpInside)
        btn.heightAnchor.constraint(greaterThanOrEqualToConstant: 72).isActive = true

        let stepLabel = UILabel()
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        stepLabel.text = step
        stepLabel.font = BAEPTheme.mono(13, .bold)
        stepLabel.textColor = BAEPTheme.navy
        stepLabel.textAlignment = .center
        let stepBg = UIView()
        stepBg.translatesAutoresizingMaskIntoConstraints = false
        stepBg.backgroundColor = BAEPTheme.orange
        stepBg.layer.cornerRadius = BAEPTheme.cornerRadius
        stepBg.addSubview(stepLabel)

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = BAEPTheme.orange
        icon.contentMode = .scaleAspectFit

        let t = UILabel()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.text = title
        t.font = BAEPTheme.font(17, .bold)
        t.textColor = BAEPTheme.textPrimary

        let s = UILabel()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.text = subtitle
        s.font = BAEPTheme.font(12)
        s.textColor = BAEPTheme.textMuted
        s.numberOfLines = 2

        let chevron = UIImageView(image: UIImage(systemName: "arrow.right"))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = BAEPTheme.steel
        chevron.contentMode = .scaleAspectFit

        btn.addSubview(stepBg)
        btn.addSubview(icon)
        btn.addSubview(t)
        btn.addSubview(s)
        btn.addSubview(chevron)

        NSLayoutConstraint.activate([
            stepBg.leadingAnchor.constraint(equalTo: btn.leadingAnchor, constant: 14),
            stepBg.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            stepBg.widthAnchor.constraint(equalToConstant: 30),
            stepBg.heightAnchor.constraint(equalToConstant: 30),
            stepLabel.centerXAnchor.constraint(equalTo: stepBg.centerXAnchor),
            stepLabel.centerYAnchor.constraint(equalTo: stepBg.centerYAnchor),

            icon.leadingAnchor.constraint(equalTo: stepBg.trailingAnchor, constant: 12),
            icon.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 22),
            icon.heightAnchor.constraint(equalToConstant: 22),

            t.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            t.topAnchor.constraint(equalTo: btn.topAnchor, constant: 14),
            t.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),

            s.leadingAnchor.constraint(equalTo: t.leadingAnchor),
            s.topAnchor.constraint(equalTo: t.bottomAnchor, constant: 2),
            s.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),
            s.bottomAnchor.constraint(equalTo: btn.bottomAnchor, constant: -14),

            chevron.trailingAnchor.constraint(equalTo: btn.trailingAnchor, constant: -14),
            chevron.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 16),
        ])
        return btn
    }

    // MARK: - Routes (all carry this fault forward)

    @objc private func openKnowledge() {
        navigationController?.pushViewController(
            BAEPKnowledgeViewController(fault: fault), animated: true)
    }

    @objc private func openMaintenance() {
        navigationController?.pushViewController(
            BAEPMaintenanceViewController(fault: fault), animated: true)
    }

    @objc private func openRecord() {
        navigationController?.pushViewController(
            BAEPRecordEditorViewController(fault: fault), animated: true)
    }
}

final class BEAPNetwrk {
    static let shared = BEAPNetwrk()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    private var callback: ((Bool) -> Void)?
    private init() {}
    
    func start(_ callback: @escaping (Bool) -> Void) {
        self.callback = callback
        
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            
            DispatchQueue.main.async {
                self?.callback?(isConnected)
            }
        }
        monitor.start(queue: queue)
    }
    
    /// 停止监听
    func stop() {
        monitor.cancel()
    }
}
