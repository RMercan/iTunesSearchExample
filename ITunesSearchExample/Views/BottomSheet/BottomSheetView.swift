//
//  BottomSheetView.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 15.03.2024.
//

import UIKit
import SnapKit

class BottomSheetView: UIView {
    
    var playerViewType: PlayerViewType = .mini {
        didSet {
            updatePlayerView()
        }
    }
    
//    lazy var testView: UIView = {
//       let view = UIView()
//        view.backgroundColor = .red
//        return view
//    }()
//    
//    lazy var testView2: UIView = {
//       let view = UIView()
//        view.backgroundColor = .orange
//        return view
//    }()
    
//    lazy var containerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        view.layer.cornerRadius = 16
//        view.clipsToBounds = true
//        return view
//    }()
    
    lazy var fullScreenPlayerView: FullScreenPlayerView = {
        let view = FullScreenPlayerView()
//        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
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
    
//    lazy var contentStackView: UIStackView = {
//        //        let spacer = UIView()
//        let stackView = UIStackView(arrangedSubviews: [fullScreenPlayerView, miniPlayerView])  //, spacer
//        stackView.axis = .vertical
//        stackView.spacing = 12.0
//        return stackView
//    }()
    
//    lazy var miniPlayButton: UIButton = {
//        let button = UIButton()
//        button.layer.cornerRadius = 20
//        button.setImage(UIImage(named: "playIcon"), for: .normal)
//        button.setImage(UIImage(named: "pauseIcon"), for: .selected)
//        return button
//    }()
    
    let defaultHeight: CGFloat = 75
    //    var defaultHeight: CGFloat {
    //        return playerViewType == .mini ? 75 : UIScreen.main.bounds.height - 64
    //    }
    let dismissibleHeight: CGFloat = 20
//    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    // Yeni yükseklikle güncellenmeye devam et
    //    var currentContainerHeight: CGFloat = 300
//    var currentContainerHeight: CGFloat {
//        get {
//            return containerViewHeightConstraint?.constant ?? defaultHeight
//        }
//        set {
//            containerViewHeightConstraint?.constant = newValue
//        }
//    }
    
    // Dynamic container constraint
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    let audioPlayerService = AudioPlayerService()
    let bottomSheetManager = BottomSheetManager()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupLayouts()
        updatePlayerView()
        setupPanGesture()
//        setupTapGesture()
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
//        addSubview(containerView)
//        containerView.translatesAutoresizingMaskIntoConstraints = false
        
//        containerView.addSubview(contentStackView)
//        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(fullScreenPlayerView)
        addSubview(miniPlayerView)
//        addSubview(miniPlayButton)
//        addSubview(testView)
//        addSubview(testView2)
//        
//        testView.frame.size.width = UIScreen.main.bounds.width
//        testView.frame.size.height = 200
//        testView.frame.origin.y = self.frame.origin.y
//        testView.frame.origin.x = self.frame.origin.x
//        
//        testView2.snp.makeConstraints { make in
//            make.top.equalToSuperview().inset(400)
//            make.leading.trailing.equalToSuperview()
//            make.height.equalTo(200)
//        }
    }
    
    func setupLayouts() {
        
//        miniPlayButton.snp.makeConstraints { make in
//            make.top.trailing.equalToSuperview().inset(20)
//            make.size.equalTo(40)
//        }
        
//        containerView.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview()
//            make.bottom.equalToSuperview()  //.inset(self.safeAreaBottom)
//            make.top.equalToSuperview()
////            make.height.equalTo(<#T##other: ConstraintRelatableTarget##ConstraintRelatableTarget#>)
//        }
        
        miniPlayerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(75)
        }
        
        fullScreenPlayerView.snp.makeConstraints { make in
            make.top.equalTo(miniPlayerView.snp.bottom).offset(40)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
//        contentStackView.snp.makeConstraints { make in    //superViewı containerVİew
//            make.top.equalToSuperview().inset(5)
//            make.bottom.equalToSuperview().inset(5)
//            make.leading.equalToSuperview().inset(5)
//            make.trailing.equalToSuperview().inset(5)
//        }
//        
        // Konteyneri varsayılan yüksekliğe ayarla
//        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        // bottom constant 0 yap
//        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        // Activate constraints
//        containerViewHeightConstraint?.isActive = true
//        containerViewBottomConstraint?.isActive = true
        // bottom constraint'i güncelle
//        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: defaultHeight)
        
    }
    
    func updatePlayerView() {
//        switch playerViewType {
//        case .mini:
//            miniPlayerView.isHidden = false
////            fullScreenPlayerView.isHidden = true
//        case .fullScreen:
//            miniPlayerView.isHidden = true
//            fullScreenPlayerView.isHidden = false
//        }
    }
    
    func animatePresentContainer() {
        // Animasyon bloğunda bottom constraint güncelle
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // kısıtlamayı yenilemek için çağır
            self.layoutIfNeeded()
        }
    }
    
//    func animateDismissView() {
//        // main container görünümünü bottom constraint'i güncelleyerek gizle
//        UIView.animate(withDuration: 0.3) {
//            self.containerViewBottomConstraint?.constant = self.defaultHeight
//            // Kısıtlamayı yenilemek için bunu çağır
//            self.layoutIfNeeded()
//        }
//        
//        // hide blur view
//        UIView.animate(withDuration: 0.4) {
//        }
//        completion: { _ in
//        // işlem bittiğinde animasyonsuz kapat
//        //            self.dismiss(animated: false)
//        self.removeFromSuperview()
//    }
//    }
    
    func setupPanGesture() {
        // pan gesture recognizer'ı view controller'ın görünümüne ekle (tüm ekran)
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // Hareketi hemen dinlemek için false'a değiştir
//        panGesture.delaysTouchesBegan = false
//        panGesture.delaysTouchesEnded = false
//        addGestureRecognizer(panGesture)
    }
    
//    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: self)
//        
//        // Bottom sheet view'ın boyutları içindeki hareketleri kontrol etmek için koordinatları bottom sheet view'a dönüştür
////        let translatedPoint = gesture.location(in: containerView)
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
    
    func animateContainerHeight(_ height: CGFloat) {
//        UIView.animate(withDuration: 0.4) {
//            // container yüksekliğini güncelle
//            self.containerViewHeightConstraint?.constant = height
//            // constraint yenilemek için bunu çağır
//            self.layoutIfNeeded()
//        }
        // Mevcut yüksekliği kaydet
//        currentContainerHeight = height
    }
    
    
    
//MARK: - Tap Gesture ----------------
//    func setupTapGesture() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
//        addGestureRecognizer(tapGesture)
//        
//        fullScreenPlayerView.previousButton.addTarget(self, action: #selector(didTapPreviousButton), for: .touchUpInside)
//        fullScreenPlayerView.nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
//    }
    
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        // Bottom sheet view'ın boyutları içindeki hareketleri kontrol etmek için koordinatları bottom sheet view'a dönüştür
//        let translatedPoint = gesture.location(in: containerView)
//        
//        // Sadece bottom sheet view'ın boyutları içindeki hareketleri işle
//        if containerView.bounds.contains(translatedPoint) {
//            
//            // Bottom sheet'in herhangi bir yerine tıklama yapıldığında burası çalışacak
//            print("Bottom sheet'e tıklandı")
//        }
        
    }
    
    //    @objc func didTapPlayButton() {
    //        audioPlayerService.playMedia(at: audioPlayerService.currentIndex)
    //    }
    

}



