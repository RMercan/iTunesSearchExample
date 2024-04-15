//
//  MiniPlayerView.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 15.03.2024.
//

import UIKit
import SnapKit
import Kingfisher

final class MiniPlayerView: UIView {
   
    lazy var miniItemImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill // Görüntüyü uygun şekilde ölçeklendir
        imageView.clipsToBounds = true // Görüntünün sınırların dışına çıkmasını önle
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    lazy var miniItemTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    lazy var miniPlayButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.setImage(UIImage(named: "playIcon"), for: .normal)
        button.setImage(UIImage(named: "pauseIcon"), for: .selected)
        return button
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00.00/00.00"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .systemBackground
        setupViews()
        setupLayouts()
    }
    
    required init? (coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(miniItemImageView)
        addSubview(miniItemTitleLabel)
        addSubview(miniPlayButton)
        addSubview(timeLabel)
    }
    
    func setupLayouts() {
        miniItemImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(10)
            make.width.equalTo(60)
        }
        
        miniItemTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(miniItemImageView.snp.trailing).offset(10)
            make.top.bottom.equalToSuperview().inset(5)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(miniItemTitleLabel.snp.trailing).offset(7)
            make.trailing.equalTo(miniPlayButton.snp.leading).offset(-10)
        }
        
        miniPlayButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(40)
        }
    }
   
}
