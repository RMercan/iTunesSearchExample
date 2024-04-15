//
//  AudioPlayerManager.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 27.03.2024.
//

import Foundation
import UIKit

final class AudioPlayerManager: NSObject {
    
    static let shared = AudioPlayerManager()
    
    var selectedIndexForPlay: Int = -1
    
    func audioEvent(for media: Media, at indexPath: IndexPath) {
        if let player = AudioPlayerService.shared.audioPlayer, player.isPlaying {
            stopAudioForAll()
        }
        
        AudioPlayerService.shared.playAudio(for: media, at: indexPath)
        
        BottomSheetManager.shared.showBottomSheetView()
        BottomSheetManager.shared.setupPanGesture()
        BottomSheetManager.shared.setPlayButtonsActive()
    }
    
    func stopAudioForAll() {
        AudioPlayerService.shared.stopAudio()
        selectedIndexForPlay = -1
        BottomSheetManager.shared.setPlayButtonsPassive()
    }

}
