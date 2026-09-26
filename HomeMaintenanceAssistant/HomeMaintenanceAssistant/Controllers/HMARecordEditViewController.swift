//
//  HMARecordEditViewController.swift
//  HomeMaintenanceAssistant
//
//  Create or edit a maintenance record. Photo is a placeholder only —
//  no camera or photo-library access is requested (fully offline).
//

import UIKit

final class HMARecordEditViewController: UIViewController {

    private let viewModel: HMARecordEditViewModel
    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    private let taskButton = UIButton(type: .system)
    private let datePicker = UIDatePicker()
    private let resultControl = UISegmentedControl(items: HMARecordResult.allCases.map { $0.rawValue })
    private let notesView = UITextView()
    private let notesPlaceholder = UILabel()

    // MARK: - Init

    init(existing: HMARecord) {
        self.viewModel = HMARecordEditViewModel(existing: existing)
        super.init(nibName: nil, bundle: nil)
    }

    init(prefillTaskId: Int?) {
        self.viewModel = HMARecordEditViewModel(existing: nil)
        super.init(nibName: nil, bundle: nil)
        if let id = prefillTaskId { viewModel.selectedTaskId = id }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = HMATheme.screenBackground
        title = viewModel.existing == nil ? "New Record" : "Edit Record"
        viewModel.HMAloadOptions()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self, action: #selector(HMAcancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .save, target: self, action: #selector(HMAsave))

        HMAbuildLayout()
        HMArefreshFromModel()
    }

    // MARK: - Layout

    private func HMAbuildLayout() {
        view.addSubview(scrollView)
        scrollView.HMApin(to: view.safeAreaLayoutGuide)
        scrollView.keyboardDismissMode = .interactive

        stack.axis = .vertical
        stack.spacing = 18
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 18, left: HMATheme.screenInset,
                                           bottom: 28, right: HMATheme.screenInset)
        scrollView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor)
        ])

        // Task selector
        taskButton.contentHorizontalAlignment = .leading
        taskButton.titleLabel?.font = HMATheme.titleFont(16, weight: .semibold)
        taskButton.setTitleColor(HMATheme.primaryText, for: .normal)
        taskButton.addTarget(self, action: #selector(HMApickTask), for: .touchUpInside)
        taskButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        taskButton.backgroundColor = HMATheme.cardBackground
        taskButton.layer.cornerRadius = HMATheme.cornerRadius
        taskButton.layer.cornerCurve = .continuous
        taskButton.layer.borderWidth = 1
        taskButton.layer.borderColor = HMATheme.hairline.cgColor
        taskButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        // Disable changing the task when editing an existing record.
        taskButton.isEnabled = (viewModel.existing == nil)
        stack.addArrangedSubview(HMAfieldGroup(title: "Task", content: taskButton))

        // Date
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        if #available(iOS 14.0, *) { datePicker.preferredDatePickerStyle = .compact }
        datePicker.addTarget(self, action: #selector(HMAdateChanged), for: .valueChanged)
        let dateWrap = UIView()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        dateWrap.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: dateWrap.leadingAnchor),
            datePicker.topAnchor.constraint(equalTo: dateWrap.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: dateWrap.bottomAnchor)
        ])
        stack.addArrangedSubview(HMAfieldGroup(title: "Date", content: dateWrap))

        // Result
        resultControl.selectedSegmentTintColor = HMATheme.accent
        resultControl.addTarget(self, action: #selector(HMAresultChanged), for: .valueChanged)
        stack.addArrangedSubview(HMAfieldGroup(title: "Result", content: resultControl))

        // Notes
        notesView.font = HMATheme.roundedFont(15, weight: .regular)
        notesView.textColor = HMATheme.primaryText
        notesView.backgroundColor = HMATheme.cardBackground
        notesView.layer.cornerRadius = HMATheme.cornerRadius
        notesView.layer.cornerCurve = .continuous
        notesView.layer.borderWidth = 1
        notesView.layer.borderColor = HMATheme.hairline.cgColor
        notesView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        notesView.delegate = self
        notesView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        notesPlaceholder.text = "Optional notes about this maintenance…"
        notesPlaceholder.font = HMATheme.roundedFont(15, weight: .regular)
        notesPlaceholder.textColor = HMATheme.secondaryText
        notesPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        notesView.addSubview(notesPlaceholder)
        NSLayoutConstraint.activate([
            notesPlaceholder.topAnchor.constraint(equalTo: notesView.topAnchor, constant: 12),
            notesPlaceholder.leadingAnchor.constraint(equalTo: notesView.leadingAnchor, constant: 14)
        ])
        stack.addArrangedSubview(HMAfieldGroup(title: "Notes", content: notesView))

        // Photo placeholder (no camera permission requested)
        stack.addArrangedSubview(HMAfieldGroup(title: "Photo", content: HMAphotoPlaceholder()))
    }

    private func HMAfieldGroup(title: String, content: UIView) -> UIView {
        let label = UILabel()
        label.text = title.uppercased()
        label.font = HMATheme.roundedFont(12, weight: .bold)
        label.textColor = HMATheme.secondaryText
        let v = UIStackView(arrangedSubviews: [label, content])
        v.axis = .vertical
        v.spacing = 8
        return v
    }

    private func HMAphotoPlaceholder() -> UIView {
        let card = HMACardView()
        let icon = UIImageView(image: UIImage(systemName: "photo.on.rectangle.angled"))
        icon.tintColor = HMATheme.secondaryText
        icon.contentMode = .scaleAspectFit
        let label = UILabel()
        label.text = "Photo attachment coming in a future update"
        label.font = HMATheme.roundedFont(13, weight: .medium)
        label.textColor = HMATheme.secondaryText
        label.numberOfLines = 0
        let v = UIStackView(arrangedSubviews: [icon, label])
        v.axis = .horizontal
        v.spacing = 12
        v.alignment = .center
        icon.widthAnchor.constraint(equalToConstant: 28).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 28).isActive = true
        v.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(v)
        v.HMApin(to: card, inset: 16)
        return card
    }

    // MARK: - Sync

    private func HMArefreshFromModel() {
        taskButton.setTitle(viewModel.HMAselectedTaskTitle, for: .normal)
        datePicker.date = viewModel.date
        if let idx = HMARecordResult.allCases.firstIndex(of: viewModel.result) {
            resultControl.selectedSegmentIndex = idx
        }
        notesView.text = viewModel.notes
        notesPlaceholder.isHidden = !viewModel.notes.isEmpty
    }

    // MARK: - Actions

    @objc private func HMApickTask() {
        let picker = HMATaskPickerViewController(options: viewModel.taskOptions,
                                                 selectedId: viewModel.selectedTaskId) { [weak self] id in
            self?.viewModel.selectedTaskId = id
            self?.taskButton.setTitle(self?.viewModel.HMAselectedTaskTitle, for: .normal)
        }
        navigationController?.pushViewController(picker, animated: true)
    }

    @objc private func HMAdateChanged() { viewModel.date = datePicker.date }

    @objc private func HMAresultChanged() {
        viewModel.result = HMARecordResult.allCases[resultControl.selectedSegmentIndex]
    }

    @objc private func HMAcancel() { dismiss(animated: true) }

    @objc private func HMAsave() {
        viewModel.notes = notesView.text ?? ""
        guard viewModel.HMAisValid else {
            let alert = UIAlertController(title: "Select a Task",
                                          message: "Please choose which task this record is for.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        viewModel.HMAsave()
        dismiss(animated: true)
    }
}

extension HMARecordEditViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        notesPlaceholder.isHidden = !(textView.text ?? "").isEmpty
    }
}

// MARK: - Task picker

/// Simple searchable list used to choose the task a record belongs to.
final class HMATaskPickerViewController: UITableViewController, UISearchResultsUpdating {

    private let allOptions: [HMARecordEditViewModel.HMATaskOption]
    private var filtered: [HMARecordEditViewModel.HMATaskOption]
    private let selectedId: Int
    private let onPick: (Int) -> Void
    private let search = UISearchController(searchResultsController: nil)

    init(options: [HMARecordEditViewModel.HMATaskOption],
         selectedId: Int,
         onPick: @escaping (Int) -> Void) {
        self.allOptions = options
        self.filtered = options
        self.selectedId = selectedId
        self.onPick = onPick
        super.init(style: .plain)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select Task"
        view.backgroundColor = HMATheme.screenBackground
        tableView.backgroundColor = HMATheme.screenBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "pick")
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search tasks"
        navigationItem.searchController = search
        definesPresentationContext = true
    }

    func updateSearchResults(for searchController: UISearchController) {
        let q = (searchController.searchBar.text ?? "").lowercased()
        filtered = q.isEmpty ? allOptions : allOptions.filter {
            $0.title.lowercased().contains(q) || $0.areaName.lowercased().contains(q)
        }
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filtered.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pick", for: indexPath)
        let option = filtered[indexPath.row]
        cell.textLabel?.text = option.title
        cell.detailTextLabel?.text = option.areaName
        cell.backgroundColor = HMATheme.cardBackground
        cell.textLabel?.textColor = HMATheme.primaryText
        cell.accessoryType = option.id == selectedId ? .checkmark : .none
        cell.tintColor = HMATheme.accent
        var config = cell.defaultContentConfiguration()
        config.text = option.title
        config.secondaryText = option.areaName
        config.textProperties.color = HMATheme.primaryText
        config.secondaryTextProperties.color = HMATheme.secondaryText
        cell.contentConfiguration = config
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onPick(filtered[indexPath.row].id)
        navigationController?.popViewController(animated: true)
    }
}
