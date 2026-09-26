//
//  BAEPTheme.swift
//  Bearing Atlas Pro
//
//  Industrial software style. HARD LOCK palette.
//  Navy / Steel Gray / Orange accent / Red-Green status.
//  No gradients, no decoration. Flat functional surfaces.
//

import UIKit

enum BAEPTheme {

    // MARK: - Core Palette

    /// Primary background. Navy #0B1F3B.
    static let navy = UIColor(red: 0x0B / 255.0, green: 0x1F / 255.0, blue: 0x3B / 255.0, alpha: 1.0)

    /// Slightly lighter navy for elevated surfaces / cards.
    static let navySurface = UIColor(red: 0x12 / 255.0, green: 0x2A / 255.0, blue: 0x4A / 255.0, alpha: 1.0)

    /// Steel gray for secondary surfaces and dividers.
    static let steel = UIColor(red: 0x5A / 255.0, green: 0x67 / 255.0, blue: 0x78 / 255.0, alpha: 1.0)

    /// Lighter steel for hairline borders.
    static let steelLine = UIColor(red: 0x2A / 255.0, green: 0x3A / 255.0, blue: 0x52 / 255.0, alpha: 1.0)

    /// Orange accent for interactive / emphasis elements.
    static let orange = UIColor(red: 0xF2 / 255.0, green: 0x7A / 255.0, blue: 0x1A / 255.0, alpha: 1.0)

    // MARK: - Status

    static let statusRed = UIColor(red: 0xD6 / 255.0, green: 0x3B / 255.0, blue: 0x2F / 255.0, alpha: 1.0)
    static let statusGreen = UIColor(red: 0x2E / 255.0, green: 0xA0 / 255.0, blue: 0x4E / 255.0, alpha: 1.0)
    static let statusAmber = UIColor(red: 0xE0 / 255.0, green: 0xA8 / 255.0, blue: 0x1E / 255.0, alpha: 1.0)

    // MARK: - Text

    static let textPrimary = UIColor(white: 0.96, alpha: 1.0)
    static let textSecondary = UIColor(red: 0x9A / 255.0, green: 0xA8 / 255.0, blue: 0xBA / 255.0, alpha: 1.0)
    static let textMuted = UIColor(red: 0x6B / 255.0, green: 0x77 / 255.0, blue: 0x88 / 255.0, alpha: 1.0)

    // MARK: - Severity → Color

    static func color(forSeverity severity: String) -> UIColor {
        switch severity.lowercased() {
        case "critical": return statusRed
        case "high":     return orange
        case "medium":   return statusAmber
        case "low":      return statusGreen
        default:         return steel
        }
    }

    // MARK: - Typography

    static func font(_ size: CGFloat, _ weight: UIFont.Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight)
    }

    /// Monospaced for codes / IDs / data readouts — reinforces instrument feel.
    static func mono(_ size: CGFloat, _ weight: UIFont.Weight = .regular) -> UIFont {
        return UIFont.monospacedSystemFont(ofSize: size, weight: weight)
    }

    // MARK: - Metrics

    static let cornerRadius: CGFloat = 4   // tight, industrial — not rounded/playful
    static let hairline: CGFloat = 1.0 / UIScreen.main.scale
    static let pad: CGFloat = 16
}

// MARK: - Reusable Builders

extension UIView {

    /// Flat steel hairline border + subtle elevated surface. No shadows, no gradients.
    func applyCardStyle(surface: UIColor = BAEPTheme.navySurface) {
        backgroundColor = surface
        layer.cornerRadius = BAEPTheme.cornerRadius
        layer.borderWidth = 1
        layer.borderColor = BAEPTheme.steelLine.cgColor
    }
}
