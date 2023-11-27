//
//  UIFloatMenuDelegate.swift
//  UIFloatMenu
//

import UIKit

//MARK: - Delegates
public struct Delegates {
    var close: UIFloatMenuCloseDelegate!
    var textField: UIFloatMenuInputDelegate!
}

//MARK: - TextFieldRow
public struct InputRow {
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

//MARK: - UIFloatMenuInputDelegate
public protocol UIFloatMenuInputDelegate: AnyObject {
    
    /**
    UIFloatMenu: Called when pressed action cell.
     
    - Returns: Text from all **textfield's** and **textview's** in menu
    */
    func UIFloatMenuGetInputData(_ rows: [InputRow])
    
}
