//
//  ListController.swift
//  evosipova_3PW3
//
//  Created by Elizabeth on 07.12.2022.
//

import Foundation

import UIKit

struct Results: Decodable {
    let articles: [Article]
}

struct Article: Decodable, Identifiable {
    var id : String? {
        source.id
    }
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let source: Source
}

struct Source: Codable {
    let id: String?
}

final class NewsViewModel {
    let title: String
    let description: String
    let imageURL: URL?
    var imageData: Data? = nil
    
    init(title: String, description: String, imageURL: URL?) {
        self.title = title
        self.description = description
        self.imageURL = imageURL
    }
}

final class NewsListViewController: UIViewController {
    private var tableView = UITableView(frame: .zero, style: .plain)
    private var isLoading = false
    private var newsViewModels = [NewsViewModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @objc
    private func goBack() {
        if (navigationController?.popViewController(animated: true) == nil) {
            dismiss(animated: true)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        self.title = "Articles"
        navigationItemUI()
        
        navigationItem.leftBarButtonItem?.tintColor = .label
        navigationItem.rightBarButtonItem?.tintColor = .label
        
        configureTableView()
    }
    
    
    private func navigationItemUI(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.counterclockwise"),
            style: .plain, target: self,
            action: #selector(menuButtonTapped)
        )
        
    }
    
    @objc
    private func menuButtonTapped() {
        isLoading = true
        fetchNews()
        tableView.reloadData()
        isLoading = false
    }
    
    private func configureTableView() {
        fetchNews()
        setTableViewUI()
        setTableViewDelegate()
        setTableViewCell()
    }
    
    private func setTableViewDelegate() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setTableViewUI() {
        view.addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.rowHeight = 120
        tableView.pinLeft(to: view)
        tableView.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        tableView.pinRight(to: view)
        tableView.pinBottom(to: view)
    }
    
    
    private func setTableViewCell() {
        tableView.register(NewsCell.self, forCellReuseIdentifier: NewsCell.reuseIdentifier)
    }
    
    
    final class NewsCell: UITableViewCell {
        static let reuseIdentifier = "NewsCell"
        private let newsImageView = UIImageView()
        private let newsTitleLabel = UILabel()
        private let newsDescriptionLabel = UILabel()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .none
            setupView()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
        }
        
        private func setupView() {
            setupImageView()
            setupTitleLabel()
            setupDescriptionLabel()
        }
        
        private func setupImageView() {
            newsImageView.layer.cornerRadius = 8
            newsImageView.layer.cornerCurve = .continuous
            newsImageView.clipsToBounds = true
            newsImageView.contentMode = .scaleAspectFill
            newsImageView.backgroundColor = .secondarySystemBackground
            
            contentView.addSubview(newsImageView)
            newsImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).isActive = true
            newsImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16).isActive = true
            newsImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12).isActive = true
            newsImageView.pinWidth(to: newsImageView.heightAnchor)
        }
        
        private func setupTitleLabel() {
            newsTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
            newsTitleLabel.textColor = .label
            newsTitleLabel.numberOfLines = 1
            
            contentView.addSubview(newsTitleLabel)
            newsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            newsTitleLabel.heightAnchor.constraint(equalToConstant: newsTitleLabel.font.lineHeight).isActive = true
            newsTitleLabel.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant: 12).isActive = true
            newsTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).isActive = true
            newsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
        }
        
        private func setupDescriptionLabel() {
            newsDescriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
            newsDescriptionLabel.textColor = .secondaryLabel
            newsDescriptionLabel.numberOfLines = 0
            
            contentView.addSubview(newsDescriptionLabel)
            newsDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            newsDescriptionLabel.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant: 12).isActive = true
            newsDescriptionLabel.topAnchor.constraint(equalTo: newsTitleLabel.bottomAnchor, constant: 0).isActive = true
            newsDescriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12).isActive = true
            newsDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
            
        }
        
        func configure(with: NewsViewModel) {
            newsTitleLabel.text = with.title
            newsDescriptionLabel.text = with.description
            
            
            if let data = with.imageData {
                newsImageView.image = UIImage(data: data)
            } else if let url = with.imageURL {
                URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                    guard let data = data else {
                        return
                    }
                    with.imageData = data
                    DispatchQueue.main.async {
                        self?.newsImageView.image = UIImage(data: data)
                    }
                }
                .resume()
            }
            
        }
    }
    
    private func fetchNews() {
        let keyURL = URL(string:"https://newsapi.org/v2/top-headlines?country=us&apiKey=915f896887f54c2791801aad7b0e9c99")
        
        if let url = keyURL {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if (error == nil) {
                    if let data = data {
                        do {
                            let results = try JSONDecoder().decode(Results.self, from: data)
                            
                            self.newsViewModels = results.articles.compactMap {
                                NewsViewModel(
                                    title: $0.title ?? "",
                                    description: $0.description ?? "No description",
                                    imageURL: URL(string: $0.urlToImage ?? "")
                                )
                            }
                            
                            DispatchQueue.main.async {
                                self.isLoading = false
                                self.tableView.reloadData()
                            }
                            
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            task.resume()
        }
    }
}

extension NewsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 0
        } else {
            return newsViewModels.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (!isLoading){
            let viewModel = newsViewModels[indexPath.row]
            if let newsCell = tableView.dequeueReusableCell(withIdentifier: NewsCell.reuseIdentifier, for: indexPath) as? NewsCell {
                newsCell.configure(with: viewModel)
                return newsCell
            }
        }
        return UITableViewCell()
    }
}

extension NewsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (!isLoading) {
            let newsCell = NewsViewController()
            newsCell.configure(with: newsViewModels[indexPath.row])
            navigationController?.pushViewController(newsCell, animated: true)
        }
    }
}
