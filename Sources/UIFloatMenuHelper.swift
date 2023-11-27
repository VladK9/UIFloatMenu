//
//  UIFloatMenuHelper.swift
//  UIFloatMenu
//

import UIKit
import Foundation

class UIFloatMenuHelper {
    
    let shared = UIFloatMenuHelper()
    
    // MARK: - getPosition()
    static public func getPosition(_ menuView: UIView, positions: UIFloatMenuConfig.UIFloatMenuPresentStyle, iPad_window_width: CGFloat = 0) -> CGPoint {
        let appRect = (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds)!
        let topPadding = UIFloatMenuHelper.getPadding(.top)
        let bottomPadding = UIFloatMenuHelper.getPadding(.bottom)

        var bottomSpace: CGFloat {
            return bottomPadding.isZero ? 15 : 30
        }

        var getPrepare: CGFloat {
            return appRect.height + bottomPadding + topPadding + menuView.bounds.height
        }

        var getShow: CGFloat {
            let lastHeight = menuView.bounds.height
            return appRect.height-lastHeight-bottomSpace+(lastHeight/2)
        }

        switch positions {
        case .center:
            if iPad_window_width != 0 {
                return CGPoint(x: iPad_window_width/2, y: appRect.height/2)
            } else {
                return CGPoint(x: appRect.width/2, y: appRect.height/2)
            }
        case .default:
            if iPad_window_width != 0 {
                return CGPoint(x: appRect.width/2, y: 0)
            } else {
                return CGPoint(x: appRect.width/2, y: getShow)
            }
        case .leftUp(let overNavBar):
            let space: CGFloat = overNavBar ? 5 : 44
            return CGPoint(x: (menuView.frame.size.width/2)+10, y: (menuView.frame.size.height/2)+topPadding+space)
        case .leftDown(let overToolBar):
            let space: CGFloat = overToolBar ? 0 : 44
            return CGPoint(x: (menuView.frame.size.width/2)+10, y: appRect.height-(menuView.frame.size.height/2)-10-space)
        case .rightUp(let overNavBar):
            let space: CGFloat = overNavBar ? 5 : 44
            if iPad_window_width != 0 {
                return CGPoint(x: iPad_window_width-(menuView.frame.size.width/2)-10, y: (menuView.frame.size.height/2)+topPadding+space)
            } else {
                return CGPoint(x: appRect.width-(menuView.frame.size.width/2)-10, y: (menuView.frame.size.height/2)+topPadding+space)
            }
        case .rightDown(let overToolBar):
            if iPad_window_width != 0 {
                return CGPoint(x: iPad_window_width-(menuView.frame.size.width/2)-10, y: 0)
            } else {
                let space: CGFloat = overToolBar ? 0 : 44
                return CGPoint(x: appRect.width-(menuView.frame.size.width/2)-10, y: appRect.height-(menuView.frame.size.height/2)-10-space)
            }
        }
    }
    
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
    static func correctPosition(_ position: UIFloatMenuConfig.UIFloatMenuPresentStyle) -> UIFloatMenuConfig.UIFloatMenuPresentStyle {
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

}

//MARK: - KeyboardHelper
final class KeyboardHelper {
    
    enum Animation {
        case keyboardWillShow
        case keyboardDidShow
        
        case keyboardWillHide
        case keyboardDidHide
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
            .addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main) { [weak self] notification in
                self?.handle(animation: .keyboardDidShow, notification: notification)
            }
        
        _ = NotificationCenter.default
            .addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] notification in
                self?.handle(animation: .keyboardWillHide, notification: notification)
            }
        
        _ = NotificationCenter.default
            .addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main) { [weak self] notification in
                self?.handle(animation: .keyboardDidHide, notification: notification)
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

extension UIView {
    
    func gestureIsEnable(_ bool: Bool) {
        for gesture in self.gestureRecognizers ?? [] {
            gesture.isEnabled = bool
        }
    }
    
}
