//
//  NavigationBarItems.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 4.03.2024.
//

import UIKit
import SnapKit

final class NavigationBarItems: UIView, UISearchBarDelegate {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "iTunes"
        label.textAlignment = .center
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()

    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search content"
        searchBar.delegate = self
        searchBar.showsScopeBar = true
        let scopeButtonTitles = ["audiobook",
                                 "music"]
        searchBar.scopeButtonTitles = scopeButtonTitles
        // Search barın scope barındaki varsayılan seçimi kaldır
        searchBar.selectedScopeButtonIndex = -1
        return searchBar
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        setupViews()
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        addSubview(titleLabel)
        addSubview(searchBar)

    }

    func setupLayouts() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(self.safeAreaBottom + 20)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
        }
    }
    
}

