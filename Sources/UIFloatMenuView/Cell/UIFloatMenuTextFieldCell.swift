//
//  UIFloatMenuTextFieldCell.swift
//  UIFloatMenu
//

import UIKit

class UIFloatMenuTextFieldCell: UITableViewCell {
    
    // MARK: Views
    lazy var backView: UIView = {
        let uiview = UIView()
        uiview.layer.cornerRadius = 8
        uiview.backgroundColor = UIColor.lightGray.withAlphaComponent(0.08)
        uiview.layer.borderWidth = 0.5
        uiview.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.25).cgColor
        return uiview
    }()
    
    lazy var TextField: UITextField = {
        let textF = UITextField()
        textF.setLeftPadding(12)
        textF.setRightPadding(12)
        textF.font = UIFloatMenuHelper.roundedFont(fontSize: 17, weight: .regular)
        return textF
    }()
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(backView)
        backView.addSubview(TextField)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        backView.frame.size = CGSize(width: frame.width-20, height: frame.height-5)
        backView.center.x = frame.width/2
        backView.center.y = frame.height/2
        
        TextField.frame = CGRect(x: 0, y: 0, width: backView.frame.size.width, height: backView.frame.size.height)
    }
}

fileprivate extension UITextField {
    
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
