//
//  UIComponents.swift
//  Bearing Atlas Pro
//
//  Shared UIKit building blocks drawn with SF Symbols + UIKit only.
//  Industrial flat style — no gradients, no decorative imagery.
//

import UIKit

// MARK: - Severity Badge

/// Compact uppercase status pill. Color encodes severity (red/orange/amber/green).
final class BAEPSeverityBadge: UIView {

    private let label = UILabel()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = BAEPTheme.cornerRadius
        layer.borderWidth = 1

        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = BAEPTheme.mono(11, .bold)
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(severity: String) {
        let c = BAEPTheme.color(forSeverity: severity)
        label.text = severity.uppercased()
        label.textColor = c
        layer.borderColor = c.cgColor
        backgroundColor = c.withAlphaComponent(0.12)
    }
}

// MARK: - Section Block (detail screens)

/// A titled, bordered block: small uppercase header + body text. Used across detail pages.
final class BAEPSectionBlock: UIView {

    private let header = UILabel()
    private let body = UILabel()
    private let accentBar = UIView()

    init(title: String, content: String, accent: UIColor = BAEPTheme.orange) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        applyCardStyle()

        accentBar.translatesAutoresizingMaskIntoConstraints = false
        accentBar.backgroundColor = accent
        accentBar.layer.cornerRadius = 1

        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = title.uppercased()
        header.font = BAEPTheme.mono(12, .bold)
        header.textColor = BAEPTheme.textSecondary

        body.translatesAutoresizingMaskIntoConstraints = false
        body.text = content
        body.font = BAEPTheme.font(15)
        body.textColor = BAEPTheme.textPrimary
        body.numberOfLines = 0

        addSubview(accentBar)
        addSubview(header)
        addSubview(body)

        NSLayoutConstraint.activate([
            accentBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            accentBar.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            accentBar.widthAnchor.constraint(equalToConstant: 3),
            accentBar.heightAnchor.constraint(equalToConstant: 12),

            header.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 8),
            header.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            header.topAnchor.constraint(equalTo: topAnchor, constant: 12),

            body.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            body.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            body.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 8),
            body.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Data Row (key/value readout)

/// Monospaced key on the left, value on the right — instrument-panel readout.
final class BAEPDataRow: UIView {

    init(key: String, value: String, valueColor: UIColor = BAEPTheme.textPrimary) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let k = UILabel()
        k.translatesAutoresizingMaskIntoConstraints = false
        k.text = key.uppercased()
        k.font = BAEPTheme.mono(12, .medium)
        k.textColor = BAEPTheme.textMuted

        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.text = value
        v.font = BAEPTheme.font(14, .semibold)
        v.textColor = valueColor
        v.textAlignment = .right
        v.numberOfLines = 0

        addSubview(k)
        addSubview(v)
        NSLayoutConstraint.activate([
            k.leadingAnchor.constraint(equalTo: leadingAnchor),
            k.topAnchor.constraint(equalTo: topAnchor),
            k.bottomAnchor.constraint(equalTo: bottomAnchor),
            k.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),

            v.leadingAnchor.constraint(equalTo: k.trailingAnchor, constant: 8),
            v.trailingAnchor.constraint(equalTo: trailingAnchor),
            v.topAnchor.constraint(equalTo: topAnchor),
            v.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Primary Action Button

/// Solid orange industrial action button.
final class BAEPActionButton: UIButton {

    init(title: String, symbol: String? = nil) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = BAEPTheme.orange
        setTitle(title, for: .normal)
        setTitleColor(BAEPTheme.navy, for: .normal)
        titleLabel?.font = BAEPTheme.font(16, .bold)
        layer.cornerRadius = BAEPTheme.cornerRadius
        if let symbol = symbol {
            setImage(UIImage(systemName: symbol), for: .normal)
            tintColor = BAEPTheme.navy
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        }
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.7 : 1.0 }
    }
}

// MARK: - Empty State

final class BAEPEmptyStateView: UIView {

    init(symbol: String, title: String, message: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = BAEPTheme.steel
        icon.contentMode = .scaleAspectFit
        icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 44, weight: .light)

        let t = UILabel()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.text = title
        t.font = BAEPTheme.font(18, .semibold)
        t.textColor = BAEPTheme.textSecondary
        t.textAlignment = .center

        let m = UILabel()
        m.translatesAutoresizingMaskIntoConstraints = false
        m.text = message
        m.font = BAEPTheme.font(14)
        m.textColor = BAEPTheme.textMuted
        m.textAlignment = .center
        m.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [icon, t, m])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -40),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Scrollable detail container

/// A navy-background scroll view with a vertical content stack pinned to readable width.
final class BAEPDetailScrollContainer: UIScrollView {

    let contentStack = UIStackView()

    init() {
        super.init(frame: .zero)
        backgroundColor = BAEPTheme.navy
        alwaysBounceVertical = true
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 12
        addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor, constant: BAEPTheme.pad),
            contentStack.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor, constant: -BAEPTheme.pad),
            contentStack.leadingAnchor.constraint(equalTo: frameLayoutGuide.leadingAnchor, constant: BAEPTheme.pad),
            contentStack.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor, constant: -BAEPTheme.pad),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
