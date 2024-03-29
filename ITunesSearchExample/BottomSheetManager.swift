//
//  BottomSheetManager.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 27.03.2024.
//

import Foundation
import UIKit
import Kingfisher
import AVFAudio

enum PlayerViewType {
    case mini
    case fullScreen
}

final class BottomSheetManager: NSObject {
    
    static let shared = BottomSheetManager()
    
    lazy var bottomSheetView: BottomSheetView = {
        let view = BottomSheetView()
        view.backgroundColor = .systemBlue
        view.isHidden = true
        return view
    }()
    
    let miniPlayerView = MiniPlayerView()
    let fullScreenPlayerView = FullScreenPlayerView()
    let audioPlayerService = AudioPlayerService()
    let homepageView = HomepageView()
    
    var playerViewType: PlayerViewType = .mini
    
    func addBottomSheetViewToWindow() {
        guard let window = UIApplication.shared.windows.last else { return }
        window.addSubview(bottomSheetView)
        
        bottomSheetView.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width)
            make.top.equalToSuperview().inset(UIScreen.main.bounds.height - self.bottomSheetView.safeAreaBottom - 75)
//            make.height.equalTo(75)
            make.width.equalTo(UIScreen.main.bounds.width)
            make.height.equalTo(UIScreen.main.bounds.height)
        }
    }
    
    func hideBottomSheetView() {
        bottomSheetView.isHidden = true
    }
    
    func showBottomSheetView() {
        bottomSheetView.isHidden = false
    }
    
//    func setupGesture() {
//        bottomSheetView.setupPanGesture()
//    }
//    
    func setupPanGesture() {
        // pan gesture recognizer'ı view controller'ın görünümüne ekle (tüm ekran)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // Hareketi hemen dinlemek için false'a değiştir
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        bottomSheetView.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.bottomSheetView)
        
        let velocity = gesture.velocity(in: self.bottomSheetView)
        // Bottom sheet view'ın boyutları içindeki hareketleri kontrol etmek için koordinatları bottom sheet view'a dönüştür
        let translatedPoint = gesture.location(in: self.bottomSheetView)
        
        
        // Sadece bottom sheet view'ın boyutları içindeki hareketleri işle
            
            // Yukarı çekmek eksi değer olacak veya tam tersi
            print("Pan gesture y offset: \(translation.y)")
        
        print("Pan gesture translatedPoint: \(translatedPoint)")
            
            // Sürükleme yönünü al
            let isDraggingDown = translation.y > 0
            print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")
        
        print("velocity.y: ", velocity.y)
        
            
            // Yeni yükseklik, sürükleme değerine ve mevcut konteyner yüksekliğine dayanır
//            let newHeight = currentContainerHeight - translation.y
            
            // gesture durumuna göre işlem yap
        
            switch gesture.state {
            case .changed:
                print("Change Pan gesture y offset: \(translation.y)")
                // Bu durum, kullanıcı sürüklediğinde oluşur
//                bottomSheetView.snp.updateConstraints { make in
//                    make.top.equalToSuperview().inset(UIScreen.main.bounds.height - self.bottomSheetView.safeAreaBottom - 75 - (-translation.y))
//                }
                if playerViewType == .mini {
                    setAlpha(alpha: (100 - (-translation.y)) * 0.01)
                    bottomSheetView.snp.updateConstraints { make in
                        make.top.equalToSuperview().inset(UIScreen.main.bounds.height - self.bottomSheetView.safeAreaBottom - 75 - (-translation.y))
                    }
                } else {
                    let padding = UIScreen.main.bounds.height - self.bottomSheetView.safeAreaBottom - 75 - 100
                    setAlpha(alpha: (translation.y - padding) * 0.01)
                    bottomSheetView.snp.updateConstraints { make in
                        make.top.equalToSuperview().inset(translation.y)
                    }
                }
                
            case .ended:
                print("Ended Pan gesture y offset: \(translation.y)")
                if velocity.y < 0 {
                    
                    bottomSheetView.snp.updateConstraints { make in
                        make.top.equalToSuperview()
                    }
                    UIView.animate(withDuration: 0.3) {
                        self.bottomSheetView.superview?.layoutIfNeeded()
                        self.bottomSheetView.layoutIfNeeded()
                        self.setAlpha(alpha: 0)
                    }
                    playerViewType = .fullScreen
                } else {
                    bottomSheetView.snp.updateConstraints { make in
                        make.top.equalToSuperview().inset(UIScreen.main.bounds.height - self.bottomSheetView.safeAreaBottom - 75)
                    }
                    UIView.animate(withDuration: 0.3) {
                        self.bottomSheetView.superview?.layoutIfNeeded()
                        self.bottomSheetView.layoutIfNeeded()
                        self.setAlpha(alpha: 1)
                    }
                    playerViewType = .mini
                }
                
                // Bu durum, kullanıcı sürüklemeyi durdurduğunda oluşur, bu yüzden konteynerin son yüksekliğini alacağız
                
            default:
                break
            }
        
    }
    
//    func updateContent(url: String) {
//        guard let url = URL(string: url) else { return }
//        bottomSheetView.fullScreenPlayerView.fullScreenItemImageView.kf.setImage(with: url)
//    }
    
    func updateContent(media: Media) {
        let url60 = URL(string: media.artworkUrl60)
        let url100 = URL(string: media.artworkUrl100)
        bottomSheetView.miniPlayerView.miniItemImageView.kf.setImage(with: url60)
        bottomSheetView.miniPlayerView.miniItemTitleLabel.text = media.artistName
        bottomSheetView.fullScreenPlayerView.fullScreenItemImageView.kf.setImage(with: url100)
        bottomSheetView.fullScreenPlayerView.fullScreenItemTitleLabel.text = media.artistName
        bottomSheetView.fullScreenPlayerView.itemSubtitleLabel.text = media.collectionName
        
        if audioPlayerService.isAudioPlaying() {
//            bottomSheetView.miniPlayerView.miniPlayButton.isSelected = true
//            bottomSheetView.fullScreenPlayerView.fullScreenPlayButton.isSelected = true
        } else {
//            bottomSheetView.miniPlayerView.miniPlayButton.isSelected = false
//            bottomSheetView.fullScreenPlayerView.fullScreenPlayButton.isSelected = false
        }
    }
    
    func setPlayButtonsActive() {
        bottomSheetView.miniPlayerView.miniPlayButton.isSelected = true
        bottomSheetView.fullScreenPlayerView.fullScreenPlayButton.isSelected = true
        // Tüm koleksiyonu döngüye alarak hücreleri kontrol et
        for cell in homepageView.collectionView.visibleCells {
            guard let cell = cell as? iTunesCollectionViewCell else { return }
            cell.playButton.isSelected = true
        }
    }
    
    func setPlayButtonsPassive() {
        bottomSheetView.miniPlayerView.miniPlayButton.isSelected = false
        bottomSheetView.fullScreenPlayerView.fullScreenPlayButton.isSelected = false
        // Tüm koleksiyonu döngüye alarak hücreleri kontrol et
        for cell in homepageView.collectionView.visibleCells {
            guard let cell = cell as? iTunesCollectionViewCell else { return }
            cell.playButton.isSelected = false
        }
    }
    
    func setAlpha(alpha: CGFloat) {
//        bottomSheetView.miniPlayButton.alpha = alpha
        bottomSheetView.miniPlayerView.alpha = alpha
    }
    
//    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: self)
//        
//        // Bottom sheet view'ın boyutları içindeki hareketleri kontrol etmek için koordinatları bottom sheet view'a dönüştür
//        let translatedPoint = gesture.location(in: containerView)
//        
//        // Sadece bottom sheet view'ın boyutları içindeki hareketleri işle
//        if containerView.bounds.contains(translatedPoint) {
//            
//            // Yukarı çekmek eksi değer olacak veya tam tersi
//            print("Pan gesture y offset: \(translation.y)")
//            
//            // Sürükleme yönünü al
//            let isDraggingDown = translation.y > 0
//            print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")
//            
//            // Yeni yükseklik, sürükleme değerine ve mevcut konteyner yüksekliğine dayanır
//            let newHeight = currentContainerHeight - translation.y
//            
//            // gesture durumuna göre işlem yap
//            switch gesture.state {
//            case .changed:
//                // Bu durum, kullanıcı sürüklediğinde oluşur
//                if newHeight < maximumContainerHeight {
//                    // Yükseklik kısıtlamasını sürekli güncelle
//                    containerViewHeightConstraint?.constant = newHeight
//                    // refresh layout
//                    self.layoutIfNeeded()
//                }
//            case .ended:
//                // Bu durum, kullanıcı sürüklemeyi durdurduğunda oluşur, bu yüzden konteynerin son yüksekliğini alacağız
//                
//                //Koşul 1: Yeni yükseklik min altındaysa, denetleyiciyi kapat
//                if newHeight < dismissibleHeight {
//                    //self.animateDismissView()
//                    animateContainerHeight(defaultHeight)
//                    playerViewType = .mini
//                }
//                else if newHeight < defaultHeight {
//                    // Koşul 2: Yeni yükseklik varsayılanın altındaysa, varsayılana geri döndür
//                    animateContainerHeight(defaultHeight)
//                    playerViewType = .mini
//                }
//                else if newHeight < maximumContainerHeight && isDraggingDown {
//                    // Koşul 3: Yeni yükseklik maksimumun altında ve aşağı gidiyorsa, varsayılan yüksekliğe ayarla
//                    animateContainerHeight(defaultHeight)
//                    playerViewType = .mini
//                }
//                else if newHeight > defaultHeight && !isDraggingDown {
//                    // Koşul 4: Yeni yükseklik maksimumun altında ve yukarı gidiyorsa, en üstte maksimum yüksekliğe ayarla
//                    animateContainerHeight(maximumContainerHeight)
//                    playerViewType = .fullScreen
//                }
//            default:
//                break
//            }
//        }
//    }
    
}
