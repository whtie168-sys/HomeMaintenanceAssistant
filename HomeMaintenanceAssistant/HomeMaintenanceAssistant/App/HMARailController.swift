//
//  HMARailController.swift
//  HomeMaintenanceAssistant
//
//  Custom container that replaces UITabBarController with a persistent
//  vertical icon rail on the leading edge. Distinct navigation shell for
//  the app's identity; child view controllers are hosted on the right.
//

import UIKit

/// One entry in the navigation rail.
struct HMARailItem {
    let title: String
    let icon: String
    let viewController: UIViewController
}

final class HMARailController: UIViewController {

    private let items: [HMARailItem]
    private(set) var selectedIndex = 0

    private let rail = UIView()
    private let brandMark = UIImageView()
    private let buttonStack = UIStackView()
    private let contentContainer = UIView()
    private var railButtons: [HMARailButton] = []

    private let railWidth: CGFloat = 80

    init(items: [HMARailItem]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = HMATheme.navy
        HMAbuildRail()
        HMAbuildContent()
        HMAselect(index: 0, initial: true)
    }

    // MARK: - Rail

    private func HMAbuildRail() {
        rail.backgroundColor = HMATheme.navy
        rail.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rail)

        // Hairline separating rail from content.
        let divider = UIView()
        divider.backgroundColor = UIColor(white: 1, alpha: 0.08)
        divider.translatesAutoresizingMaskIntoConstraints = false
        rail.addSubview(divider)

        // Brand mark at the top of the rail for identity.
        brandMark.image = UIImage(systemName: "house.lodge.fill")
        brandMark.tintColor = HMATheme.accent
        brandMark.contentMode = .scaleAspectFit
        brandMark.translatesAutoresizingMaskIntoConstraints = false
        rail.addSubview(brandMark)

        buttonStack.axis = .vertical
        buttonStack.alignment = .fill
        buttonStack.distribution = .equalSpacing
        buttonStack.spacing = 6
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        rail.addSubview(buttonStack)

        for (index, item) in items.enumerated() {
            let button = HMARailButton(title: item.title, icon: item.icon)
            button.tag = index
            button.HMAonTap = { [weak self] in self?.HMAselect(index: index, initial: false) }
            railButtons.append(button)
            buttonStack.addArrangedSubview(button)
        }

        NSLayoutConstraint.activate([
            rail.topAnchor.constraint(equalTo: view.topAnchor),
            rail.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rail.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rail.widthAnchor.constraint(equalToConstant: railWidth),

            divider.topAnchor.constraint(equalTo: rail.topAnchor),
            divider.bottomAnchor.constraint(equalTo: rail.bottomAnchor),
            divider.trailingAnchor.constraint(equalTo: rail.trailingAnchor),
            divider.widthAnchor.constraint(equalToConstant: 1),

            brandMark.topAnchor.constraint(equalTo: rail.safeAreaLayoutGuide.topAnchor, constant: 14),
            brandMark.centerXAnchor.constraint(equalTo: rail.centerXAnchor),
            brandMark.widthAnchor.constraint(equalToConstant: 30),
            brandMark.heightAnchor.constraint(equalToConstant: 30),

            buttonStack.topAnchor.constraint(equalTo: brandMark.bottomAnchor, constant: 22),
            buttonStack.leadingAnchor.constraint(equalTo: rail.leadingAnchor, constant: 8),
            buttonStack.trailingAnchor.constraint(equalTo: rail.trailingAnchor, constant: -8),
            buttonStack.bottomAnchor.constraint(lessThanOrEqualTo: rail.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    private func HMAbuildContent() {
        contentContainer.backgroundColor = HMATheme.screenBackground
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentContainer)
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: view.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: rail.trailingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - Selection

    private func HMAselect(index: Int, initial: Bool) {
        guard index >= 0, index < items.count else { return }

        // Re-tap on the active item: pop its navigation stack to root.
        if !initial, index == selectedIndex {
            if let nav = items[index].viewController as? UINavigationController {
                nav.popToRootViewController(animated: true)
            }
            return
        }

        // Remove the currently shown child.
        if !initial {
            let current = items[selectedIndex].viewController
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }

        selectedIndex = index
        let incoming = items[index].viewController
        addChild(incoming)
        incoming.view.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(incoming.view)
        NSLayoutConstraint.activate([
            incoming.view.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            incoming.view.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            incoming.view.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            incoming.view.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor)
        ])
        incoming.didMove(toParent: self)

        for (i, button) in railButtons.enumerated() {
            button.HMAsetSelected(i == index)
        }
        setNeedsStatusBarAppearanceUpdate()
    }
}

// MARK: - Rail button

/// A single icon + caption entry in the rail with a selected pill state.
final class HMARailButton: UIControl {

    var HMAonTap: (() -> Void)?

    private let pill = UIView()
    private let iconView = UIImageView()
    private let captionLabel = UILabel()

    init(title: String, icon: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        pill.backgroundColor = .clear
        pill.layer.cornerRadius = 16
        pill.layer.cornerCurve = .continuous
        pill.isUserInteractionEnabled = false
        pill.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pill)

        iconView.image = UIImage(systemName: icon)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor(white: 0.62, alpha: 1.0)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)

        captionLabel.text = title
        captionLabel.font = HMATheme.roundedFont(10, weight: .semibold)
        captionLabel.textColor = UIColor(white: 0.62, alpha: 1.0)
        captionLabel.textAlignment = .center
        captionLabel.adjustsFontSizeToFitWidth = true
        captionLabel.minimumScaleFactor = 0.8
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(captionLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 62),

            pill.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            pill.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            pill.leadingAnchor.constraint(equalTo: leadingAnchor),
            pill.trailingAnchor.constraint(equalTo: trailingAnchor),

            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            captionLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 4),
            captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2)
        ])

        addTarget(self, action: #selector(HMAtapped), for: .touchUpInside)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func HMAtapped() { HMAonTap?() }

    func HMAsetSelected(_ selected: Bool) {
        UIView.animate(withDuration: 0.18) {
            self.pill.backgroundColor = selected ? UIColor(white: 1, alpha: 0.10) : .clear
            self.iconView.tintColor = selected ? HMATheme.accent : UIColor(white: 0.62, alpha: 1.0)
            self.captionLabel.textColor = selected ? HMATheme.accent : UIColor(white: 0.62, alpha: 1.0)
        }
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.6 : 1.0 }
    }
}
