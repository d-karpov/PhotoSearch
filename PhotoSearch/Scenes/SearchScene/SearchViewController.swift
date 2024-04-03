//
//  SearchViewController.swift
//  PhotoSearch
//
//  Created by Денис Карпов on 20.03.2024.
//

import UIKit

protocol ISearchView: AnyObject {
	func setupIU()
	func shiftSearchBar()
	func startLoading()
	func showNonResultLabel()
	func showResults()
	func reloadCollection()
	func showAlert(title: String, with message: String)
}

class SearchViewController: UIViewController {
	
	private lazy var searchField: UISearchTextField = makeSearchField()
	private lazy var searchButton: UIButton = makeSearchButton()
	private lazy var searchBar: UIStackView = makeSearchBar()
	private lazy var searchResult: UICollectionView = makeSearchResultCollection()
	private lazy var activityIndicator: UIActivityIndicatorView = makeActivityIndicator()
	private lazy var nonResultLable: UILabel = makeNonResultLabel()
	
	var presenter: ISearchViewPresenter!
	var router: ISearchViewRouter!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		presenter.viewIsReady()
		searchResult.dataSource = self
		searchResult.delegate = self
		searchField.delegate = self
	}
	
}

// MARK: - UICollectionViewDataSource
extension SearchViewController: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		presenter.cellsCount()
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
		presenter.prepareCell(at: indexPath, cell: cell)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
		if let image = cell.imageView.image {
			router.showDetailScene(of: image)
		}
	}
	
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let size = (collectionView.frame.width)/3.15
		return CGSize(width: size, height: size)
	}
}

// MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		searchStarted()
		return true
	}
}

// MARK: - Private extension for UI methods
private extension SearchViewController {
	
	func layout() {
		view.addSubview(searchBar)
		searchBar.addArrangedSubview(searchField)
		searchBar.addArrangedSubview(searchButton)
		view.addSubview(searchResult)
		view.addSubview(activityIndicator)
		view.addSubview(nonResultLable)
		setupConstraints()
	}
	
	func setupConstraints() {
		
		NSLayoutConstraint.activate([
			searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:view.bounds.height/4),
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
		searchButton.addTarget(self, action: #selector(searchStarted), for: .touchUpInside)
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
	
	func createCollectionLayout() -> UICollectionViewLayout {
		let layout = UICollectionViewFlowLayout()
		layout.minimumInteritemSpacing = 6
		return layout
	}
	
	func makeSearchResultCollection() -> UICollectionView {
		let searchResult = UICollectionView(frame: .zero, collectionViewLayout: createCollectionLayout())
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
	
	func stopLoading() {
		activityIndicator.stopAnimating()
	}
	
	@objc func searchStarted() {
		presenter.search(request: searchField.text!)
	}
	
	func callAlert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(alertAction)
		present(alert, animated: true, completion: nil)
	}
}

extension SearchViewController: ISearchView {
	func setupIU() {
		layout()
		view.backgroundColor = .white
		searchResult.backgroundColor = .white
	}
	
	func shiftSearchBar() {
		searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
	}
	
	func startLoading() {
		nonResultLable.isHidden = true
		searchResult.isHidden = true
		activityIndicator.startAnimating()
		searchField.resignFirstResponder()
	}
	
	func showNonResultLabel() {
		stopLoading()
		nonResultLable.isHidden = false
	}
	
	func showResults() {
		stopLoading()
		searchResult.isHidden = false
	}
	
	func reloadCollection() {
		searchResult.reloadData()
	}
	
	func showAlert(title: String, with message: String) {
		stopLoading()
		callAlert(title: title, message: message)
	}
}
