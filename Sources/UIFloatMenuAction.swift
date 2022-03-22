//
//  UIFloatMenuAction.swift
//  UIFloatMenu
//

import UIKit

//MARK: - h_heightStyle
public enum h_heightStyle {
    case compact
    case standard
}

//MARK: - h_cellLayout
public enum h_cellLayout {
    case Icon_Title
    case center
    case Title_Icon
}

//MARK: - heightStyle
public enum heightStyle {
    case compact
    case standard
    case big
}

//MARK: - labelConfig
public enum labelConfig {
    case config(fontSize: CGFloat = 15, fontWeight: UIFont.Weight = .semibold)
}

//MARK: - itemColor
public enum itemColor {
    case standard
    case clear
    case filled(_ color: UIColor)
    case tinted(_ color: UIColor)
    case custom(iconColor: UIColor = .clear, textColor: UIColor, backColor: UIColor)
}

//MARK: - cellLayout
public enum cellLayout {
    case Icon_Title
    case Title_Icon
}

//MARK: - spacerType
public enum spacerType {
    case empty
    case line(_ color: UIColor = UIColor.gray.withAlphaComponent(0.25), inset: CGFloat = 15)
    case dashedLine(_ color: UIColor = UIColor.gray.withAlphaComponent(0.35))
    case divider
}

//MARK: - itemSetup
public enum itemSetup {
    /**
    UIFloatMenu: ActionCell
    
    - Parameter icon: Optional
    - Parameter title: Title
    - Parameter subtitle: Optional
    - Parameter layout: Loyout of cell (**.Title_Icon**, **.Icon_Title**), Default: **.Title_Icon**.
    - Parameter height: Height of cell (**.standard**,  **.compact**), Default: **.standard**.
    */
    case ActionCell(icon: UIImage? = nil, title: String, subtitle: String = "", layout: cellLayout = .Title_Icon, height: heightStyle = .standard)
    
    /**
    UIFloatMenu: Title
    
    - Parameter title: Title
    */
    case Title(_ title: String)
    
    /**
    UIFloatMenu: Spacer
    
    - Parameter type: Type of spacer (**.empty**, **.line**, **.divider**)
    */
    case Spacer(type: spacerType = .empty)
    
    /**
    UIFloatMenu: InfoCell
    
    - Parameter icon: Optional
    - Parameter title: Title
    - Parameter label: Configuration of label (**fontSize**, **fontWeight**)
    */
    case InfoCell(icon: UIImage? = nil, title: String,
                  label: labelConfig = .config(fontSize: 15, fontWeight: .semibold))
    
    /**
    UIFloatMenu: TextFieldCell
    
    - Parameter title: Data in TextField at start
    - Parameter placeholder: Placeholder
    - Parameter isResponder: Is active at start
    - Parameter isSecure: Show dots
    - Parameter content: UITextContentType
    - Parameter keyboard: UIKeyboardType
    */
    case TextFieldCell(title: String = "", placeholder: String, isResponder: Bool = false,
                       isSecure: Bool = false, content: UITextContentType? = nil, keyboard: UIKeyboardType = .default)
    
    /**
    UIFloatMenu: SwitchCell
    
    - Parameter icon: Optional
    - Parameter title: Title
    - Parameter isOn: Is On at start
    - Parameter tintColor: Tint color
    - Parameter action: Action for Switch
    */
    case SwitchCell(icon: UIImage? = nil, title: String, isOn: Bool = false, tintColor: UIColor = .systemBlue, action: Selector)
    
    /**
    UIFloatMenu: SwitchCell
    
    - Parameter title: Optional
    - Parameter items: Items **[UIImage, String]**
    - Parameter selected: Selected item
    - Parameter action: Action for SegmentControl
    */
    case SegmentCell(title: String = "", items: [Any], selected: Int = 0, action: Selector)
    
    /**
    UIFloatMenu: HorizontalCell
    
    - Parameter items: [UIFloatMenuAction]
    */
    case HorizontalCell(items: [UIFloatMenuAction], height: h_heightStyle = .standard, layout: h_cellLayout = .center)
}

public typealias UIFloatMenuActionHandler = (UIFloatMenuAction) -> Void

//MARK: - UIFloatMenuAction
public class UIFloatMenuAction {
    
    /**
    UIFloatMenu: item
    */
    public var item: itemSetup
    
    /**
    UIFloatMenu: itemColor
    */
    public var itemColor: itemColor
    
    /**
    UIFloatMenu: closeOnTap
    */
    public var closeOnTap: Bool
    
    /**
    UIFloatMenu: action
    */
    public var action: UIFloatMenuActionHandler?
    
    public init(item: itemSetup,
                itemColor: itemColor = .standard,
                closeOnTap: Bool = true,
                action: UIFloatMenuActionHandler? = nil) {
        self.item = item
        
        self.itemColor = itemColor
        
        self.closeOnTap = closeOnTap
        self.action = action
    }
    
}
