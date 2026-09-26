//
//  GatewayViewController.swift
//  Bearing Atlas Pro
//
//  Knowledge and Maintenance have NO standalone pages.
//  Their tabs present a gateway that redirects the user to the Faults tab,
//  enforcing: Knowledge / Maintenance MUST be opened via a selected fault.
//

import UIKit

final class BAEPGatewayViewController: UIViewController {

    enum Kind {
        case knowledge
        case maintenance

        var titleText: String {
            switch self {
            case .knowledge:   return "Knowledge"
            case .maintenance: return "Maintenance"
            }
        }
        var symbol: String {
            switch self {
            case .knowledge:   return "book.closed.fill"
            case .maintenance: return "wrench.and.screwdriver.fill"
            }
        }
        var message: String {
            switch self {
            case .knowledge:
                return "Knowledge articles open from a selected fault. Choose a fault to read its linked article."
            case .maintenance:
                return "Maintenance tasks open from a selected fault. Choose a fault to view its linked task."
            }
        }
    }

    private let kind: Kind

    init(kind: Kind) {
        self.kind = kind
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = kind.titleText
        view.backgroundColor = BAEPTheme.navy
        navigationController?.navigationBar.prefersLargeTitles = true
        build()
    }

    private func build() {
        let icon = UIImageView(image: UIImage(systemName: kind.symbol))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = BAEPTheme.orange
        icon.contentMode = .scaleAspectFit
        icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 52, weight: .regular)

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Open via a Fault"
        title.font = BAEPTheme.font(22, .heavy)
        title.textColor = BAEPTheme.textPrimary
        title.textAlignment = .center

        let message = UILabel()
        message.translatesAutoresizingMaskIntoConstraints = false
        message.text = kind.message
        message.font = BAEPTheme.font(15)
        message.textColor = BAEPTheme.textSecondary
        message.textAlignment = .center
        message.numberOfLines = 0

        let flow = UILabel()
        flow.translatesAutoresizingMaskIntoConstraints = false
        flow.text = "FAULT → KNOWLEDGE → MAINTENANCE → RECORD"
        flow.font = BAEPTheme.mono(10, .bold)
        flow.textColor = BAEPTheme.textMuted
        flow.textAlignment = .center
        flow.adjustsFontSizeToFitWidth = true
        flow.minimumScaleFactor = 0.7

        let go = BAEPActionButton(title: "Go to Faults", symbol: "list.bullet.rectangle.fill")
        go.addTarget(self, action: #selector(goToFaults), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [icon, title, message, flow])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 14

        view.addSubview(stack)
        view.addSubview(go)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            go.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: BAEPTheme.pad),
            go.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -BAEPTheme.pad),
            go.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
    }

    @objc private func goToFaults() {
        tabBarController?.selectedIndex = 0
    }
}
