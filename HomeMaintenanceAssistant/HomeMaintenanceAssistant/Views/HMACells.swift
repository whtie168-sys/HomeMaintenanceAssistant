//
//  HMACells.swift
//  HomeMaintenanceAssistant
//
//  Reusable table cells used across Areas, Tasks, Dashboard and Records.
//  Distinct card-with-leading-glyph layout for the "utility tool" identity.
//

import UIKit

// MARK: - Area cell

final class HMAAreaCell: UITableViewCell {
    static let reuseID = "HMAAreaCell"

    private let card = HMACardView()
    private let glyphWell = UIView()
    private let glyph = UIImageView()
    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    private let chevron = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        HMAsetup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func HMAsetup() {
        contentView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HMATheme.screenInset),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -HMATheme.screenInset)
        ])

        glyphWell.backgroundColor = HMATheme.accentSoft
        glyphWell.layer.cornerRadius = 12
        glyphWell.layer.cornerCurve = .continuous
        glyph.tintColor = HMATheme.accent
        glyph.contentMode = .scaleAspectFit

        titleLabel.font = HMATheme.titleFont(17, weight: .semibold)
        titleLabel.textColor = HMATheme.primaryText
        countLabel.font = HMATheme.roundedFont(13, weight: .medium)
        countLabel.textColor = HMATheme.secondaryText

        chevron.image = UIImage(systemName: "chevron.right")
        chevron.tintColor = HMATheme.secondaryText
        chevron.contentMode = .scaleAspectFit

        [glyphWell, titleLabel, countLabel, chevron].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview($0)
        }
        glyphWell.addSubview(glyph)
        glyph.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            glyphWell.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            glyphWell.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            glyphWell.widthAnchor.constraint(equalToConstant: 46),
            glyphWell.heightAnchor.constraint(equalToConstant: 46),
            glyph.centerXAnchor.constraint(equalTo: glyphWell.centerXAnchor),
            glyph.centerYAnchor.constraint(equalTo: glyphWell.centerYAnchor),
            glyph.widthAnchor.constraint(equalToConstant: 24),
            glyph.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: glyphWell.trailingAnchor, constant: 14),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),

            countLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            countLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),

            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12)
        ])
    }

    func HMAconfigure(area: HMAArea, taskCount: Int) {
        glyph.image = UIImage(systemName: area.icon)
        titleLabel.text = area.name
        countLabel.text = taskCount == 1 ? "1 maintenance task" : "\(taskCount) maintenance tasks"
    }
}

// MARK: - Task cell

final class HMATaskCell: UITableViewCell {
    static let reuseID = "HMATaskCell"

    private let card = HMACardView()
    private let statusBar = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let difficultyTag = HMATagLabel()
    private let statusTag = HMATagLabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        HMAsetup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func HMAsetup() {
        contentView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HMATheme.screenInset),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -HMATheme.screenInset)
        ])

        statusBar.layer.cornerRadius = 2.5
        card.addSubview(statusBar)

        titleLabel.font = HMATheme.titleFont(16, weight: .semibold)
        titleLabel.textColor = HMATheme.primaryText
        titleLabel.numberOfLines = 2

        subtitleLabel.font = HMATheme.roundedFont(13, weight: .medium)
        subtitleLabel.textColor = HMATheme.secondaryText

        [statusBar, titleLabel, subtitleLabel, difficultyTag, statusTag].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview($0)
        }

        NSLayoutConstraint.activate([
            statusBar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            statusBar.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            statusBar.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            statusBar.widthAnchor.constraint(equalToConstant: 5),

            titleLabel.leadingAnchor.constraint(equalTo: statusBar.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            difficultyTag.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            difficultyTag.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 10),
            difficultyTag.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),

            statusTag.leadingAnchor.constraint(equalTo: difficultyTag.trailingAnchor, constant: 8),
            statusTag.centerYAnchor.constraint(equalTo: difficultyTag.centerYAnchor)
        ])
    }

    func HMAconfigure(item: HMATaskListItem, showArea: Bool) {
        titleLabel.text = item.task.title
        let freq = item.task.frequency.rawValue
        subtitleLabel.text = showArea ? "\(item.areaName) · \(freq)" : freq

        difficultyTag.HMAconfigure(text: item.task.difficulty.rawValue,
                                   color: HMAStatusStyling.HMAcolor(for: item.task.difficulty))
        let statusColor = HMAStatusStyling.HMAcolor(for: item.status)
        statusBar.backgroundColor = statusColor
        statusTag.HMAconfigure(text: HMAshortStatus(item.status), color: statusColor, filled: false)
    }

    private func HMAshortStatus(_ status: HMAScheduleStatus) -> String {
        switch status {
        case .overdue:   return "Overdue"
        case .dueSoon:   return "Due Soon"
        case .upcoming:  return "On Track"
        case .neverDone: return "New"
        }
    }
}

// MARK: - Record cell

final class HMARecordCell: UITableViewCell {
    static let reuseID = "HMARecordCell"

    private let card = HMACardView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private let notesLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        HMAsetup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func HMAsetup() {
        contentView.addSubview(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: HMATheme.screenInset),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -HMATheme.screenInset)
        ])

        iconView.contentMode = .scaleAspectFit
        titleLabel.font = HMATheme.titleFont(16, weight: .semibold)
        titleLabel.textColor = HMATheme.primaryText
        titleLabel.numberOfLines = 2
        metaLabel.font = HMATheme.roundedFont(13, weight: .medium)
        metaLabel.textColor = HMATheme.secondaryText
        notesLabel.font = HMATheme.roundedFont(13, weight: .regular)
        notesLabel.textColor = HMATheme.secondaryText
        notesLabel.numberOfLines = 2

        [iconView, titleLabel, metaLabel, notesLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview($0)
        }

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            iconView.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            metaLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            metaLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),

            notesLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            notesLabel.topAnchor.constraint(equalTo: metaLabel.bottomAnchor, constant: 6),
            notesLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            notesLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
    }

    func HMAconfigure(record: HMARecord) {
        let color = HMAStatusStyling.HMAcolor(for: record.result)
        iconView.image = UIImage(systemName: HMAStatusStyling.HMAicon(for: record.result))
        iconView.tintColor = color
        titleLabel.text = record.taskTitle.isEmpty ? "Maintenance Record" : record.taskTitle
        let dateText = HMAFormat.mediumDate.string(from: record.date)
        let area = record.areaName.isEmpty ? "" : "\(record.areaName) · "
        metaLabel.text = "\(area)\(record.result.rawValue) · \(dateText)"
        notesLabel.text = record.notes.isEmpty ? "No notes added." : record.notes
    }
}
