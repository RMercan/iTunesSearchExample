//
//  FullScreenPlayerView.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 15.03.2024.
//

import UIKit
import SnapKit
import Kingfisher

final class FullScreenPlayerView: UIView {

    lazy var fullScreenItemImageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.backgroundColor = .orange
        imageView.contentMode = .scaleAspectFit // Görüntüyü uygun şekilde ölçeklendir
        imageView.clipsToBounds = true // Görüntünün sınırların dışına çıkmasını önle
        return imageView
    }()
    
    lazy var fullScreenItemTitleLabel: UILabel = {
        let label = UILabel()
//        label.text = "Title"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    lazy var itemSubtitleLabel: UILabel = {
        let label = UILabel()
//        label.text = "Subtitle"
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    lazy var fullScreenPlayButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.setImage(UIImage(named: "playIcon"), for: .normal)
        button.setImage(UIImage(named: "pauseIcon"), for: .selected)
        return button
    }()
    
    lazy var previousButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.setImage(UIImage(named: "previous"), for: .normal)
        return button
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.setImage(UIImage(named: "next-button"), for: .normal)
        return button
    }()
    
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = .gray
        progressView.trackTintColor = .lightGray
        return progressView
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
        addSubview(fullScreenItemImageView)
        addSubview(fullScreenItemTitleLabel)
        addSubview(itemSubtitleLabel)
        addSubview(fullScreenPlayButton)
        addSubview(previousButton)
        addSubview(nextButton)
        addSubview(progressView)
    }
    
    func setupLayouts() {
        fullScreenItemImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(self.safeAreaTop + 20)
            make.height.equalTo(fullScreenItemImageView.snp.width)
        }
        
        fullScreenItemTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(fullScreenItemImageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(25)
            make.height.equalTo(20)
        }
        
        itemSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(fullScreenItemTitleLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().inset(25)
            make.trailing.equalToSuperview().inset(30)
            make.height.equalTo(20)
        }
        
        progressView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(itemSubtitleLabel.snp.bottom).offset(20)
            make.height.equalTo(10)
        }
        
        fullScreenPlayButton.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(60)
        }
        
        previousButton.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(20)
            make.trailing.equalTo(fullScreenPlayButton.snp.leading).inset(-10)
            make.height.width.equalTo(60)
        }
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(20)
            make.leading.equalTo(fullScreenPlayButton.snp.trailing).offset(10)
            make.height.width.equalTo(60)
        }
    }
    
}

