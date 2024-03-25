//
//  PhotoCellView.swift
//  PhotoSearch
//
//  Created by Денис Карпов on 21.03.2024.
//

import UIKit


final class PhotoCell: UICollectionViewCell {
	
	let imageView: UIImageView = UIImageView()
	
	static let identifier = "photoCell"
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = 10
		
		NSLayoutConstraint.activate([
			imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			imageView.heightAnchor.constraint(equalTo: heightAnchor),
			imageView.widthAnchor.constraint(equalTo: widthAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func configure( _ image: UIImage) {
		imageView.image = image
	}
	
}
