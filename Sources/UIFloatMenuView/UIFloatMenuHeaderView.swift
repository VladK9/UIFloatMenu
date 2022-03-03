//
//  UIFloatMenuHeaderView.swift
//  UIFloatMenu
//

import UIKit
import Foundation

class UIFloatMenuHeaderView: UIView {
    
    private var stackView: UIStackView = UIStackView()
    
    var menuConfig = UIFloatMenuConfig()
    var headerConfig = UIFloatMenuHeaderConfig()
    
    private var viewWidth = CGFloat()
    
    private var headerHeight: CGFloat = 60
    
    //MARK: - Views
    private let TitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIFloatMenuColors.revColor
        label.font = UIFloatMenuHelper.roundedFont(fontSize: 18, weight: .semibold)
        return label
    }()
    
    private let SubtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIFloatMenuColors.revColor
        label.font = UIFloatMenuHelper.roundedFont(fontSize: 11, weight: .regular)
        return label
    }()
    
    private var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.isEnabled = true
        button.setImage(UIImage(systemName: "multiply.circle.fill", withConfiguration: UIImage.SymbolConfiguration(textStyle: .title3)), for: .normal)
        button.tintColor = UIColor.systemGray.withAlphaComponent(0.4)
        return button
    }()
    
    lazy var lineView: UIView = {
        let uiview = UIView()
        uiview.backgroundColor = UIColor.gray.withAlphaComponent(0.25)
        uiview.frame.origin.y = headerHeight-1
        return uiview
    }()
    
    //MARK: - init
    public init(headerConfig: UIFloatMenuHeaderConfig, menuConfig: UIFloatMenuConfig) {
        super.init(frame: CGRect.zero)
        let appRect = UIApplication.shared.windows[0].bounds
        let device = UIDevice.current.userInterfaceIdiom
        let width = (device == .pad ? menuConfig.viewWidth_iPad : (Orientation.isPortrait ? appRect.width-30 : appRect.width/2.5))!
        
        self.headerConfig = headerConfig
        self.menuConfig = menuConfig
        self.viewWidth = width
        
        addSubview(cancelButton)
        backgroundColor = menuConfig.blurBackground ? .clear : UIFloatMenuColors.mainColor
        
        TitleLabel.text = headerConfig.title
        SubtitleLabel.text = headerConfig.subTitle
        
        if headerConfig.showLine {
            lineView.frame.size = CGSize(width: width-(headerConfig.lineInset*2), height: 1)
            lineView.center.x = viewWidth/2
            addSubview(lineView)
        }
        
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        
        if headerConfig.title != "" && headerConfig.subTitle != "" {
            stackView.addArrangedSubview(TitleLabel)
            stackView.addArrangedSubview(SubtitleLabel)
        }
        
        if headerConfig.title != "" && headerConfig.subTitle == "" {
            stackView.addArrangedSubview(TitleLabel)
        }
        
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -55),
        ])
        
        stackView.isUserInteractionEnabled = true
        
        let pan = UITapGestureRecognizer(target: self, action: #selector(tapClose(_:)))
        cancelButton.addGestureRecognizer(pan)
    }
    
    //MARK: - coder
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        cancelButton.frame = CGRect(x: frame.width-41, y: 0, width: 30, height: 30)
        cancelButton.center.y = headerHeight/2
        
        if headerConfig.showLine {
            lineView.frame.size = CGSize(width: frame.size.width-(headerConfig.lineInset*2), height: 1)
            lineView.center.x = frame.size.width/2
            addSubview(lineView)
        }
        
        frame.size.height = headerHeight
    }
    
    // MARK: tapClose
    @objc func tapClose(_ sender: UIPanGestureRecognizer) {
        NotificationCenter.default.post(name: NSNotification.Name("UIFloatMenuClose"), object: nil)
    }
}
