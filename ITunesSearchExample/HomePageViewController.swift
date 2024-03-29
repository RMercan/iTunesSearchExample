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
    
    // Kategorilere göre favori durumları saklamak için dictionary
    var favoriteStatusByCategory: [String: [IndexPath: Bool]] = [:]
    var selectedCategory: String = ""
    var searchBarSearchText: String = ""
    var filteredMedia: [Media] = []
    var allMedia: [Media] = []
    let mediasService = MediasService()
    let favoritesManager = FavoritesManager()
    let audioPlayerService = AudioPlayerService()
//    let miniPlayerView = MiniPlayerView()
//    let fullScreenPlayerView = FullScreenPlayerView()
    let bottomSheetView = BottomSheetManager.shared.bottomSheetView
    var selectedIndexForPlay: Int = -1
    var selectedIndexForFavorite: Int = -1
    var selectedScopeForScopeBar: Int = -1
//    var currentMedia: Media
    
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
        bottomSheetView.fullScreenPlayerView.fullScreenPlayButton.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
        bottomSheetView.miniPlayerView.miniPlayButton.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
        bottomSheetView.fullScreenPlayerView.previousButton.addTarget(self, action: #selector(didTapPreviousButton), for: .touchUpInside)
        bottomSheetView.fullScreenPlayerView.nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
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
        cell.playButton.addTarget(self, action: #selector(didTapPlayButton), for: .touchUpInside)
//        bottomSheetView.miniPlayerView.miniPlayButton = cell.playButton  //YANLIŞ KULLANIM
//        bottomSheetView.fullScreenPlayerView.fullScreenPlayButton = cell.playButton    //YANLIŞ KULLANIM
        
        cell.favoriteButton.tag = indexPath.item
        cell.favoriteButton.addTarget(self, action: #selector(didTapFavoriteButton), for: .touchUpInside)
        
        cell.configure(index: indexPath.row, selectedIndex: selectedIndexForPlay, media: media)
        
        audioPlayerService.currentIndex = selectedIndexForPlay
           
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? iTunesCollectionViewCell else { return }
        cell.playButton.isSelected = indexPath.row == selectedIndexForPlay ? true : false

        //cell.favoriteButton.isSelected = cell.isFavorite
        setupInitialFavoriteButtonAppearance()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Seçilen hücrenin indeksini kullan
        let selectedItem = filteredMedia[indexPath.item]
//        let currentMedia = filteredMedia[indexPath.item]
        setupInitialFavoriteButtonAppearance()
        
        print("Selected item: \(selectedItem)")
    }
    
    
    
//MARK: SearchBar Settings ---------------
        
    func searchBar( _ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Search Bar Text Did Change - \(searchText)")
//        stopAudioForAll()
//        selectedIndexForPlay = -1
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
//        case "podcast":
//            whenSelectCategory()
        case "music":
            whenSelectCategory()
        default:
            break
        }
    }
    
    func whenSelectCategory() {
//        selectedIndexForPlay = -1
//        stopAudioForAll()
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
                
//                updateCellsPlayerButtonsAppearance()
                DispatchQueue.main.async {
                    self.homepageView.collectionView.reloadData() // Koleksiyon görünümünü güncelle
                }
            case .failure(let error):
                print("Error fetching \(self.selectedCategory) data: \(error.localizedDescription)")
            }
        }
//        presentcustomModalViewController()
//        bottomSheetView.contentStackView.isHidden = false
    }
    
//MARK: PLAY AUDIO ----------------------
    
//    func audioEvent(for media: Media, at indexPath: IndexPath, in cell: iTunesCollectionViewCell) {
//        if let player = audioPlayerService.audioPlayer, player.isPlaying {
//            
//            stopAudioForAll()
//            //updateCellsPlayerButtonsAppearance()
//        }
//        
//        audioPlayerService.playAudio(for: media, at: indexPath)
////        audioPlayerService.playMedia(at: audioPlayerService.currentIndex)
//        
//        // Şimdiki indexPath referansına güncelle
//        audioPlayerService.currentPlayingIndexPath = indexPath
////        audioPlayerService.currentIndex =
////        audioPlayerService.playlist =
//        //        DispatchQueue.main.async {
//        //            self.presentcustomModalViewController()
//        BottomSheetManager.shared.showBottomSheetView()
//        BottomSheetManager.shared.setupPanGesture()
//        cell.playButton.isSelected = true
//        BottomSheetManager.shared.setPlayButtonsActive()
//        
////        BottomSheetManager.shared.updateContent(url: media.artworkUrl60)
//        
////        miniPlayerView.update(with: media)
////        fullScreenPlayerView.update(with: media)
//        //        }
//    }
    
    func audioEvent(for media: Media, at indexPath: IndexPath) {
        if let player = audioPlayerService.audioPlayer, player.isPlaying {
            stopAudioForAll()
        }
        
        audioPlayerService.playAudio(for: media, at: indexPath)
        //Şimdiki indexPath referansına güncelle
        audioPlayerService.currentPlayingIndexPath = indexPath
        
        BottomSheetManager.shared.showBottomSheetView()
        BottomSheetManager.shared.setupPanGesture()
//        cell.playButton.isSelected = true
        BottomSheetManager.shared.setPlayButtonsActive()
    }
    
    func stopAudioForAll() {
        //player.stop()
        BottomSheetManager.shared.setPlayButtonsPassive()
        audioPlayerService.stopAudio()
        
        // Tüm koleksiyonu döngüye alarak hücreleri kontrol et
        for cell in homepageView.collectionView.visibleCells {
            guard let cell = cell as? iTunesCollectionViewCell else { return }
            cell.playButton.isSelected = false
        }
        
        // Önceki indexPath referansını temizle
        audioPlayerService.currentPlayingIndexPath = nil
    }
    
    func updateCellsPlayerButtonsAppearance() {
        DispatchQueue.main.async {
            guard let currentMedia = self.audioPlayerService.currentMedia else { return }
            let currentMediaCollectionId = currentMedia.collectionId
            
            for cell in self.homepageView.collectionView.visibleCells {
                guard let cell = cell as? iTunesCollectionViewCell else { continue }
                
                if let cellMedia = cell.media, cellMedia.collectionId == currentMediaCollectionId {
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
            bottomSheetView.fullScreenPlayerView.progressView.setProgress(0.0, animated: false)
        } else {
            // Şarkı çalıyorsa ilerleme durumunu güncelle
            bottomSheetView.fullScreenPlayerView.progressView.setProgress(progress, animated: true)
        }
        updateCellsPlayerButtonsAppearance()
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
        audioPlayerService.currentPlayingIndexPath = nil
    }
    
//    func audioPlayerDidFinishPlaying() {
//        if let player = audioPlayerService.audioPlayer, player.isPlaying {
//            // Çalma tamamlanmadı
//            // Tüm koleksiyonu döngüye alarak hücreleri kontrol et
//            for cell in homepageView.collectionView.visibleCells {
//                guard let cell = cell as? iTunesCollectionViewCell else { return }
//                cell.playButton.isSelected = true
//            }
//            BottomSheetManager.shared.setPlayButtonsActive()
//        } else {
//            // Çalma tamamlandı
//            // Tüm koleksiyonu döngüye alarak hücreleri kontrol et
//            for cell in homepageView.collectionView.visibleCells {
//                guard let cell = cell as? iTunesCollectionViewCell else { return }
//                cell.playButton.isSelected = false
//            }
//            BottomSheetManager.shared.setPlayButtonsPassive()
//        }
//    }
    
    @objc func didTapPlayButton(_ sender: UIButton) {
        guard !sender.isSelected else {
//            selectedIndexForPlay = -1
            stopAudioForAll()
            return
        }
//            updateCellsPlayerButtonsAppearance()
        let rowIndex = sender.tag
//        selectedIndexForPlay = rowIndex
        audioPlayerService.currentIndex = rowIndex
        let indexPath = IndexPath(row: rowIndex, section: 0)
        guard let cell = homepageView.collectionView.cellForItem(at: indexPath) as? iTunesCollectionViewCell else { return }
        let media = filteredMedia[indexPath.item]
//        let media = audioPlayerService.playlist[indexPath.item]
        BottomSheetManager.shared.setPlayButtonsActive()
        cell.playButton.isSelected = true
        
//        audioEvent(for: media, at: indexPath, in: cell)
        audioEvent(for: media, at: indexPath)
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
                if self.favoritesManager.favoriteMedia.contains(where: { $0.media.collectionId == media.collectionId }) {
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
        
        if let favoriteIndex = favoritesManager.favoriteMedia.firstIndex(where: { $0.media.collectionId == media.collectionId }) {
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
    
    
    //MARK: - Bottom Sheet Activity---------------
    
//    func presentcustomModalViewController() {
//        let customModalViewController = CustomModalViewController()
////        customModalViewController.modalPresentationStyle = .overCurrentContext
//        customModalViewController.modalPresentationStyle = .custom
//        // Keep animated value as false
//        // Custom Modal presentation animation will be handled in view controller itself
//        self.present(customModalViewController, animated: false)
        
        // container view oluşturulması ve view controller'ın eklenmesi
//        let customModalViewController = CustomModalViewController()
//        addChild(customModalViewController)
//        homepageView.collectionView.addSubview(customModalViewController.view)
//        customModalViewController.didMove(toParent: self)

//    }
    
    
//    func updateMiniPlayer() {
////        guard let currentMedia = audioPlayerService.playlist[safe: audioPlayerService.currentIndex] else {
//        guard let currentMedia = audioPlayerService.currentMedia else {
//            // Eğer şu anda çalınan bir medya yoksa, mini player'ı temizle
////            miniPlayerView.miniItemImageView.image = nil
////            miniPlayerView.miniItemTitleLabel.text = nil
////            miniPlayerView.miniPlayButton.isSelected = false
//            return
//        }
//        miniPlayerView.update(with: currentMedia)
//    }
//    
//    func updateFullScreenPlayer() {
////        guard let currentMedia = audioPlayerService.playlist[safe: audioPlayerService.currentIndex] else {
//        guard let currentMedia = audioPlayerService.currentMedia else {
//            // Eğer şu anda çalınan bir medya yoksa, full screen player'ı temizle
////            fullScreenPlayerView.fullScreenItemImageView.image = nil
////            fullScreenPlayerView.fullScreenItemTitleLabel.text = nil
////            fullScreenPlayerView.playButton.isSelected = false
//            return
//        }
//        fullScreenPlayerView.update(with: currentMedia)
//    }
    
    
    @objc func didTapPreviousButton() {
        audioPlayerService.playPrevious()
    }
    
    @objc func didTapNextButton() {
        audioPlayerService.playNext()
    }
    
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
