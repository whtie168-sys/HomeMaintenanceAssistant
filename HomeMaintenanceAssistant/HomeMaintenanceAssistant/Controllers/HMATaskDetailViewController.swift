//
//  HMATaskDetailViewController.swift
//  HomeMaintenanceAssistant
//
//  Full task reference: meta tags, tools, safety notes and numbered steps,
//  plus a shortcut to log a maintenance record for this task.
//

import UIKit

final class HMATaskDetailViewController: UIViewController {

    private let task: HMATask
    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    init(task: HMATask) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Task Detail"
        view.backgroundColor = HMATheme.screenBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain, target: self, action: #selector(HMAlogRecord))
        HMAbuildLayout()
    }

    private func HMAbuildLayout() {
        view.addSubview(scrollView)
        scrollView.HMApin(to: view.safeAreaLayoutGuide)
        scrollView.alwaysBounceVertical = true

        stack.axis = .vertical
        stack.spacing = HMATheme.cardSpacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: HMATheme.screenInset,
                                           bottom: 28, right: HMATheme.screenInset)
        scrollView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor)
        ])

        stack.addArrangedSubview(HMAheaderCard())
        stack.addArrangedSubview(HMAmetaCard())
        stack.addArrangedSubview(HMAtextCard(title: "Tools Required", icon: "wrench.and.screwdriver.fill",
                                             body: task.tools, tint: HMATheme.navy))
        stack.addArrangedSubview(HMAtextCard(title: "Safety Notes", icon: "shield.lefthalf.filled",
                                             body: task.safety, tint: HMATheme.overdue))
        stack.addArrangedSubview(HMAprocedureCard())
        stack.addArrangedSubview(HMAlogButton())
    }

    // MARK: - Cards

    private func HMAheaderCard() -> UIView {
        let card = HMACardView()
        let titleLabel = UILabel()
        titleLabel.text = task.title
        titleLabel.font = HMATheme.titleFont(24, weight: .heavy)
        titleLabel.textColor = HMATheme.primaryText
        titleLabel.numberOfLines = 0
        let detailLabel = UILabel()
        detailLabel.text = task.detail
        detailLabel.font = HMATheme.roundedFont(15, weight: .regular)
        detailLabel.textColor = HMATheme.secondaryText
        detailLabel.numberOfLines = 0

        let diff = HMATagLabel()
        diff.HMAconfigure(text: task.difficulty.rawValue,
                          color: HMAStatusStyling.HMAcolor(for: task.difficulty), filled: true)
        let freq = HMATagLabel()
        freq.HMAconfigure(text: task.frequency.rawValue, color: HMATheme.accent)
        let tagRow = UIStackView(arrangedSubviews: [diff, freq, UIView()])
        tagRow.axis = .horizontal
        tagRow.spacing = 8

        let v = UIStackView(arrangedSubviews: [titleLabel, detailLabel, tagRow])
        v.axis = .vertical
        v.spacing = 10
        v.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(v)
        v.HMApin(to: card, inset: 16)
        return card
    }

    private func HMAmetaCard() -> UIView {
        let card = HMACardView()
        let rows = [
            HMAmetaRow(icon: "clock.fill", label: "Estimated Time", value: task.HMAestimatedTimeText),
            HMAmetaRow(icon: "arrow.triangle.2.circlepath", label: "Recommended", value: task.frequency.rawValue),
            HMAmetaRow(icon: "chart.bar.fill", label: "Difficulty", value: task.difficulty.rawValue)
        ]
        let v = UIStackView(arrangedSubviews: rows)
        v.axis = .vertical
        v.spacing = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(v)
        v.HMApin(to: card, inset: 16)
        return card
    }

    private func HMAmetaRow(icon: String, label: String, value: String) -> UIView {
        let row = UIView()
        let icv = UIImageView(image: UIImage(systemName: icon))
        icv.tintColor = HMATheme.accent
        icv.contentMode = .scaleAspectFit
        let nameLabel = UILabel()
        nameLabel.text = label
        nameLabel.font = HMATheme.roundedFont(14, weight: .medium)
        nameLabel.textColor = HMATheme.secondaryText
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = HMATheme.titleFont(15, weight: .semibold)
        valueLabel.textColor = HMATheme.primaryText
        valueLabel.textAlignment = .right
        [icv, nameLabel, valueLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; row.addSubview($0) }
        NSLayoutConstraint.activate([
            icv.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            icv.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            icv.widthAnchor.constraint(equalToConstant: 20),
            icv.heightAnchor.constraint(equalToConstant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: icv.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            row.heightAnchor.constraint(equalToConstant: 24)
        ])
        return row
    }

    private func HMAtextCard(title: String, icon: String, body: String, tint: UIColor) -> UIView {
        let card = HMACardView()
        let header = HMAcardHeader(title: title, icon: icon, tint: tint)
        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.font = HMATheme.roundedFont(15, weight: .regular)
        bodyLabel.textColor = HMATheme.primaryText
        bodyLabel.numberOfLines = 0
        let v = UIStackView(arrangedSubviews: [header, bodyLabel])
        v.axis = .vertical
        v.spacing = 10
        v.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(v)
        v.HMApin(to: card, inset: 16)
        return card
    }

    private func HMAprocedureCard() -> UIView {
        let card = HMACardView()
        let header = HMAcardHeader(title: "Step-by-Step Procedure",
                                   icon: "list.number", tint: HMATheme.accent)
        let v = UIStackView(arrangedSubviews: [header])
        v.axis = .vertical
        v.spacing = 12

        for (index, step) in task.HMAprocedureSteps.enumerated() {
            v.addArrangedSubview(HMAstepRow(number: index + 1, text: HMAstrip(step)))
        }
        v.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(v)
        v.HMApin(to: card, inset: 16)
        return card
    }

    /// Removes a leading "N. " prefix that the seed stored for plain display.
    private func HMAstrip(_ step: String) -> String {
        guard let dot = step.firstIndex(of: ".") else { return step }
        let prefix = step[step.startIndex..<dot]
        if Int(prefix) != nil {
            return String(step[step.index(after: dot)...]).trimmingCharacters(in: .whitespaces)
        }
        return step
    }

    private func HMAstepRow(number: Int, text: String) -> UIView {
        let row = UIView()
        let badge = UILabel()
        badge.text = "\(number)"
        badge.font = HMATheme.roundedFont(14, weight: .bold)
        badge.textColor = .white
        badge.textAlignment = .center
        badge.backgroundColor = HMATheme.navy
        badge.layer.cornerRadius = 13
        badge.clipsToBounds = true
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = HMATheme.roundedFont(15, weight: .regular)
        textLabel.textColor = HMATheme.primaryText
        textLabel.numberOfLines = 0
        [badge, textLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; row.addSubview($0) }
        NSLayoutConstraint.activate([
            badge.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            badge.topAnchor.constraint(equalTo: row.topAnchor),
            badge.widthAnchor.constraint(equalToConstant: 26),
            badge.heightAnchor.constraint(equalToConstant: 26),
            textLabel.leadingAnchor.constraint(equalTo: badge.trailingAnchor, constant: 12),
            textLabel.topAnchor.constraint(equalTo: row.topAnchor, constant: 2),
            textLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])
        return row
    }

    private func HMAcardHeader(title: String, icon: String, tint: UIColor) -> UIView {
        let row = UIView()
        let icv = UIImageView(image: UIImage(systemName: icon))
        icv.tintColor = tint
        icv.contentMode = .scaleAspectFit
        let label = UILabel()
        label.text = title
        label.font = HMATheme.titleFont(18, weight: .bold)
        label.textColor = HMATheme.primaryText
        [icv, label].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; row.addSubview($0) }
        NSLayoutConstraint.activate([
            icv.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            icv.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            icv.widthAnchor.constraint(equalToConstant: 22),
            icv.heightAnchor.constraint(equalToConstant: 22),
            label.leadingAnchor.constraint(equalTo: icv.trailingAnchor, constant: 8),
            label.topAnchor.constraint(equalTo: row.topAnchor),
            label.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor)
        ])
        return row
    }

    private func HMAlogButton() -> UIView {
        let button = UIButton(type: .system)
        button.setTitle("  Log Maintenance Record", for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        button.titleLabel?.font = HMATheme.titleFont(17, weight: .semibold)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = HMATheme.accent
        button.layer.cornerRadius = HMATheme.cornerRadius
        button.layer.cornerCurve = .continuous
        button.addTarget(self, action: #selector(HMAlogRecord), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 54).isActive = true
        return button
    }

    @objc private func HMAlogRecord() {
        let editor = HMARecordEditViewController(prefillTaskId: task.id)
        let nav = UINavigationController(rootViewController: editor)
        present(nav, animated: true)
    }
}
