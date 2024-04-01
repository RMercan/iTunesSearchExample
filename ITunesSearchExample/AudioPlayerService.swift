//
//  AudioPlayerService.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 12.03.2024.
//

import Foundation
import AVFoundation

protocol AudioPlayerServiceDelegate: AnyObject {
    func didUpdateProgress(_ progress: Float)
    func finishPlaying()
}

final class AudioPlayerService: NSObject, AVAudioPlayerDelegate {
    
    weak var delegate: AudioPlayerServiceDelegate?

    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    
    //FIXME: check this: is there any caller
    var currentPlayingIndexPath: IndexPath?
    var currentPlayingMedia: Media?
    var currentIndex: Int = -1
    var playlist: [Media] = []
    var totalTime: TimeInterval = 0.0
    
    func playAudio(for media: Media, at indexPath: IndexPath) {
        // Önceki timerı durdur
        timer?.invalidate()
        
        guard let audioURL = URL(string: media.previewUrl) else {
            print("Invalid audio URL")
            return
        }
        let task = URLSession.shared.dataTask(with: audioURL) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Audio data not received: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                do {
                    self.currentPlayingMedia = media
                    self.playMedia(at: indexPath.row) 
                    self.currentPlayingIndexPath = indexPath

                    self.audioPlayer = try AVAudioPlayer(data: data)
                    self.audioPlayer?.delegate = self
                    self.audioPlayer?.play()
                    
                    // İlerleme durumunu güncellemek için zamanlayıcıyı başlat
                    self.startUpdatingProgress()
                    
                    // Medyanın toplam süresi
                    self.totalTime =  self.audioPlayer?.duration ?? 1
                    
                    
                    BottomSheetManager.shared.updateContent(media: media)
                } catch {
                    print("Error playing audio: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
    
    func startUpdatingProgress() {
        // Zaten bir timer varsa, durdur
        timer?.invalidate()
        
        // Yeni bir timer oluştur ve başlat
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            guard let player = self.audioPlayer else { return }
            
            let progress = Float(player.currentTime / player.duration)
            self.delegate?.didUpdateProgress(progress)
        }
    }
    
    
    func stopAudio() {
        // timerı durdur
        timer?.invalidate()
        
        if let existingPlayer = audioPlayer, existingPlayer.isPlaying {
            existingPlayer.stop()
//            currentPlayingMedia = nil
//            currentPlayingIndexPath = nil
        }
        
        delegate?.finishPlaying()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            stopAudio()
        }
    }
    
    func isAudioPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    func playPauseToggle(for media: Media, at indexPath: IndexPath) {
        if isAudioPlaying() {
            stopAudio()
        } else {
            playAudio(for: media, at: indexPath)
        }
    }
    
    func playMedia(at index: Int) {
        guard index >= 0 && index < playlist.count else { return }
        currentIndex = index
        let media = playlist[currentIndex]
    }
    
    func playNext() {
        guard !playlist.isEmpty else {
            print("Playlist is empty!")
            return // Playlist boşsa işlemi durdur
        }
        
        let nextIndex = (currentIndex + 1) % playlist.count
        currentIndex = nextIndex
        
        let media = playlist[nextIndex]
        playAudio(for: media, at: IndexPath(item: nextIndex, section: 0))
    }

    func playPrevious() {
        guard !playlist.isEmpty else {
            print("Playlist is empty!")
            return // Playlist boşsa işlemi durdur
        }
        
        let previousIndex = (currentIndex - 1 + playlist.count) % playlist.count
        currentIndex = previousIndex
        
        let media = playlist[previousIndex]
        playAudio(for: media, at: IndexPath(item: previousIndex, section: 0))
    }

}


    
