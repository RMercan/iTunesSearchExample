//
//  BottomSheetView.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 15.03.2024.
//

import UIKit
import SnapKit

class BottomSheetView: UIView {
    
    lazy var fullScreenPlayerView: FullScreenPlayerView = {
        let view = FullScreenPlayerView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var miniPlayerView: MiniPlayerView = {
        let view = MiniPlayerView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 10
        return view
    }()
    
    let defaultHeight: CGFloat = 75
    
    let dismissibleHeight: CGFloat = 20
    
    // Dynamic container constraint
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    let audioPlayerService = AudioPlayerService()
    let bottomSheetManager = BottomSheetManager()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if window != nil {
            // View göründüğünde yapılacak işlemler
            self.animatePresentContainer()
        }
    }
    
    func setupViews() {
        addSubview(fullScreenPlayerView)
        addSubview(miniPlayerView)
    }
    
    func setupLayouts() {
        
        miniPlayerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(75)
        }
        
        fullScreenPlayerView.snp.makeConstraints { make in
            make.top.equalTo(miniPlayerView.snp.bottom).offset(40)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
    }
    
    func animatePresentContainer() {
        // Animasyon bloğunda bottom constraint güncelle
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // kısıtlamayı yenilemek için çağır
            self.layoutIfNeeded()
        }
    }
 
}



