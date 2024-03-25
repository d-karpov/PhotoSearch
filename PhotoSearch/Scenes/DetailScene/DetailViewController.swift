//
//  DetailViewController.swift
//  PhotoSearch
//
//  Created by Денис Карпов on 26.03.2024.
//

import UIKit
import SwiftUI

class DetailViewController: UIViewController {
	
	let imageView: UIImageView = UIImageView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		view.addSubview(imageView)

		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.bounds.height/2),
			imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
		])

	}
}


// MARK: - PreviewProvider
#if DEBUG
struct DetailViewControllerProvider: PreviewProvider {
	static var previews: some View {
		Group {
			DetailViewController().preview()
		}
	}
}
#endif
