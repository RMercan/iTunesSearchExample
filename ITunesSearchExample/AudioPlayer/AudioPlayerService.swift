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
    func didPlayedMedia(media: Media)
}

final class AudioPlayerService: NSObject, AVAudioPlayerDelegate {
    
    weak var delegate: AudioPlayerServiceDelegate?

    static let shared = AudioPlayerService()
    
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
    var currentPlayingMedia: Media?
    var selectedScopeIndexForScopeBar: Int = -1
    var currentIndex: Int = -1
    var totalTime: TimeInterval = 0.0
    var formattedCurrentTime: String = "00.00"
    var formattedTotalTime: String = "00.00"
    
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
                    
                    self.audioPlayer = try AVAudioPlayer(data: data)
                    self.audioPlayer?.delegate = self
                    self.audioPlayer?.play()
                    
                    // İlerleme durumunu güncellemek için zamanlayıcıyı başlat
                    self.startUpdatingProgress()
                    
                    // Medyanın toplam süresi
                    self.totalTime =  self.audioPlayer?.duration ?? 1
                    print("Total Time: \(self.totalTime)")
                    BottomSheetManager.shared.updateContent(media: media)
                } catch {
                    print("Error playing audio: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
        
        self.delegate?.didPlayedMedia(media: media)
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
    
    func playMedia(at index: Int) {
        guard index >= 0 && index < MediasService.shared.playlist.count else { return }
        currentIndex = index
    }
    
    func playNext() {
        guard !MediasService.shared.playlist.isEmpty else {
            print("Playlist is empty!")
            return // Playlist boşsa işlemi durdur
        }
        
        let nextIndex = (currentIndex + 1) % MediasService.shared.playlist.count
        currentIndex = nextIndex
        
        let media = MediasService.shared.playlist[nextIndex]
        playAudio(for: media, at: IndexPath(item: nextIndex, section: 0))
    }

    func playPrevious() {
        guard !MediasService.shared.playlist.isEmpty else {
            print("Playlist is empty!")
            return // Playlist boşsa işlemi durdur
        }
        
        let previousIndex = (currentIndex - 1 + MediasService.shared.playlist.count) % MediasService.shared.playlist.count
        currentIndex = previousIndex
        let media = MediasService.shared.playlist[previousIndex]
        
        playAudio(for: media, at: IndexPath(item: previousIndex, section: 0))
    }
    
    func formattedTime(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}


    
