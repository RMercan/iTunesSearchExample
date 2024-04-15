//
//  FavoritesManager.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 11.03.2024.
//

import Foundation
import UIKit


final class FavoritesManager {
        
    static let shared = FavoritesManager()
    
    // Favorileri userDefaultsa kaydetme işlemi
    func saveFavoritesToUserDefaults() {
        let defaults = UserDefaults.standard
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(FavoritesService.shared.favoriteMedia)
            defaults.set(data, forKey: "favoriteMedia")
        } catch {
            print("Error encoding favorite media: \(error.localizedDescription)")
        }
    }
    
    // Favoriler listesindeki her bir medyanın eklenme tarihine bakarak 24 saat geçmiş olanları kaldırma işlemi
    func removeExpiredFavorites() {
        let currentDate = Date()
        FavoritesService.shared.favoriteMedia = FavoritesService.shared.favoriteMedia.filter { currentDate.timeIntervalSince($0.addedDate) <= 24 * 3600 }
        saveFavoritesToUserDefaults()
    }
    
}

