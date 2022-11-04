//
//  UIFloatMenuHelper.swift
//  UIFloatMenu
//

import UIKit
import Foundation

class UIFloatMenuHelper {
    
    let shared = UIFloatMenuHelper()
    
    //MARK: - roundedFont()
    static func roundedFont(fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: fontSize, weight: weight)
        if #available(iOS 13.0, *) {
            if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
                return UIFont(descriptor: descriptor, size: fontSize)
            } else {
                return systemFont
            }
        } else {
            return systemFont
        }
    }
    
    static func theme() -> UIUserInterfaceStyle {
        if #available(iOS 13.0, *) {
            let userInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
            if userInterfaceStyle == .dark {
                return .dark
            } else {
                return .light
            }
        } else {
            return .light
        }
    }
    
    //MARK: - padding
    public enum padding {
        case top
        case bottom
    }
    
    //MARK: - getPadding(_ padding: padding)
    static func getPadding(_ padding: padding) -> CGFloat {
        if #available(iOS 15, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            switch padding {
            case .top:
                return (windowScene?.keyWindow?.safeAreaInsets.top)!
            case .bottom:
                return (windowScene?.keyWindow?.safeAreaInsets.bottom)!
            }
        } else {
            let window = UIApplication.shared.keyWindow
            switch padding {
            case .top:
                return window?.safeAreaInsets.top ?? 0
            case .bottom:
                return window?.safeAreaInsets.bottom ?? 0
            }
        }
    }
    
    // MARK: - correctPosition()
    static func correctPosition(_ position: UIFloatMenuPresentStyle) -> UIFloatMenuPresentStyle {
        let device = UIDevice.current.userInterfaceIdiom
        
        if device == .pad {
            let layout = Layout.determineLayout()
            
            if layout == .iPadOneThirdScreen {
                if case .center = position {
                    return .center
                }
                return .default
            }
            return position
        } else if device == .phone {
            if case .center = position {
                return .center
            }
            return .default
        } else {
            return position
        }
    }
    
    static func getTopVC() -> UIViewController {
        var topController: UIViewController {
            let keyWindow = UIApplication.shared.windows.filter( {$0.isKeyWindow} ).first
            if var topController = keyWindow?.rootViewController {
                while let presentedVC = topController.presentedViewController {
                    topController = presentedVC
                }
                return topController
            }
            return UIViewController()
        }
        return topController
    }
    
    static func showAlert(_ alert: UIAlertController) {
        var topController: UIViewController {
            let keyWindow = UIApplication.shared.windows.filter( {$0.isKeyWindow} ).first
            if var topController = keyWindow?.rootViewController {
                while let presentedVC = topController.presentedViewController {
                    topController = presentedVC
                }
                return topController
            }
            return UIViewController()
        }
        
        topController.present(alert, animated: true, completion: nil)
    }
    
    static func find(_ rows: [TextFieldRow], by identifier: String) -> String {
        if let index = rows.firstIndex(where: { $0.identifier == identifier}) {
            return rows[index].text
        }
        return ""
    }
    
}

// MARK: - Layout
struct Layout {
    
    enum LayoutStyle: String {
        case iPadFullScreen = "iPad Full Screen"
        case iPadHalfScreen = "iPad 1/2 Screen"
        case iPadTwoThirdScreen = "iPad 2/3 Screen"
        case iPadOneThirdScreen = "iPad 1/3 Screen"
        case iPhoneFullScreen = "iPhone"
    }
    
    static func determineLayout() -> LayoutStyle {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .iPhoneFullScreen
        }
        
        let screenSize = UIScreen.main.bounds.size
        let appSize = UIApplication.shared.windows[0].bounds.size
        let screenWidth = screenSize.width
        let appWidth = appSize.width
        
        if screenSize == appSize {
             return .iPadFullScreen
        }
        
        let persent = CGFloat(appWidth / screenWidth) * 100.0
        
        if persent <= 55.0 && persent >= 45.0 {
            return .iPadHalfScreen
        } else if persent > 55.0 {
            return .iPadTwoThirdScreen
        } else {
            return .iPadOneThirdScreen
        }
    }
    
}

// MARK: - Orientation
struct Orientation {
    
    static var isLandscape: Bool {
        get {
            return UIDevice.current.orientation.isValidInterfaceOrientation
                   ? UIDevice.current.orientation.isLandscape
                   : (UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isLandscape)!
        }
    }
    
    static var isPortrait: Bool {
        get {
            return UIDevice.current.orientation.isValidInterfaceOrientation
                   ? UIDevice.current.orientation.isPortrait
                   : (UIApplication.shared.windows.first?.windowScene?.interfaceOrientation.isPortrait)!
        }
    }

}

//MARK: - KeyboardHelper
final class KeyboardHelper {
    
    enum Animation {
        case keyboardWillShow
        case keyboardWillHide
    }
    
    typealias HandleBlock = (_ animation: Animation, _ keyboardFrame: CGRect, _ duration: TimeInterval) -> Void
    
    private let handleBlock: HandleBlock
    
    init(handleBlock: @escaping HandleBlock) {
        self.handleBlock = handleBlock
        setupNotification()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotification() {
        _ = NotificationCenter.default
            .addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] notification in
                self?.handle(animation: .keyboardWillShow, notification: notification)
            }
        
        _ = NotificationCenter.default
            .addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] notification in
                self?.handle(animation: .keyboardWillHide, notification: notification)
            }
    }
    
    private func handle(animation: Animation, notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        
        handleBlock(animation, keyboardFrame, duration)
    }
}
