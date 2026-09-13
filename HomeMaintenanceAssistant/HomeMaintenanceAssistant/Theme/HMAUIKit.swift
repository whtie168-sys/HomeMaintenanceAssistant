//
//  HMAUIKit.swift
//  HomeMaintenanceAssistant
//
//  Small reusable UIKit building blocks shared across screens.
//

import UIKit

// MARK: - Layout sugar

extension UIView {

    /// Pins this view to another view's edges with an optional inset.
    func HMApin(to other: UIView, inset: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: other.topAnchor, constant: inset),
            leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: inset),
            trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -inset),
            bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -inset)
        ])
    }

    /// Pins this view to a layout guide's edges (e.g. safe area / readable content).
    func HMApin(to guide: UILayoutGuide, inset: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: guide.topAnchor, constant: inset),
            leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: inset),
            trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -inset),
            bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -inset)
        ])
    }
}

// MARK: - Card container

/// Rounded surface used everywhere to build the "utility tool" look.
final class HMACardView: UIView {

    init(filled: Bool = false) {
        super.init(frame: .zero)
        backgroundColor = HMATheme.cardBackground
        layer.cornerRadius = HMATheme.cornerRadius
        layer.cornerCurve = .continuous
        if filled {
            backgroundColor = HMATheme.navy
        }
        layer.borderWidth = 1
        layer.borderColor = HMATheme.hairline.cgColor
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        layer.borderColor = HMATheme.hairline.cgColor
    }
}

// MARK: - Pill / tag label

/// Small rounded capsule used for difficulty, frequency and status tags.
final class HMATagLabel: UIView {

    private let label = UILabel()

    init() {
        super.init(frame: .zero)
        addSubview(label)
        label.font = HMATheme.roundedFont(12, weight: .bold)
        label.HMApin(to: self, inset: 0)
        layer.cornerRadius = 9
        layer.cornerCurve = .continuous
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var intrinsicContentSize: CGSize {
        let base = label.intrinsicContentSize
        return CGSize(width: base.width + 22, height: base.height + 10)
    }

    func HMAconfigure(text: String, color: UIColor, filled: Bool = false) {
        label.text = text.uppercased()
        if filled {
            backgroundColor = color
            label.textColor = .white
        } else {
            backgroundColor = color.withAlphaComponent(0.16)
            label.textColor = color
        }
        invalidateIntrinsicContentSize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds.insetBy(dx: 11, dy: 5)
    }
}

// MARK: - Insettable label

/// Label with internal padding, handy for empty states and section headers.
final class HMAInsetLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + textInsets.left + textInsets.right,
                      height: s.height + textInsets.top + textInsets.bottom)
    }
}
