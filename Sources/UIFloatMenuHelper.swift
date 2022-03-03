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
    
    //MARK: - detectTheme()
    static func detectTheme(dark: UIColor, light: UIColor, any: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            let userInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
            if userInterfaceStyle == .dark {
                return dark
            } else {
                return light
            }
        } else {
            return any
        }
    }
    
    //MARK: - HexToUIColor(_ hex: String)
    static func HexToUIColor(_ hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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
    
    //MARK: - dashedLine()
    static func dashedLine(width: CGFloat, color: UIColor) -> UIView {
        let backView = UIView()
        backView.frame.size.width = width
        backView.frame.size.height = 1
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 1.1
        shapeLayer.lineDashPattern = [2,3]
        shapeLayer.lineJoin = .round
        
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 0, y: 0), CGPoint(x: width, y: 0)])
        shapeLayer.path = path
        backView.layer.addSublayer(shapeLayer)
        
        return backView
    }
    
}

// MARK: - Detect gesture direction
extension UIPanGestureRecognizer {
    
    public struct PanGestureDirection: OptionSet {
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        static let Up = PanGestureDirection(rawValue: 1 << 0)
        static let Down = PanGestureDirection(rawValue: 1 << 1)
    }
    
    private func getDirectionBy(velocity: CGFloat, greater: PanGestureDirection, lower: PanGestureDirection) -> PanGestureDirection {
        if velocity == 0 {
            return []
        }
        return velocity > 0 ? greater : lower
    }
    
    public func direction(in view: UIView) -> PanGestureDirection {
        let velocity = self.velocity(in: view)
        let yDirection = getDirectionBy(velocity: velocity.y, greater: PanGestureDirection.Down, lower: PanGestureDirection.Up)
        return (yDirection)
    }
}

extension UIView {
    
    //MARK: - UIFloatMenuShadow()
    func UIFloatMenuShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
    }
    
    //MARK: - UIFloatMenuRoundCorners()
    func UIFloatMenuRoundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
    
}

extension UIColor {
    
    //MARK: - isLight
    var isLight: Bool {
        var white: CGFloat = 0
        getWhite(&white, alpha: nil)
        return white > 0.8
    }
    
    //MARK: - lighter/darker
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
    
}

extension UITableView {
    var contentSizeHeight: CGFloat {
        var height = CGFloat(0)
        for section in 0..<numberOfSections {
            height = height + rectForHeader(inSection: section).height
            let rows = numberOfRows(inSection: section)
            for row in 0..<rows {
                height = height + rectForRow(at: IndexPath(row: row, section: section)).height
            }
        }
        return height
    }
}

extension UITextField {
    
    func setLeftPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPadding(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
}

// MARK: - Layout
struct Layout {
    
    enum LayoutStyle: String {
        case iPadFullscreen = "iPad Full Screen"
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
             return .iPadFullscreen // Full screen
        }
        
        let persent = CGFloat(appWidth / screenWidth) * 100.0
        
        if persent <= 55.0 && persent >= 45.0 {
            return .iPadHalfScreen // The view persent between 45-55 - it's half screen
        } else if persent > 55.0 {
            return .iPadTwoThirdScreen // More than 55% - it's 2/3
        } else {
            return .iPadOneThirdScreen // Less than 45% - it's 1/3
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
