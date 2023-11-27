//
//  UIFloatMenuAction.swift
//  UIFloatMenu
//

import UIKit

//MARK: - itemSetup
public enum itemSetup {
    
    //MARK: - selectionConfig
    public enum selectionConfig {
        case multi(isSelected: Bool = false, selectedIcon: UIImage?, selectedTitle: String, defaultIcon: UIImage?, defaultTitle: String)
        case `default`(icon: UIImage? = nil, title: String)
    }

    //MARK: - transition_style
    public enum transition_style {
        case `default`(animated: Bool = true)
        case fade
    }

    //MARK: - h_heightStyle
    public enum h_heightStyle {
        case compact
        case `default`
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
        case `default`
        case big
    }

    //MARK: - inputType
    public enum inputType {
        case textField(text: String = "", isSecure: Bool = false, content: UITextContentType? = nil, keyboard: UIKeyboardType = .default)
        case textView(text: String = "", content: UITextContentType? = nil, keyboard: UIKeyboardType = .default)
    }
    
    //MARK: - labelConfig
    public enum labelConfig {
        case config(fontSize: CGFloat = 15, fontWeight: UIFont.Weight = .semibold)
    }

    //MARK: - itemColor
    public enum itemColor {
        case `default`
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
        case empty(height: CGFloat = 12)
        case line(_ color: UIColor = UIColor.gray.withAlphaComponent(0.25), inset: CGFloat = 15)
        case dashedLine(_ color: UIColor = UIColor.gray.withAlphaComponent(0.35))
        case divider
    }
    
    /**
    UIFloatMenu: ActionCell
    
    - Parameter selection: selectionConfig **(.multi - with 2 state, .default)**
    - Parameter subtitle: Optional
    - Parameter layout: Loyout of cell (**.Title_Icon**, **.Icon_Title**), Default: **.Title_Icon**.
    - Parameter height: Height of cell (**.standard**,  **.compact**), Default: **.standard**.
    */
    case ActionCell(selection: selectionConfig, subtitle: String = "", itemColor: itemColor = .default,
                    layout: cellLayout = .Icon_Title, height: heightStyle = .default)
    
    /**
    UIFloatMenu: Title
    
    - Parameter title: Title
    */
    case Title(_ title: String)
    
    /**
    UIFloatMenu: Spacer
    
    - Parameter type: Type of spacer (**.empty**, **.line**, **.divider**)
    */
    case Spacer(type: spacerType = .empty())
    
    /**
    UIFloatMenu: InfoCell
    
    - Parameter icon: Optional
    - Parameter title: Title
    - Parameter label: Configuration of label (**fontSize**, **fontWeight**)
    */
    case InfoCell(icon: UIImage? = nil, title: String,
                  label: labelConfig = .config(fontSize: 15, fontWeight: .semibold))
    
    /**
    UIFloatMenu: InputCell
    
    - Parameter type: **.textField()** or **.textView()**
    - Parameter placeholder: Placeholder
    - Parameter isResponder: Is active at start
    - Parameter identifier: Identifier to search data in **UIFloatMenuGetInputData** delegate
    */
    case InputCell(type: inputType, placeholder: String, isResponder: Bool = false, identifier: String = "")
    
    /**
    UIFloatMenu: SwitchCell
    
    - Parameter icon: Optional
    - Parameter title: Title
    - Parameter isOn: Is On at start
    - Parameter tintColor: Tint color
    - Parameter action: Selector for Switch
    */
    case SwitchCell(icon: UIImage? = nil, title: String, isOn: Bool = false, tintColor: UIColor = .systemBlue, action: Selector)
    
    /**
    UIFloatMenu: SwitchCell
    
    - Parameter title: Optional
    - Parameter items: Items **[UIImage, String]**
    - Parameter selected: Selected item
    - Parameter action: Selector for SegmentControl
    */
    case SegmentCell(title: String = "", items: [Any], selected: Int = 0, action: Selector)
    
    /**
    UIFloatMenu: HorizontalCell
    
    - Parameter items: actions **[UIFloatMenuAction]**
    - Parameter height: h_heightStyle
    - Parameter layout: h_cellLayout
    */
    case HorizontalCell(items: [UIFloatMenuAction], height: h_heightStyle = .default, layout: h_cellLayout = .center)
    
    /**
    UIFloatMenu: CustomCell
    
    - Parameter view: custom UIView
    */
    case CustomCell(view: UIView)
}

public typealias UIFloatMenuActionHandler = (UIFloatMenuAction) -> Void

//MARK: - UIFloatMenuAction
public class UIFloatMenuAction {
    
    /**
    UIFloatMenu: item
    */
    public var item: itemSetup
    
    /**
    UIFloatMenu: closeOnTap
    */
    public var closeOnTap: Bool
    
    /**
    UIFloatMenu: action
    */
    public var action: UIFloatMenuActionHandler?
    
    /**
    UIFloatMenu: isSelected
    */
    public var isSelected: Bool?
    
    public init(item: itemSetup,
                closeOnTap: Bool = true,
                action: UIFloatMenuActionHandler? = nil) {
        self.item = item
        
        self.closeOnTap = closeOnTap
        self.action = action
    }
    
}
