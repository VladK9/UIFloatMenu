//
//  UIFloatMenuConfig.swift
//  UIFloatMenu
//

import UIKit

// MARK: - UIFloatMenuConfig
public struct UIFloatMenuConfig {
    
    //MARK: - presentationStyle
    /**
     UIFloatMenu: Present styles.
     */
    public enum UIFloatMenuPresentStyle {
        
        /**
        UIFloatMenu: Located in center of window
        */
        case center
        
        /**
        UIFloatMenu: Presented from buttom
        */
        case `default`
        
        /**
        UIFloatMenu: Located in left up corner
         
        overToolBar = **false**
        */
        case leftUp(overNavBar: Bool = false)
        
        /**
        UIFloatMenu: Located in left down corner
         
        overToolBar = **true**
        */
        case leftDown(overToolBar: Bool = true)
        
        
        /**
        UIFloatMenu: Located in right up corner
         
        overToolBar = **false**
        */
        case rightUp(overNavBar: Bool = false)
        
        /**
        UIFloatMenu: Located in right down
         
        overToolBar = **true**
        */
        case rightDown(overToolBar: Bool = true)
    }
    
    /**
    UIFloatMenu: Corner radius of menu
     
    > Default: **12**.
    */
    public var cornerRadius: CGFloat!
    
    /**
    UIFloatMenu: Width of menu for iPad (for iPhone is always **window.width-30**)
     
    > Default: **400**.
    */
    public var viewWidth: CGFloat!
    
    /**
    UIFloatMenu: Add blur to background
     
    > Default: **false**.
    */
    public var blurBackground: Bool
    
    public var blurStyle: UIBlurEffect.Style
    
    /**
    UIFloatMenu: Presentation styles
    
    - Parameter center: Located in center of window
    - Parameter default: Presented from bottom
    - Parameter leftUp: Located in left up corner
    - Parameter leftDown: Located in left down corner
    - Parameter rightUp: Located in right up corner
    - Parameter rightDown: Located in right down corner
     
    > Default: **.default** .
    */
    public var presentation: UIFloatMenuPresentStyle!
    
    public var dragEnable: Bool!
    
    public init(cornerRadius: CGFloat = 12,
                blurBackground: Bool = false,
                blurStyle: UIBlurEffect.Style = .prominent,
                presentation: UIFloatMenuPresentStyle = .default,
                dragEnable: Bool = true,
                viewWidth: CGFloat = 345) {
        self.cornerRadius = cornerRadius
        self.blurBackground = blurBackground
        self.blurStyle = blurStyle
        
        self.presentation = presentation
        self.dragEnable = dragEnable
        
        self.viewWidth = viewWidth
    }
    
}

// MARK: - UIMenuHeaderConfig
public struct UIFloatMenuHeaderConfig {
    
    /**
    UIFloatMenu: Show header
     
    > Default: **true**.
    */
    public var showHeader: Bool
    
    /**
    UIFloatMenu: Title of header
    */
    public var title: String
    
    /**
    UIFloatMenu: Subtitle of header (optional)
    */
    public var subtitle: String?
    
    /**
    UIFloatMenu: Show line under header
     
    > Default: **true**.
    */
    public var showLine: Bool
    
    /**
    UIFloatMenu: Show close button
     
    > Default: **true**.
    */
    public var showButton: Bool
    
    /**
    UIFloatMenu: **Left** and **Right** insets for line
     
    > Default: **15**.
    */
    public var lineInset: CGFloat
    
    public init(showHeader: Bool = true, title: String = "", subtitle: String? = "",
                showLine: Bool = true, showButton: Bool = true, lineInset: CGFloat = 15) {
        self.showHeader = showHeader
        
        self.title = title
        self.subtitle = subtitle
        
        self.showLine = showLine
        self.showButton = showButton
        self.lineInset = lineInset
    }
    
}

// MARK: - UIFloatMenuQueue
public struct UIFloatMenuQueue {
    
    public var uuid: Int!
    public var viewHeight: CGFloat!
    public var header: UIFloatMenuHeaderConfig!
    public var config: UIFloatMenuConfig!
    public var actions: [UIFloatMenuAction]!
    
    public init(uuid: Int, viewHeight: CGFloat = 0, header: UIFloatMenuHeaderConfig, config: UIFloatMenuConfig, actions: [UIFloatMenuAction]) {
        self.uuid = uuid
        self.viewHeight = viewHeight
        self.header = header
        self.config = config
        self.actions = actions
    }
    
}

// MARK: - UIFloatMenuID
class UIFloatMenuID {
    
    let shared = UIFloatMenuID()
    
    static let backViewID = 100010001
    static let containerViewID = 11223300332211
    static let indicatorID = 1000030000
    
    static func genID(_ count: Int) -> Int {
        if count == 0 {
            return backViewID
        }
        return backViewID+count
    }
    
}

class UIFloatMenuColors {
    
    let shared = UIFloatMenuColors()
    
    static let revColor = UIColor(named: "UIMenuRevColor")
    
    static func mainColor() -> UIColor {
        let light = UIColor(red: 250/255, green: 250/255, blue: 249/255, alpha: 1)
        let dark = UIColor(red: 39/255, green: 44/255, blue: 49/255, alpha: 1)
        
        return UIColor { (trait) -> UIColor in
            return trait.userInterfaceStyle == .light ? light : dark
        }
    }
    
}
