//
//  KnowledgeViewController.swift
//  Bearing Atlas Pro
//
//  Tab content reached ONLY via a selected fault.
//  Renders the linked knowledge article (fault_id) in the strict field format.
//

import UIKit

final class BAEPKnowledgeViewController: UIViewController {

    private let fault: BAEPFault

    init(fault: BAEPFault) {
        self.fault = fault
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Knowledge"
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

        guard let a = BAEPDatabaseManager.shared.fetchArticle(faultId: fault.id) else {
            let empty = BAEPEmptyStateView(symbol: "book.closed",
                                           title: "No Article",
                                           message: "No knowledge article is linked to this fault.")
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

        scroll.contentStack.addArrangedSubview(titleCard(a.title))
        scroll.contentStack.addArrangedSubview(BAEPSectionBlock(title: "Overview", content: a.overview))
        scroll.contentStack.addArrangedSubview(BAEPSectionBlock(title: "Causes", content: a.causes))
        scroll.contentStack.addArrangedSubview(BAEPSectionBlock(title: "Symptoms", content: a.symptoms))
        scroll.contentStack.addArrangedSubview(BAEPSectionBlock(title: "Inspection", content: a.inspection))
        scroll.contentStack.addArrangedSubview(BAEPSectionBlock(title: "Maintenance", content: a.maintenance))
        scroll.contentStack.addArrangedSubview(
            BAEPSectionBlock(title: "Related Fault",
                             content: "\(fault.name)  ·  \(fault.system)  ·  \(fault.severity.uppercased())",
                             accent: BAEPTheme.color(forSeverity: fault.severity)))

        // Continue the flow
        let next = BAEPActionButton(title: "Proceed to Maintenance", symbol: "wrench.and.screwdriver.fill")
        next.addTarget(self, action: #selector(goMaintenance), for: .touchUpInside)
        scroll.contentStack.addArrangedSubview(next)
    }

    private func titleCard(_ text: String) -> UIView {
        let card = UIView()
        card.applyCardStyle()
        let tag = UILabel()
        tag.translatesAutoresizingMaskIntoConstraints = false
        tag.text = "KNOWLEDGE ARTICLE"
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

    @objc private func goMaintenance() {
        navigationController?.pushViewController(
            BAEPMaintenanceViewController(fault: fault), animated: true)
    }
}
