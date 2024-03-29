////
////  CustomModalViewController.swift
////  ITunesSearchExample
////
////  Created by RabiaMercan on 19.03.2024.
////
//
//import UIKit
//
//class CustomModalViewController: UIViewController {
//    
//    lazy var bottomSheetView: BottomSheetView = {
//        let view = BottomSheetView(frame: self.view.frame)
//        return view
//    }()
//    
//    let audioPlayerService = AudioPlayerService()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        bottomSheetView.frame = self.view.frame
//        self.view.addSubview(bottomSheetView)
//        
//        bottomSheetView.setupPanGesture()
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
////        bottomSheetView.animatePresentContainer()
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        // View ekrandan kaybolduğunda yapılacak işlemler
////        self.dismiss(animated: true)
//    }
//    
//}
