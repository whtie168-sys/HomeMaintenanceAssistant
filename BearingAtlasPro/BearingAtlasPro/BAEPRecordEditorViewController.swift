//
//  RecordEditorViewController.swift
//  Bearing Atlas Pro
//
//  Workflow closure. A record is created ONLY from a fault session,
//  so it always carries fault_id. No standalone record creation exists.
//

import UIKit

final class BAEPRecordEditorViewController: UIViewController {

    private let fault: BAEPFault

    private let motorField = UITextField()
    private let diagnosisField = UITextField()
    private let actionField = UITextField()
    private let resultControl = UISegmentedControl(items: ["Resolved", "Pending", "Escalated"])
    private let notesView = UITextView()

    init(fault: BAEPFault) {
        self.fault = fault
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Record"
        view.backgroundColor = BAEPTheme.navy
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save", style: .done, target: self, action: #selector(save))
        navigationItem.rightBarButtonItem?.tintColor = BAEPTheme.orange
        build()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
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

        // Bound fault banner — proves fault_id linkage
        scroll.contentStack.addArrangedSubview(faultBanner())

        scroll.contentStack.addArrangedSubview(fieldBlock(title: "Motor Name", field: motorField,
                                                          placeholder: "e.g. Pump Motor A-12"))
        scroll.contentStack.addArrangedSubview(fieldBlock(title: "Diagnosis Result", field: diagnosisField,
                                                          placeholder: "Confirmed finding"))
        scroll.contentStack.addArrangedSubview(fieldBlock(title: "Action Taken", field: actionField,
                                                          placeholder: "Corrective action performed"))
        scroll.contentStack.addArrangedSubview(resultBlock())
        scroll.contentStack.addArrangedSubview(notesBlock())

        let saveBtn = BAEPActionButton(title: "Save Record", symbol: "tray.and.arrow.down.fill")
        saveBtn.addTarget(self, action: #selector(save), for: .touchUpInside)
        scroll.contentStack.addArrangedSubview(saveBtn)
    }

    private func faultBanner() -> UIView {
        let card = UIView()
        card.applyCardStyle()
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = BAEPTheme.color(forSeverity: fault.severity)
        bar.layer.cornerRadius = 2
        let tag = UILabel()
        tag.translatesAutoresizingMaskIntoConstraints = false
        tag.text = "CLOSING WORKFLOW FOR"
        tag.font = BAEPTheme.mono(10, .bold)
        tag.textColor = BAEPTheme.textMuted
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.text = "\(String(format: "FLT-%03d", fault.id))  ·  \(fault.name)"
        name.font = BAEPTheme.font(16, .bold)
        name.textColor = BAEPTheme.textPrimary
        name.numberOfLines = 0
        card.addSubview(bar)
        card.addSubview(tag)
        card.addSubview(name)
        NSLayoutConstraint.activate([
            bar.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            bar.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            bar.widthAnchor.constraint(equalToConstant: 4),
            bar.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            tag.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            tag.leadingAnchor.constraint(equalTo: bar.trailingAnchor, constant: 12),
            tag.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            name.topAnchor.constraint(equalTo: tag.bottomAnchor, constant: 4),
            name.leadingAnchor.constraint(equalTo: bar.trailingAnchor, constant: 12),
            name.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            name.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])
        return card
    }

    private func styleField(_ field: UITextField, placeholder: String) {
        field.translatesAutoresizingMaskIntoConstraints = false
        field.font = BAEPTheme.font(16)
        field.textColor = BAEPTheme.textPrimary
        field.tintColor = BAEPTheme.orange
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: BAEPTheme.textMuted])
        field.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }

    private func fieldBlock(title: String, field: UITextField, placeholder: String) -> UIView {
        let card = UIView()
        card.applyCardStyle()
        let header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = title.uppercased()
        header.font = BAEPTheme.mono(12, .bold)
        header.textColor = BAEPTheme.textSecondary
        styleField(field, placeholder: placeholder)
        card.addSubview(header)
        card.addSubview(field)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            header.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            header.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            field.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 8),
            field.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            field.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            field.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
        ])
        return card
    }

    private func resultBlock() -> UIView {
        let card = UIView()
        card.applyCardStyle()
        let header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = "RESULT"
        header.font = BAEPTheme.mono(12, .bold)
        header.textColor = BAEPTheme.textSecondary
        resultControl.translatesAutoresizingMaskIntoConstraints = false
        resultControl.selectedSegmentIndex = 0
        resultControl.selectedSegmentTintColor = BAEPTheme.orange
        resultControl.backgroundColor = BAEPTheme.navy
        resultControl.setTitleTextAttributes([.foregroundColor: BAEPTheme.textSecondary], for: .normal)
        resultControl.setTitleTextAttributes([.foregroundColor: BAEPTheme.navy,
                                              .font: BAEPTheme.font(14, .bold)], for: .selected)
        card.addSubview(header)
        card.addSubview(resultControl)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            header.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            header.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            resultControl.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 10),
            resultControl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            resultControl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            resultControl.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
        ])
        return card
    }

    private func notesBlock() -> UIView {
        let card = UIView()
        card.applyCardStyle()
        let header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = "NOTES"
        header.font = BAEPTheme.mono(12, .bold)
        header.textColor = BAEPTheme.textSecondary
        notesView.translatesAutoresizingMaskIntoConstraints = false
        notesView.font = BAEPTheme.font(15)
        notesView.textColor = BAEPTheme.textPrimary
        notesView.tintColor = BAEPTheme.orange
        notesView.backgroundColor = .clear
        notesView.isScrollEnabled = false
        notesView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
        card.addSubview(header)
        card.addSubview(notesView)
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            header.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            header.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            notesView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 6),
            notesView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
            notesView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
            notesView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
        ])
        return card
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    @objc private func save() {
        let motor = motorField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !motor.isEmpty else {
            present(alert("Motor Name Required", "Enter the motor name before saving."), animated: true)
            return
        }
        let diagnosis = diagnosisField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let action = actionField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let result = resultControl.titleForSegment(at: resultControl.selectedSegmentIndex) ?? "Resolved"

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        let date = df.string(from: Date())

        let ok = BAEPDatabaseManager.shared.insertRecord(
            faultId: fault.id,
            motorName: motor,
            diagnosisResult: diagnosis.isEmpty ? fault.name : diagnosis,
            action: action,
            result: result,
            date: date,
            notes: notesView.text ?? "")

        guard ok else {
            present(alert("Save Failed", "The record could not be stored."), animated: true)
            return
        }

        // Workflow closed — return to the fault list root.
        let banner = UIAlertController(title: "Record Saved",
                                       message: "Workflow closed for \(fault.name).",
                                       preferredStyle: .alert)
        banner.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(banner, animated: true)
    }

    private func alert(_ title: String, _ message: String) -> UIAlertController {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        return a
    }
}
