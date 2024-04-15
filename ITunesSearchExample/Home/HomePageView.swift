//
//  HomePageView.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 3.03.2024.
//

import UIKit
import SnapKit

final class HomepageView: UIView {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 20, height: 70) // Hücre boyutları
        layout.minimumLineSpacing = 10 // Hücreler arası minimum boşluk
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0) // Bütün koleksiyon bölgesinin iç içe boşlukları
        
        layout.scrollDirection = .vertical
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(iTunesCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return view
    }()
    
    lazy var navigationBarItems: NavigationBarItems = {
        let items = NavigationBarItems()
        return items
    }()
    
    lazy var beginningLabel: UILabel = {
        let label = UILabel()
        label.text = "No data to show can be found. Use the search bar for see the data."
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
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
        addSubview(collectionView)
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        addSubview(navigationBarItems)
        addSubview(beginningLabel)
    }
    
    func setupLayouts(){
        navigationBarItems.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(5)
        }

        collectionView.snp.makeConstraints{ make in
            make.top.equalTo(navigationBarItems.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
        }
        
        beginningLabel.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBarItems.snp.bottom).offset(200)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
}

