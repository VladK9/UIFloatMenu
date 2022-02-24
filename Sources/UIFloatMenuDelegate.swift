//
//  UIFloatMenuDelegate.swift
//  UIFloatMenu
//

import UIKit

//MARK: - UIFloatMenuCloseDelegate
public protocol UIFloatMenuCloseDelegate: AnyObject {
    
    /**
     UIFloatMenu: Called when pressed close button (or overlay) or swiped.
     */
    func didCloseMenu()
    
}

//MARK: - UIFloatMenuTextFieldDelegate
public protocol UIFloatMenuTextFieldDelegate: AnyObject {
    
    /**
     UIFloatMenu: Called when pressed action cell.
     
     - Returns: Text from all textfields in menu
     */
    func getTextFieldData(_ data: [String])
    
}