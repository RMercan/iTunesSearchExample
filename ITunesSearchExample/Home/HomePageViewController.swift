//
//  HomePageViewController.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 3.03.2024.
//

import UIKit
import Kingfisher
import AVFoundation


final class HomepageViewController: UIViewController {
    
    lazy var homepageView: HomepageView = {
        let view = HomepageView(frame: self.view.frame)
        return view
    }()
    
    private var selectedCategory: String = ""
    private var searchBarSearchText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homepageView.frame = self.view.frame
        self.view.addSubview(homepageView)

        setupDelegates()
        loadFavoritesFromUserDefaults()
        BottomSheetManager.shared.addBottomSheetViewToWindow()
        setupTargets()
    }
    
}


//MARK: Setups -----------
extension HomepageViewController {
    func setupTargets() {
        BottomSheetManager.shared.bottomSheetView.fullScreenPlayerView.fullScreenPlayButton.addTarget(self, action: #selector(didTapPlayButtonForMiniAndFullScreenPlayer), for: .touchUpInside)
        BottomSheetManager.shared.bottomSheetView.miniPlayerView.miniPlayButton.addTarget(self, action: #selector(didTapPlayButtonForMiniAndFullScreenPlayer), for: .touchUpInside)
        BottomSheetManager.shared.bottomSheetView.fullScreenPlayerView.previousButton.addTarget(self, action: #selector(didTapPreviousButton), for: .touchUpInside)
        BottomSheetManager.shared.bottomSheetView.fullScreenPlayerView.nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        // Progress slider değeri değiştiğinde
        BottomSheetManager.shared.bottomSheetView.fullScreenPlayerView.progressSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: .valueChanged)
    }
    
    func setupDelegates() {
        homepageView.collectionView.delegate = self
        homepageView.collectionView.dataSource = self
        homepageView.navigationBarItems.searchBar.delegate = self
        AudioPlayerService.shared.audioPlayer?.delegate = self
        AudioPlayerService.shared.delegate = self
    }
}


//MARK: Audio Player - AVAudioPlayerDelegate, AudioPlayerServiceDelegate ----------------------
extension HomepageViewController: AVAudioPlayerDelegate, AudioPlayerServiceDelegate {
    
    func updateCellsPlayerButtonsAppearance() {
        DispatchQueue.main.async {
            guard let currentMedia = AudioPlayerService.shared.currentPlayingMedia else { return }
            let currentMediaPreviewUrl = currentMedia.previewUrl
            
            for cell in self.homepageView.collectionView.visibleCells {
                guard let cell = cell as? iTunesCollectionViewCell else { continue }
                
                if let cellMedia = cell.media, cellMedia.previewUrl == currentMediaPreviewUrl {
                    cell.playButton.isSelected = true
                } else {
                    cell.playButton.isSelected = false
                }
            }
        }
    }
    
    func didUpdateProgress(_ progress: Float) {
        BottomSheetManager.shared.bottomSheetView.fullScreenPlayerView.progressSlider.setValue(progress, animated: true)
        BottomSheetManager.shared.updateTimeLabels()
        updateCellsPlayerButtonsAppearance()
    }
    
    func finishPlaying() {
        // Medya çalma tamamlandığında yapılacak işlemler
        BottomSheetManager.shared.setPlayButtonsPassive()
        AudioPlayerManager.shared.selectedIndexForPlay = -1
        self.homepageView.collectionView.reloadData()
    }
    
    func didPlayedMedia(media: Media) {
        AudioPlayerManager.shared.selectedIndexForPlay = MediasService.shared.filteredMedia.firstIndex(where: { $0.previewUrl == media.previewUrl }) ?? -1
        print("Selected Index: \(AudioPlayerManager.shared.selectedIndexForPlay)")
        self.homepageView.collectionView.reloadData()
    }
    
    @objc func progressSliderValueChanged(_ sender: UISlider) {
        // Yeni ilerleme süresini hesapla
        let newPosition = Double(sender.value) * AudioPlayerService.shared.totalTime
        
        // AVAudioPlayer'ın currentTime özelliğini ayarla
        AudioPlayerService.shared.audioPlayer?.currentTime = newPosition
    }

    @objc func didTapPlayButtonForCells(_ sender: UIButton) {
        guard !sender.isSelected else {
            AudioPlayerManager.shared.stopAudioForAll()
            return
        }
        let rowIndex = sender.tag
        let indexPath = IndexPath(row: rowIndex, section: 0)
        
        guard let cell = homepageView.collectionView.cellForItem(at: indexPath) as? iTunesCollectionViewCell else { return }
        
        let media = MediasService.shared.filteredMedia[indexPath.item]
        BottomSheetManager.shared.setPlayButtonsActive()
        
        AudioPlayerManager.shared.audioEvent(for: media, at: indexPath)
    }
    
    @objc func didTapPlayButtonForMiniAndFullScreenPlayer(_ sender: UIButton) {
        guard !sender.isSelected else {
            AudioPlayerManager.shared.stopAudioForAll()
            self.homepageView.collectionView.reloadData()
            return
        }
        let index = sender.tag
        let indexPath = IndexPath(item: index, section: 0)
        
        // currentPlayingMedia değişkeninden medya bilgisini al
        guard let media = AudioPlayerService.shared.currentPlayingMedia else { return }
        BottomSheetManager.shared.setPlayButtonsActive()

        AudioPlayerManager.shared.audioEvent(for: media, at: indexPath)
    }
    
    @objc func didTapPreviousButton() {
        AudioPlayerService.shared.playPrevious()
        BottomSheetManager.shared.setPlayButtonsActive()
    }
    
    @objc func didTapNextButton() {
        AudioPlayerService.shared.playNext()
        BottomSheetManager.shared.setPlayButtonsActive()
    }
    
}


//MARK: - Favorite Activity ---------------------
extension HomepageViewController {
    
    // Liste yüklendiğinde favori butonlarının başlangıç görünümünü ayarlama işlemi
    func setupInitialFavoriteButtonAppearance() {
        DispatchQueue.main.async {
            FavoritesManager.shared.removeExpiredFavorites()
            for (index, media) in MediasService.shared.filteredMedia.enumerated() {
                let indexPath = IndexPath(row: index, section: 0)
                guard let cell = self.homepageView.collectionView.cellForItem(at: indexPath) as? iTunesCollectionViewCell else { continue }
                if FavoritesService.shared.favoriteMedia.contains(where: { $0.media.previewUrl == media.previewUrl }) {
                    // Medya favorilerde, dolu yıldız görünümü
                    cell.favoriteButton.isSelected = true
                } else {
                    // Medya favorilerde değil, içi boş yıldız görünümü
                    cell.favoriteButton.isSelected = false
                }
            }
        }
    }
    
    // UserDefaults'tan yükle
    func loadFavoritesFromUserDefaults() {
        let defaults = UserDefaults.standard
        
        if let data = defaults.data(forKey: "favoriteMedia") {
            do {
                let decoder = JSONDecoder()
                let favorites = try decoder.decode([FavoriteMedia].self, from: data)
                FavoritesService.shared.favoriteMedia = favorites
            } catch {
                print("Error decoding favorite media: \(error.localizedDescription)")
            }
        }
    }
    
    @objc func didTapFavoriteButton(_ sender: UIButton) {
        let rowIndex = sender.tag
        let indexPath = IndexPath(row: rowIndex, section: 0)
        
        // IndexPath geçerli mi kontrol et
        guard indexPath.row < MediasService.shared.filteredMedia.count else {
            print("Invalid indexPath")
            return
        }
        
        // indexPath'e göre hücreyi al
        guard let cell = homepageView.collectionView.cellForItem(at: indexPath) as? iTunesCollectionViewCell else { return }
        let media = MediasService.shared.filteredMedia[indexPath.row]
        
        if let favoriteIndex = FavoritesService.shared.favoriteMedia.firstIndex(where: { $0.media.previewUrl == media.previewUrl }) {
            // Medya zaten favorilerde, favorilerden çıkar
            FavoritesService.shared.favoriteMedia.remove(at: favoriteIndex)
            FavoritesManager.shared.saveFavoritesToUserDefaults()
            // Buton görünümünü güncelle: İçi boş yıldız
            cell.favoriteButton.isSelected = false
        } else {
            // Medya favorilerde değil, favorilere ekle
            let favoriteMedia = FavoriteMedia(media: media, addedDate: Date())
            FavoritesService.shared.favoriteMedia.append(favoriteMedia)
            FavoritesManager.shared.saveFavoritesToUserDefaults()
            // Buton görünümünü güncelle: Dolu yıldız
            cell.favoriteButton.isSelected = true
        }
    }
}


//MARK: Collection Extension --------------
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


//MARK: CollectionView Functions - UICollectionViewDataSource, UICollectionViewDelegate ------------------
extension HomepageViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("filteredMedia.count: ", MediasService.shared.filteredMedia.count)
        return MediasService.shared.filteredMedia.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! iTunesCollectionViewCell
        let media = MediasService.shared.filteredMedia[indexPath.item]
        
        let url = URL(string: media.artworkUrl60)
        cell.itemImageView.kf.setImage(with: url)
        cell.itemTitleLabel.text = media.artistName
        
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(didTapPlayButtonForCells), for: .touchUpInside)
        
        cell.favoriteButton.tag = indexPath.item
        cell.favoriteButton.addTarget(self, action: #selector(didTapFavoriteButton), for: .touchUpInside)
        
        cell.configure(index: indexPath.row, selectedIndex: AudioPlayerManager.shared.selectedIndexForPlay, media: media)
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? iTunesCollectionViewCell else { return }
        cell.playButton.isSelected = indexPath.row == AudioPlayerManager.shared.selectedIndexForPlay ? true : false
        
        setupInitialFavoriteButtonAppearance()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Seçilen hücrenin indeksini kullan
        let selectedItem = MediasService.shared.filteredMedia[indexPath.item]

        setupInitialFavoriteButtonAppearance()
        
        print("Selected item: \(selectedItem)")
    }
    
}


//MARK: SearchBar Settings - UISearchBarDelegate ---------------
extension HomepageViewController: UISearchBarDelegate {
        
    func searchBar( _ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Search Bar Text Did Change - \(searchText)")
        
        searchBarSearchText = searchText
        MediasService.shared.filteredMedia = searchText.isEmpty ? MediasService.shared.allMedia : MediasService.shared.allMedia.filter {
            $0.artistName.lowercased().contains(searchText.lowercased())
        }
        MediasService.shared.filteredMedia.sort { (media1, media2) -> Bool in
            let title1 = media1.artistName.lowercased()
            let title2 = media2.artistName.lowercased()
            
            if title1.hasPrefix(searchText.lowercased()) && !title2.hasPrefix(searchText.lowercased()) {
                return true
            } else if !title1.hasPrefix(searchText.lowercased()) && title2.hasPrefix(searchText.lowercased()) {
                return false
            } else {
                return title1.localizedCaseInsensitiveCompare(title2) == .orderedAscending
            }
        }
        updateCellsPlayerButtonsAppearance()

        print("Playlist: \(MediasService.shared.playlist)")
        
        self.homepageView.collectionView.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        // Yeni kategoriye göre API çağrısını gerçekleştir
        AudioPlayerService.shared.selectedScopeIndexForScopeBar = selectedScope
        print("Selected category scope index: \(selectedScope)")
        guard let categoryTitle = searchBar.scopeButtonTitles?[AudioPlayerService.shared.selectedScopeIndexForScopeBar] else { return }
        print("Selected category: \(categoryTitle)")
        homepageView.beginningLabel.isHidden = true
        
        selectedCategory = categoryTitle

        switch categoryTitle {
        case "audiobook":
            whenSelectCategory()
        case "music":
            whenSelectCategory()
        default:
            break
        }
    }
    
    func whenSelectCategory() {
        updateCellsPlayerButtonsAppearance()
        // Kategori değiştiğinde favori durumlarını güncelle
        setupInitialFavoriteButtonAppearance()
        // Collection görünümündeki eski verileri temizle
        MediasService.shared.allMedia.removeAll()
        MediasService.shared.filteredMedia.removeAll()
        MediasService.shared.playlist.removeAll()
        
        let searchCategoryText = selectedCategory
        MediasService.shared.fetch(urlParameters: ["media": selectedCategory, "term": searchCategoryText, "limit": "100"]) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let mediaArray):
                MediasService.shared.allMedia = mediaArray
                
                MediasService.shared.filteredMedia = mediaArray // Tüm medya listesini filtrelenmiş listeye ata
                MediasService.shared.filteredMedia = searchBarSearchText.isEmpty ? MediasService.shared.allMedia : MediasService.shared.allMedia.filter {
                    $0.artistName.lowercased().contains(self.searchBarSearchText.lowercased())
                }
                
                MediasService.shared.filteredMedia.sort { (media1, media2) -> Bool in
                    let title1 = media1.artistName.lowercased()
                    let title2 = media2.artistName.lowercased()
                    
                    if title1.hasPrefix(self.searchBarSearchText.lowercased()) && !title2.hasPrefix(self.searchBarSearchText.lowercased()) {
                        return true
                    } else if !title1.hasPrefix(self.searchBarSearchText.lowercased()) && title2.hasPrefix(self.searchBarSearchText.lowercased()) {
                        return false
                    } else {
                        return title1.localizedCaseInsensitiveCompare(title2) == .orderedAscending
                    }
                }
                MediasService.shared.playlist = MediasService.shared.filteredMedia
                // Favori durumlarını güncelle
                setupInitialFavoriteButtonAppearance()
                
                DispatchQueue.main.async {
                    self.homepageView.collectionView.reloadData() // Collection görünümünü güncelle
                }
            case .failure(let error):
                print("Error fetching \(self.selectedCategory) data: \(error.localizedDescription)")
            }
        }
    }
 
}
