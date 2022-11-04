//
//  UIFloatMenuDelegate.swift
//  UIFloatMenu
//

import UIKit

//MARK: - Delegates
public struct Delegates {
    var close: UIFloatMenuCloseDelegate!
    var textField: UIFloatMenuTextFieldDelegate!
}

//MARK: - TextFieldRow
public struct TextFieldRow {
    let text: String!
    let identifier: String!
}

//MARK: - UIFloatMenuCloseDelegate
public protocol UIFloatMenuCloseDelegate: AnyObject {
    
    /**
     UIFloatMenu: Called when pressed close button (or overlay) or swiped.
     */
    func UIFloatMenuDidCloseMenu()
    
}

//MARK: - UIFloatMenuTextFieldDelegate
public protocol UIFloatMenuTextFieldDelegate: AnyObject {
    
    /**
     UIFloatMenu: Called when pressed action cell.
     
     - Returns: Text from all textfields in menu
     */
    func UIFloatMenuGetTextFieldData(_ rows: [TextFieldRow])
    
}
