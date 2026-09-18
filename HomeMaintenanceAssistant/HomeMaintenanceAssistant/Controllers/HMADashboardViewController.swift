//
//  HMADashboardViewController.swift
//  HomeMaintenanceAssistant
//
//  Home screen: stat cards plus overdue and upcoming task lists.
//

import UIKit

final class HMADashboardViewController: UIViewController {

    private let viewModel = HMADashboardViewModel()
    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private weak var statsRow: UIStackView?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dashboard"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = HMATheme.screenBackground
        HMAbuildLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        HMArefresh()
    }

    // MARK: - Layout

    private func HMAbuildLayout() {
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.HMApin(to: view.safeAreaLayoutGuide)

        stack.axis = .vertical
        stack.spacing = HMATheme.cardSpacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 28, right: 0)
        scrollView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor)
        ])
    }

    // MARK: - Data

    private func HMArefresh() {
        viewModel.HMAreload()
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        stack.addArrangedSubview(HMAmakeStatsGrid())

        if !viewModel.overdue.isEmpty {
            stack.addArrangedSubview(HMAsectionHeader("Overdue Tasks", color: HMATheme.overdue))
            for item in viewModel.overdue.prefix(5) {
                stack.addArrangedSubview(HMAtaskRow(item.task, status: item.status, area: item.areaName))
            }
        }

        stack.addArrangedSubview(HMAsectionHeader("Upcoming Tasks", color: HMATheme.accent))
        if viewModel.upcoming.isEmpty {
            stack.addArrangedSubview(HMAemptyRow("Nothing due in the next two weeks. Nice work."))
        } else {
            for item in viewModel.upcoming.prefix(6) {
                stack.addArrangedSubview(HMAtaskRow(item.task, status: item.status, area: item.areaName))
            }
        }
    }

    // MARK: - Stat grid

    private func HMAmakeStatsGrid() -> UIView {
        let s = viewModel.stats
        let cards = [
            HMAstatCard(value: "\(s.dueCount)", caption: "Tasks Due", tint: HMATheme.accent, icon: "calendar.badge.clock"),
            HMAstatCard(value: "\(s.overdueCount)", caption: "Overdue", tint: HMATheme.overdue, icon: "exclamationmark.triangle.fill"),
            HMAstatCard(value: "\(s.completedThisMonth)", caption: "Done / Month", tint: HMATheme.completed, icon: "checkmark.seal.fill"),
            HMAstatCard(value: "\(s.recordCount)", caption: "Records", tint: HMATheme.navy, icon: "tray.full.fill")
        ]
        let row1 = UIStackView(arrangedSubviews: [cards[0], cards[1]])
        let row2 = UIStackView(arrangedSubviews: [cards[2], cards[3]])
        [row1, row2].forEach { $0.axis = .horizontal; $0.distribution = .fillEqually; $0.spacing = HMATheme.cardSpacing }
        let grid = UIStackView(arrangedSubviews: [row1, row2])
        grid.axis = .vertical
        grid.spacing = HMATheme.cardSpacing
        let wrap = HMAinsetWrap(grid)
        return wrap
    }

    private func HMAstatCard(value: String, caption: String, tint: UIColor, icon: String) -> UIView {
        let card = HMACardView()
        let icv = UIImageView(image: UIImage(systemName: icon))
        icv.tintColor = tint
        icv.contentMode = .scaleAspectFit
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = HMATheme.titleFont(30, weight: .heavy)
        valueLabel.textColor = HMATheme.primaryText
        let captionLabel = UILabel()
        captionLabel.text = caption.uppercased()
        captionLabel.font = HMATheme.roundedFont(11, weight: .bold)
        captionLabel.textColor = HMATheme.secondaryText

        [icv, valueLabel, captionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview($0)
        }
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 104),
            icv.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            icv.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            icv.widthAnchor.constraint(equalToConstant: 22),
            icv.heightAnchor.constraint(equalToConstant: 22),
            valueLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            valueLabel.topAnchor.constraint(equalTo: icv.bottomAnchor, constant: 6),
            captionLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            captionLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            captionLabel.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -8)
        ])
        return card
    }

    // MARK: - Rows

    private func HMAsectionHeader(_ text: String, color: UIColor) -> UIView {
        let container = UIView()
        let bar = UIView()
        bar.backgroundColor = color
        bar.layer.cornerRadius = 2
        let label = UILabel()
        label.text = text
        label.font = HMATheme.titleFont(19, weight: .bold)
        label.textColor = HMATheme.primaryText
        [bar, label].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; container.addSubview($0) }
        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: HMATheme.screenInset),
            bar.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            bar.widthAnchor.constraint(equalToConstant: 4),
            bar.heightAnchor.constraint(equalToConstant: 20),
            label.leadingAnchor.constraint(equalTo: bar.trailingAnchor, constant: 8),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -2),
            label.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -HMATheme.screenInset)
        ])
        return container
    }

    private func HMAtaskRow(_ task: HMATask, status: HMAScheduleStatus, area: String) -> UIView {
        let card = HMACardView()
        let bar = UIView()
        bar.backgroundColor = HMAStatusStyling.HMAcolor(for: status)
        bar.layer.cornerRadius = 2.5
        let title = UILabel()
        title.text = task.title
        title.font = HMATheme.titleFont(16, weight: .semibold)
        title.textColor = HMATheme.primaryText
        title.numberOfLines = 2
        let meta = UILabel()
        meta.text = "\(area) · \(HMAFormat.HMArelativeDue(status))"
        meta.font = HMATheme.roundedFont(13, weight: .medium)
        meta.textColor = HMAStatusStyling.HMAcolor(for: status)

        [bar, title, meta].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; card.addSubview($0) }
        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            bar.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            bar.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            bar.widthAnchor.constraint(equalToConstant: 5),
            title.leadingAnchor.constraint(equalTo: bar.trailingAnchor, constant: 12),
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            meta.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            meta.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            meta.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            meta.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(HMArowTapped(_:)))
        card.addGestureRecognizer(tap)
        card.tag = task.id
        return HMAinsetWrap(card)
    }

    private func HMAemptyRow(_ text: String) -> UIView {
        let card = HMACardView()
        let label = UILabel()
        label.text = text
        label.font = HMATheme.roundedFont(14, weight: .medium)
        label.textColor = HMATheme.secondaryText
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(label)
        label.HMApin(to: card, inset: 18)
        return HMAinsetWrap(card)
    }

    /// Wraps a card in horizontal screen insets so stack rows line up.
    private func HMAinsetWrap(_ inner: UIView) -> UIView {
        let wrap = UIView()
        inner.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: wrap.topAnchor),
            inner.bottomAnchor.constraint(equalTo: wrap.bottomAnchor),
            inner.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: HMATheme.screenInset),
            inner.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -HMATheme.screenInset)
        ])
        return wrap
    }

    @objc private func HMArowTapped(_ sender: UITapGestureRecognizer) {
        guard let id = sender.view?.tag, let task = HMADatabaseManager.shared.HMAfetchTask(id: id) else { return }
        let detail = HMATaskDetailViewController(task: task)
        navigationController?.pushViewController(detail, animated: true)
    }
}
