//
//  MaintenanceViewController.swift
//  Bearing Atlas Pro
//
//  Reached ONLY via a selected fault.
//  Renders the linked maintenance task (fault_id) in the strict field format,
//  then offers to close the workflow by creating a record.
//

import UIKit

final class BAEPMaintenanceViewController: UIViewController {

    private let fault: BAEPFault

    init(fault: BAEPFault) {
        self.fault = fault
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Maintenance"
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

        guard let t = BAEPDatabaseManager.shared.fetchTask(faultId: fault.id) else {
            let empty = BAEPEmptyStateView(symbol: "wrench.and.screwdriver",
                                           title: "No Task",
                                           message: "No maintenance task is linked to this fault.")
            empty.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(empty)
            NSLayoutConstraint.activate([
                empty.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                empty.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                empty.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                empty.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
            return
        }

        scroll.contentStack.addArrangedSubview(titleCard(t.name))
        scroll.contentStack.addArrangedSubview(BAEPSectionBlock(title: "Tools", content: t.tools))
        scroll.contentStack.addArrangedSubview(
            BAEPSectionBlock(title: "Safety", content: t.safety, accent: BAEPTheme.statusRed))
        scroll.contentStack.addArrangedSubview(stepsCard(t.steps))
        scroll.contentStack.addArrangedSubview(
            BAEPSectionBlock(title: "Expected Result", content: t.expectedResult, accent: BAEPTheme.statusGreen))

        let next = BAEPActionButton(title: "Complete · Create Record", symbol: "checkmark.seal.fill")
        next.addTarget(self, action: #selector(goRecord), for: .touchUpInside)
        scroll.contentStack.addArrangedSubview(next)
    }

    private func titleCard(_ text: String) -> UIView {
        let card = UIView()
        card.applyCardStyle()
        let tag = UILabel()
        tag.translatesAutoresizingMaskIntoConstraints = false
        tag.text = "MAINTENANCE TASK"
        tag.font = BAEPTheme.mono(11, .bold)
        tag.textColor = BAEPTheme.orange
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = text
        title.font = BAEPTheme.font(22, .heavy)
        title.textColor = BAEPTheme.textPrimary
        title.numberOfLines = 0
        card.addSubview(tag)
        card.addSubview(title)
        NSLayoutConstraint.activate([
            tag.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            tag.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            tag.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            title.topAnchor.constraint(equalTo: tag.bottomAnchor, constant: 6),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            title.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])
        return card
    }

    /// Steps are stored newline-separated; render as a numbered checklist of rows.
    private func stepsCard(_ steps: String) -> UIView {
        let card = UIView()
        card.applyCardStyle()

        let header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = "STEPS"
        header.font = BAEPTheme.mono(12, .bold)
        header.textColor = BAEPTheme.textSecondary

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10

        let lines = steps.split(separator: "\n").map(String.init)
        for line in lines {
            let row = UILabel()
            row.translatesAutoresizingMaskIntoConstraints = false
            row.text = line
            row.font = BAEPTheme.font(15)
            row.textColor = BAEPTheme.textPrimary
            row.numberOfLines = 0
            stack.addArrangedSubview(row)
        }

        card.addSubview(header)
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            header.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            header.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
        ])
        return card
    }

    @objc private func goRecord() {
        navigationController?.pushViewController(
            BAEPRecordEditorViewController(fault: fault), animated: true)
    }
}
