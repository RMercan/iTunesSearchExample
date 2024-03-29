//
//  UIViewExtensions.swift
//  ITunesSearchExample
//
//  Created by RabiaMercan on 4.03.2024.
//


import UIKit

public extension UIView {
    
    var rightToLeft: Bool {
        return UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
    }
    
    var safeAreaBottom: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return window.safeAreaInsets.bottom
        }
        
        return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        
    }
    
    var safeAreaTop: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return window.safeAreaInsets.top
        }
        
        return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    }
}

