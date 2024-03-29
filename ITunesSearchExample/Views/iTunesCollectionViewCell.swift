//
//  iTunesCollectionViewCell.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 4.03.2024.
//

import UIKit
import SnapKit

final class iTunesCollectionViewCell: UICollectionViewCell {
    
    var isFavorite: Bool = false
    
    var media: Media?
    
    lazy var itemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill // Görüntüyü uygun şekilde ölçeklendir
        imageView.clipsToBounds = true // Görüntünün sınırların dışına çıkmasını önle
        return imageView
    }()
    
    lazy var itemTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.setImage(UIImage(named: "playIcon"), for: .normal)
        button.setImage(UIImage(named: "pauseIcon"), for: .selected)
        return button
    }()
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.setImage(UIImage(named: "favStarIconLight"), for: .normal)
        button.setImage(UIImage(named: "favStarIconDark"), for: .selected)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(itemImageView)
        addSubview(itemTitleLabel)
        addSubview(playButton)
        addSubview(favoriteButton)
        
        playButton.widthAnchor.constraint(equalTo: playButton.heightAnchor).isActive = true
        favoriteButton.widthAnchor.constraint(equalTo: favoriteButton.heightAnchor).isActive = true
        let commonHeightConstraint = playButton.heightAnchor.constraint(equalTo: favoriteButton.heightAnchor)
        commonHeightConstraint.isActive = true
        
    }
    
    func setupLayouts() {
        itemImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(5)
            make.width.equalTo(60)
        }

        itemTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(itemImageView.snp.trailing).offset(10)
            make.trailing.equalTo(playButton.snp.leading).offset(-7)
            make.top.bottom.equalToSuperview().inset(5)
        }
        
        playButton.snp.makeConstraints { make in
            make.trailing.equalTo(favoriteButton.snp.leading).offset(-5) 
            make.centerY.equalToSuperview()
            make.height.width.equalTo(40)
        }
        
        favoriteButton.snp.makeConstraints{ make in
            make.trailing.equalToSuperview().inset(5)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(40)
        }
    }

}

// MARK: - Configure
extension iTunesCollectionViewCell {
    
    func configure(index: Int, selectedIndex: Int, media: Media) {
        favoriteButton.isSelected = isFavorite
        playButton.isSelected = index == selectedIndex
        self.media = media
    }
}
