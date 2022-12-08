//
//  NotesViewController.swift
//  evosipova_3PW3
//
//  Created by Elizabeth on 14.11.2022.
//

import Foundation
import UIKit

struct ShortNote : Codable {
    var text: String
}

final class NotesViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    internal var dataSource = [ShortNote]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        dataSource = load()
    }
    
    private func setupView() {
        setupTableView()
        setupNavBar()
    }
    
    private func setupTableView() {
        tableView.register(NoteCell.self, forCellReuseIdentifier: NoteCell.reuseIdentifier)
        tableView.register(AddNoteCell.self, forCellReuseIdentifier: AddNoteCell.reuseIdentifier)
        
        view.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.keyboardDismissMode = .onDrag
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.pin(to: self.view)
    }
    
    private func setupNavBar() {
        self.title = "Articles"
        
        let closeButton = UIButton(type: .close)
        closeButton.addTarget(self, action: #selector(dismissViewController(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
    }
    
    @objc
    private func dismissViewController(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    private func handleDelete(indexPath: IndexPath) {
        dataSource.remove(at: indexPath.row)
        tableView.reloadData()
        save()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(_: animated)
        setupView()
    }
    
    private var fileURL: URL = {
        let dirPath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return dirPath.appendingPathComponent("dataDirPath.txt")
    }()
    
    func save() {
        let encoder = PropertyListEncoder()
        let data = try! encoder.encode(dataSource)
        try! data.write(to: fileURL)
    }
    
    func load() -> [ShortNote] {
        do {
            let file = try Data(contentsOf: fileURL)
            let decoder = PropertyListDecoder()
            let data = try! decoder.decode([ShortNote].self, from: file)
            return data
        } catch (_) {
        }
        return []
    }
}

final class NoteCell: UITableViewCell {
    static let reuseIdentifier = "NoteCell"
    
    func configure(note: ShortNote) {
        textLabel?.text = note.text
        textLabel?.numberOfLines = 0
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.contentView.backgroundColor = .systemGray6
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NotesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return dataSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            if let addNewCell = tableView.dequeueReusableCell(withIdentifier:
                                                                AddNoteCell.reuseIdentifier, for: indexPath) as? AddNoteCell {
                addNewCell.delegate = self
                return addNewCell
            }
        default:
            let note = dataSource[indexPath.row]
            if let noteCell = tableView.dequeueReusableCell(withIdentifier:
                                                                NoteCell.reuseIdentifier, for: indexPath) as? NoteCell {
                noteCell.configure(note: note)
                return noteCell
            }
        }
        return UITableViewCell()
    }
}

extension NotesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt
                   indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if (indexPath.section != 1){
            return nil
        }
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: .none
        ) { [weak self] (action, view, completion) in
            self?.handleDelete(indexPath: indexPath)
            completion(true)
        }
        deleteAction.image = UIImage(
            systemName: "trash.fill",
            withConfiguration: UIImage.SymbolConfiguration(weight: .bold))?.withTintColor(.white)
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension NotesViewController: AddNoteDelegate {
    func newNoteAdded(note: ShortNote) {
        dataSource.insert(note, at: 0)
        tableView.reloadData()
        save()
    }
}

