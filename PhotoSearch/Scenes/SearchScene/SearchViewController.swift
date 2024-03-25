//
//  SearchViewController.swift
//  PhotoSearch
//
//  Created by Денис Карпов on 20.03.2024.
//

import UIKit
#if DEBUG
import SwiftUI
#endif

class SearchViewController: UIViewController {
	
	private lazy var searchField: UISearchTextField = makeSearchField()
	private lazy var searchButton: UIButton = makeSearchButton()
	private lazy var searchBar: UIStackView = makeSearchBar()
	private lazy var searchResult: UICollectionView = makeSearchResult()
	private lazy var activityIndicator: UIActivityIndicatorView = makeActivityIndicator()
	private lazy var nonResultLable: UILabel = makeNonResultLabel()
	private var imageUrls: PhotoUrls?
	private var isSearched = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		searchResult.dataSource = self
		searchResult.delegate = self
		searchField.delegate = self
	}
	
}

// MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let count = imageUrls?.results.count else { return 0 }
		return count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
		if let url = imageUrls?.results[indexPath.item].urls.regular {
			do {
				let data = try Data(contentsOf: url)
				cell.configure(UIImage(data: data)!)
			} catch {
				print("Проблема при распаковке картинки ячейку")
			}
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let detailImageView = DetailViewController()
		let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
		detailImageView.imageView.image = cell.imageView.image
		detailImageView.modalPresentationStyle = .pageSheet
		present(detailImageView, animated: true)
	}
	
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let size = (collectionView.frame.width)/3.15
		return CGSize(width: size, height: size)
	}
}

extension SearchViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		fetchImageUrls()
		return true
	}
}

// MARK: - Private extension for UI methods
private extension SearchViewController {
	
	func setupUI() {
		layout()
		setSearchActions()
		view.backgroundColor = .white
		searchResult.backgroundColor = .white
	}
	
	func layout() {
		view.addSubview(searchBar)
		searchBar.addArrangedSubview(searchField)
		searchBar.addArrangedSubview(searchButton)
		view.addSubview(searchResult)
		view.addSubview(activityIndicator)
		view.addSubview(nonResultLable)
		
		layoutConstraints()
	}
	
	func layoutConstraints() {
		
		NSLayoutConstraint.activate([
			searchBar.topAnchor.constraint(
				equalTo: view.safeAreaLayoutGuide.topAnchor,
				constant: isSearched ? 0 : view.bounds.height/4
			),
			searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			searchBar.heightAnchor.constraint(equalToConstant: 50)
		])
		
		NSLayoutConstraint.activate([
			searchResult.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
			searchResult.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			searchResult.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			searchResult.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
		
		NSLayoutConstraint.activate([
			nonResultLable.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 40),
			nonResultLable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			nonResultLable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
		])
		
	}
	
	func makeActivityIndicator() -> UIActivityIndicatorView {
		let indicator = UIActivityIndicatorView(style: .large)
		indicator.color = .darkGray
		indicator.center = view.center
		
		return indicator
	}
	
	func makeSearchField() -> UISearchTextField {
		let searchField = UISearchTextField()

		searchField.placeholder = "Телефоны, яблоки, груши, снег"
		searchField.backgroundColor = .white
		searchField.returnKeyType = .search
		
		return searchField
	}
	
	func makeSearchButton() -> UIButton {
		var configuration = UIButton.Configuration.filled()
		configuration.titleAlignment = .center
		configuration.cornerStyle = .large
		configuration.contentInsets = NSDirectionalEdgeInsets(
			top: 14.5,
			leading: 16,
			bottom: 14.5,
			trailing: 16
		)
		configuration.baseBackgroundColor = .red
		configuration.title = "Найти"
		
		let searchButton = UIButton(configuration: configuration)
		
		return searchButton
	}
	
	func makeSearchBar() -> UIStackView {
		let searchBar = UIStackView()
		searchBar.translatesAutoresizingMaskIntoConstraints = false
		
		searchBar.axis = .horizontal
		searchBar.alignment = .fill
		searchBar.distribution = .fill
		searchBar.spacing = 8

		return searchBar
	}
	
	func makeSearchResult() -> UICollectionView {
		let searchResult = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
		searchResult.translatesAutoresizingMaskIntoConstraints = false
		
		searchResult.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
		searchResult.showsVerticalScrollIndicator = false
		return searchResult
	}
	
	func makeNonResultLabel() -> UILabel {
		let label = UILabel()
		
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .systemFont(ofSize: 16, weight: .light)
		label.text = "К сожалению, поиск не дал результатов"
		label.textColor = .systemGray
		label.isHidden = true
		
		return label
	}
	
	func createLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewFlowLayout()
		layout.minimumInteritemSpacing = 6
		return layout
	}
	
	func setSearchActions() {
		searchButton.addTarget(self, action: #selector(fetchImageUrls), for: .touchUpInside)
	}
	
	func clearSearchResults() {
		imageUrls = nil
		nonResultLable.isHidden = true
		searchResult.reloadData()
	}
	
	@objc func fetchImageUrls() {
		isSearched = true
		layout()
		clearSearchResults()
		activityIndicator.startAnimating()
		
		NetworkManager.getImagesUrls(about: searchField.text!) { [weak self] photoUrls in
			switch photoUrls {
			case .success(let photoUrls):
				DispatchQueue.main.async {
					self?.imageUrls = photoUrls
					if photoUrls.results.isEmpty {
						self?.nonResultLable.isHidden = false
					}
					self?.searchResult.reloadData()
					self?.activityIndicator.stopAnimating()
				}
			case .failure(let error):
				print("\(error.errorDescription ?? "Бесовство")")
			}
		}
		
	}
}


// MARK: - PreviewProvider
#if DEBUG
struct SearchViewControllerProvider: PreviewProvider {
	static var previews: some View {
		Group {
			SearchViewController().preview()
		}
	}
}
#endif
