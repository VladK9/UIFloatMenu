//
//  UIFloatMenuTextFieldCell.swift
//  UIFloatMenu
//

import UIKit

class UIFloatMenuInputCell: UITableViewCell, UITextViewDelegate {
    
    var inputType: itemSetup.inputType!
    
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
    
    var textLayer = CATextLayer()
    lazy var TextView: UITextView = {
        let textV = UITextView()
        textV.font = UIFloatMenuHelper.roundedFont(fontSize: 17, weight: .regular)
        textV.backgroundColor = .clear
        return textV
    }()
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(backView)
        backView.addSubview(TextField)
        backView.addSubview(TextView)
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
        
        switch inputType {
        case .textField(_,_,_,_):
            TextField.frame = CGRect(x: 0, y: 0, width: backView.frame.size.width, height: backView.frame.size.height)
        case .textView(_,_,_):
            TextView.delegate = self
            TextView.frame.size.height = backView.bounds.height-5
            TextView.frame.size.width = backView.bounds.width-10
            TextView.center.y = backView.bounds.height/2
            TextView.center.x = backView.bounds.width/2
            
            textLayer.contentsScale = UIScreen.main.scale
            textLayer.alignmentMode = .left
            textLayer.isWrapped = true
            textLayer.foregroundColor = UIFloatMenuColors.revColor?.withAlphaComponent(0.7).cgColor
            textLayer.fontSize = 17
            textLayer.font = UIFloatMenuHelper.roundedFont(fontSize: 17, weight: .regular)
            textLayer.frame = TextView.bounds.insetBy(dx: 5, dy: 8)
            TextView.layer.insertSublayer(textLayer, at: 0)
        case .none:
            break
        }
    }
    
    //MARK: - textViewDidChange
    func textViewDidChange(_ textView: UITextView) {
        textLayer.isHidden = textView.text.isEmpty ? false : true
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
