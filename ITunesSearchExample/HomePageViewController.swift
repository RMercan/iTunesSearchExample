//
//  HomePageViewController.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 3.03.2024.
//

import UIKit
import Kingfisher
import AVFoundation

class HomepageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, AVAudioPlayerDelegate, AudioPlayerServiceDelegate {
    
    lazy var homepageView: HomepageView = {
        let view = HomepageView(frame: self.view.frame)
        return view
    }()
    
    var selectedCategory: String = ""
    var searchBarSearchText: String = ""
    var filteredMedia: [Media] = []
    var allMedia: [Media] = []
    let mediasService = MediasService()
    let favoritesManager = FavoritesManager()
    let audioPlayerService = AudioPlayerService()
    let bottomSheetView = BottomSheetManager.shared.bottomSheetView
    var selectedIndexForPlay: Int = -1
    var selectedScopeForScopeBar: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homepageView.frame = self.view.frame
        self.view.addSubview(homepageView)
        
        homepageView.collectionView.delegate = self
        homepageView.collectionView.dataSource = self
        homepageView.navigationBarItems.searchBar.delegate = self
        audioPlayerService.audioPlayer?.delegate = self
        
        filteredMedia = allMedia
        loadFavoritesFromUserDefaults()
        
        BottomSheetManager.shared.addBottomSheetViewToWindow()
        
        audioPlayerService.delegate = self
        setupTargets()
    }
      
    func loadFavoritesFromUserDefaults() {
        let defaults = UserDefaults.standard

        if let data = defaults.data(forKey: "favoriteMedia") {
            do {
                let decoder = JSONDecoder()
                let favorites = try decoder.decode([FavoriteMedia].self, from: data)
                favoritesManager.favoriteMedia = favorites
            } catch {
                print("Error decoding favorite media: \(error.localizedDescription)")
            }
        }
    }
    
    func setupTargets() {
        bottomSheetView.fullScreenPlayerView.fullScreenPlayButton.addTarget(self, action: #selector(didTapPlayButtonForMiniAndFullScreenPlayer), for: .touchUpInside)
        bottomSheetView.miniPlayerView.miniPlayButton.addTarget(self, action: #selector(didTapPlayButtonForMiniAndFullScreenPlayer), for: .touchUpInside)
        bottomSheetView.fullScreenPlayerView.previousButton.addTarget(self, action: #selector(didTapPreviousButton), for: .touchUpInside)
        bottomSheetView.fullScreenPlayerView.nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        // Progress slider değeri değiştiğinde
        bottomSheetView.fullScreenPlayerView.progressSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)), for: .valueChanged)
    }
    
//MARK: CollectionView Functions ------------------
    
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("filteredMedia.count: ", filteredMedia.count)
        return filteredMedia.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! iTunesCollectionViewCell
        let media = filteredMedia[indexPath.item]
        
        let url = URL(string: media.artworkUrl60)
        cell.itemImageView.kf.setImage(with: url)
        cell.itemTitleLabel.text = media.artistName
        
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(didTapPlayButtonForCells), for: .touchUpInside)
        
        cell.favoriteButton.tag = indexPath.item
        cell.favoriteButton.addTarget(self, action: #selector(didTapFavoriteButton), for: .touchUpInside)
        
        cell.configure(index: indexPath.row, selectedIndex: selectedIndexForPlay, media: media)
        
        audioPlayerService.currentIndex = selectedIndexForPlay
           
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? iTunesCollectionViewCell else { return }
        cell.playButton.isSelected = indexPath.row == selectedIndexForPlay ? true : false

        setupInitialFavoriteButtonAppearance()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Seçilen hücrenin indeksini kullan
        let selectedItem = filteredMedia[indexPath.item]

        setupInitialFavoriteButtonAppearance()
        
        print("Selected item: \(selectedItem)")
    }
    
    
    
//MARK: SearchBar Settings ---------------
        
    func searchBar( _ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Search Bar Text Did Change - \(searchText)")
        
        searchBarSearchText = searchText
        filteredMedia = searchText.isEmpty ? allMedia : allMedia.filter {
            $0.artistName.lowercased().contains(searchText.lowercased())
        }
        filteredMedia.sort { (media1, media2) -> Bool in
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

//        print("Search Text: \(searchText)")
//        print("All Media: \(allMedia)")
//        print("Filtered Media: \(filteredMedia)")
        self.homepageView.collectionView.reloadData()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        // Yeni kategoriye göre API çağrısını gerçekleştir
        selectedScopeForScopeBar = selectedScope
        guard let categoryTitle = searchBar.scopeButtonTitles?[selectedScopeForScopeBar] else { return }
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
        // Koleksiyon görünümündeki eski verileri temizle
        allMedia.removeAll()
        filteredMedia.removeAll()
        audioPlayerService.playlist.removeAll()
        
        let searchCategoryText = selectedCategory
        mediasService.fetch(urlParameters: ["media": selectedCategory, "term": searchCategoryText, "limit": "100"]) { [self] result in
            switch result {
            case .success(let mediaArray):
                //print("\(self.selectedCategory) Data: \(mediaArray)")
                self.allMedia = mediaArray
                audioPlayerService.playlist = mediaArray
                self.filteredMedia = mediaArray // Tüm medya listesini filtrelenmiş listeye ata
                filteredMedia = searchBarSearchText.isEmpty ? allMedia : self.allMedia.filter {
                    $0.artistName.lowercased().contains(searchBarSearchText.lowercased())
                }
                self.filteredMedia.sort { (media1, media2) -> Bool in
                    let title1 = media1.artistName.lowercased()
                    let title2 = media2.artistName.lowercased()
                    
                    if title1.hasPrefix(searchBarSearchText.lowercased()) && !title2.hasPrefix(searchBarSearchText.lowercased()) {
                        return true
                    } else if !title1.hasPrefix(searchBarSearchText.lowercased()) && title2.hasPrefix(searchBarSearchText.lowercased()) {
                        return false
                    } else {
                        return title1.localizedCaseInsensitiveCompare(title2) == .orderedAscending
                    }
                }
                // Favori durumlarını güncelle
                setupInitialFavoriteButtonAppearance()
                
                DispatchQueue.main.async {
                    self.homepageView.collectionView.reloadData() // Koleksiyon görünümünü güncelle
                }
            case .failure(let error):
                print("Error fetching \(self.selectedCategory) data: \(error.localizedDescription)")
            }
        }
    }
    
//MARK: PLAY AUDIO ----------------------
    
    func audioEvent(for media: Media, at indexPath: IndexPath) {
        if let player = audioPlayerService.audioPlayer, player.isPlaying {
            stopAudioForAll()
        }
        
        audioPlayerService.playAudio(for: media, at: indexPath)
        //Şimdiki indexPath referansına güncelle
//        audioPlayerService.currentPlayingIndexPath = indexPath
        
        BottomSheetManager.shared.showBottomSheetView()
        BottomSheetManager.shared.setupPanGesture()
        BottomSheetManager.shared.setPlayButtonsActive()
    }
    
    func stopAudioForAll() {
        //player stop
        audioPlayerService.stopAudio()
        
        BottomSheetManager.shared.setPlayButtonsPassive()
        // Tüm koleksiyonu döngüye alarak hücreleri kontrol et
        for cell in homepageView.collectionView.visibleCells {
            guard let cell = cell as? iTunesCollectionViewCell else { return }
            cell.playButton.isSelected = false
        }
        
        // Önceki indexPath referansını temizle
//        audioPlayerService.currentPlayingIndexPath = nil
    }
    
    func updateCellsPlayerButtonsAppearance() {
        DispatchQueue.main.async {
            guard let currentMedia = self.audioPlayerService.currentPlayingMedia else { return }
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
    
    // AudioPlayerServiceDelegate
    func didUpdateProgress(_ progress: Float) {
        if !audioPlayerService.isAudioPlaying() {
            // Eğer şarkı ilk defa çalınıyorsa ilerleme çubuğunu sıfırla
            bottomSheetView.fullScreenPlayerView.progressSlider.setValue(0.0, animated: false)
        } else {
            // Şarkı çalıyorsa ilerleme durumunu güncelle
            bottomSheetView.fullScreenPlayerView.progressSlider.setValue(progress, animated: true)
        }
        updateCellsPlayerButtonsAppearance()
    }
    
    // Selector fonksiyonu
    @objc func progressSliderValueChanged(_ sender: UISlider) {
        
        // Yeni ilerleme süresini hesapla
        let newPosition = Double(sender.value) * audioPlayerService.totalTime
        
        // AVAudioPlayer'ın currentTime özelliğini ayarla
        audioPlayerService.audioPlayer?.currentTime = newPosition
    }

    // Zamanı biçimlendirme fonksiyonu
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func finishPlaying() {
        // Medya çalma tamamlandığında yapılacak işlemler
        BottomSheetManager.shared.setPlayButtonsPassive()
        // Tüm koleksiyonu döngüye alarak hücreleri kontrol et
        for cell in self.homepageView.collectionView.visibleCells {
            guard let cell = cell as? iTunesCollectionViewCell else { return }
            cell.playButton.isSelected = false
        }
        // Önceki indexPath referansını temizle
//        audioPlayerService.currentPlayingIndexPath = nil
    }
    
    @objc func didTapPlayButtonForCells(_ sender: UIButton) {
        guard !sender.isSelected else {
            stopAudioForAll()
            return
        }
        let rowIndex = sender.tag
        audioPlayerService.currentIndex = rowIndex
        let indexPath = IndexPath(row: rowIndex, section: 0)
        
        guard let cell = homepageView.collectionView.cellForItem(at: indexPath) as? iTunesCollectionViewCell else { return }
        
        let media = filteredMedia[indexPath.item]
        BottomSheetManager.shared.setPlayButtonsActive()
        cell.playButton.isSelected = true
        
//        audioEvent(for: media, at: indexPath, in: cell)
        audioEvent(for: media, at: indexPath)
    }
    
    @objc func didTapPlayButtonForMiniAndFullScreenPlayer( sender: UIButton) {
        guard !sender.isSelected else {
            stopAudioForAll()
            return
        }
        let index = sender.tag
        audioPlayerService.currentIndex = index
        let indexPath = IndexPath(item: index, section: 0)

        // currentPlayingMedia değişkeninden medya bilgisini al
        guard let media = audioPlayerService.currentPlayingMedia else { return }
        BottomSheetManager.shared.setPlayButtonsActive()
        
        audioEvent(for: media, at: indexPath)
    }
    
    @objc func didTapPreviousButton() {
        audioPlayerService.playPrevious()
    }
    
    @objc func didTapNextButton() {
        audioPlayerService.playNext()
    }
    
    
    
//MARK: - Favorite Activity ---------------------
    
    // Favorileri userDefaultsa kaydetme işlemi
    func saveFavoritesToUserDefaults() {
        let defaults = UserDefaults.standard
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(favoritesManager.favoriteMedia)
            defaults.set(data, forKey: "favoriteMedia")
        } catch {
            print("Error encoding favorite media: \(error.localizedDescription)")
        }
    }
    
    // Favoriler listesindeki her bir medyanın eklenme tarihine bakarak 24 saat geçmiş olanları kaldırma işlemi
    func removeExpiredFavorites() {
        let currentDate = Date()
        favoritesManager.favoriteMedia = favoritesManager.favoriteMedia.filter { currentDate.timeIntervalSince($0.addedDate) <= 24 * 3600 }
        saveFavoritesToUserDefaults()
    }
    
    // Liste yüklendiğinde favori butonlarının başlangıç görünümünü ayarlama işlemi
    func setupInitialFavoriteButtonAppearance() {
        DispatchQueue.main.async {
            self.removeExpiredFavorites()
            for (index, media) in self.filteredMedia.enumerated() {
                let indexPath = IndexPath(row: index, section: 0)
                guard let cell = self.homepageView.collectionView.cellForItem(at: indexPath) as? iTunesCollectionViewCell else { continue }
                if self.favoritesManager.favoriteMedia.contains(where: { $0.media.previewUrl == media.previewUrl }) {
                    // Medya favorilerde, dolu yıldız görünümü
                    cell.favoriteButton.isSelected = true
                } else {
                    // Medya favorilerde değil, içi boş yıldız görünümü
                    cell.favoriteButton.isSelected = false
                }
            }
        }
    }
    
    @objc func didTapFavoriteButton(_ sender: UIButton) {
        let rowIndex = sender.tag
        let indexPath = IndexPath(row: rowIndex, section: 0)
        
        // IndexPath geçerli mi kontrol et
        guard indexPath.row < filteredMedia.count else {
            print("Invalid indexPath")
            return
        }
        
        // indexPath'e göre hücreyi al
        guard let cell = homepageView.collectionView.cellForItem(at: indexPath) as? iTunesCollectionViewCell else { return }
        let media = filteredMedia[indexPath.row]
        
        if let favoriteIndex = favoritesManager.favoriteMedia.firstIndex(where: { $0.media.previewUrl == media.previewUrl }) {
            // Medya zaten favorilerde, favorilerden çıkar
            favoritesManager.favoriteMedia.remove(at: favoriteIndex)
            saveFavoritesToUserDefaults()
            // Buton görünümünü güncelle: İçi boş yıldız
            cell.favoriteButton.isSelected = false
        } else {
            // Medya favorilerde değil, favorilere ekle
            let favoriteMedia = FavoriteMedia(media: media, addedDate: Date())
            favoritesManager.favoriteMedia.append(favoriteMedia)
            saveFavoritesToUserDefaults()
            // Buton görünümünü güncelle: Dolu yıldız
            cell.favoriteButton.isSelected = true
        }
    }
   
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
