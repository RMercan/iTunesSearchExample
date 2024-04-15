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
        view.backgroundColor = .systemGray5
        view.isHidden = true
        return view
    }()
    
    let miniPlayerView = MiniPlayerView()
    let fullScreenPlayerView = FullScreenPlayerView()
    
    var playerViewType: PlayerViewType = .mini
    
    func addBottomSheetViewToWindow() {
        guard let window = UIApplication.shared.windows.last else { return }
        window.addSubview(bottomSheetView)
        
        bottomSheetView.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width)
            make.top.equalToSuperview().inset(UIScreen.main.bounds.height - self.bottomSheetView.safeAreaBottom - 75)
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
    
    func updateContent(media: Media) {
        let url60 = URL(string: media.artworkUrl60)
        let url100 = URL(string: media.artworkUrl100)
        bottomSheetView.miniPlayerView.miniItemImageView.kf.setImage(with: url60)
        bottomSheetView.miniPlayerView.miniItemTitleLabel.text = media.artistName
        bottomSheetView.fullScreenPlayerView.fullScreenItemImageView.kf.setImage(with: url100)
        bottomSheetView.fullScreenPlayerView.fullScreenItemTitleLabel.text = media.artistName
        bottomSheetView.fullScreenPlayerView.itemSubtitleLabel.text = media.collectionName
        
    }
    
    func updateTimeLabels() {
        guard let player = AudioPlayerService.shared.audioPlayer else { return }
        let currentTime = player.currentTime
        AudioPlayerService.shared.formattedCurrentTime = AudioPlayerService.shared.formattedTime(time: currentTime)
        print("Current time: \(AudioPlayerService.shared.formattedCurrentTime)")
        AudioPlayerService.shared.formattedTotalTime = AudioPlayerService.shared.formattedTime(time: AudioPlayerService.shared.totalTime)
        print("Total time: \(AudioPlayerService.shared.formattedTotalTime)")
        
        bottomSheetView.miniPlayerView.timeLabel.text = "\(AudioPlayerService.shared.formattedCurrentTime)/\(AudioPlayerService.shared.formattedTotalTime)"
        bottomSheetView.fullScreenPlayerView.currentTimeLabel.text = "\(AudioPlayerService.shared.formattedCurrentTime)"
        bottomSheetView.fullScreenPlayerView.totalTimeLabel.text = "\(AudioPlayerService.shared.formattedTotalTime)"
//        DispatchQueue.main.async {
//            BottomSheetManager.shared.miniPlayerView.timeLabel.text = "\(self.formattedCurrentTime)/\(self.formattedTotalTime)"
//            BottomSheetManager.shared.fullScreenPlayerView.currentTimeLabel.text = "\(self.formattedCurrentTime)"
//            BottomSheetManager.shared.fullScreenPlayerView.totalTimeLabel.text = "\(self.formattedTotalTime)"
//        }
    }

    
    func setPlayButtonsActive() {
        bottomSheetView.miniPlayerView.miniPlayButton.isSelected = true
        bottomSheetView.fullScreenPlayerView.fullScreenPlayButton.isSelected = true
    }
    
    func setPlayButtonsPassive() {
        bottomSheetView.miniPlayerView.miniPlayButton.isSelected = false
        bottomSheetView.fullScreenPlayerView.fullScreenPlayButton.isSelected = false
    }
    
    func setAlpha(alpha: CGFloat) {
        bottomSheetView.miniPlayerView.alpha = alpha
    }
    
}


//MARK: Pan Gesture --------
extension BottomSheetManager {
    
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
        
        
        // Sadece bottom sheet view'ın boyutları içindeki hareketleri işle:
        // Yukarı çekmek eksi değer olacak veya tam tersi
        print("Pan gesture y offset: \(translation.y)")
        
        print("Pan gesture translatedPoint: \(translatedPoint)")
        
        // Sürükleme yönünü al
        let isDraggingDown = translation.y > 0
        print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")
        
        print("velocity.y: ", velocity.y)
        
        // gesture durumuna göre işlem yap
        switch gesture.state {
        case .changed:
            print("Change Pan gesture y offset: \(translation.y)")
            
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
                        
        default:
            break
        }
        
    }
    
}
