//
//  UIFloatMenuHeaderView.swift
//  UIFloatMenu
//

import UIKit

class UIFloatMenuHeaderView: UIView {
    
    private var stackView: UIStackView = UIStackView()
    private var labelsStackView: UIStackView = UIStackView()
    
    var headerConfig = UIFloatMenuHeaderConfig()
    
    private var headerHeight: CGFloat = 60
    
    //MARK: - Views
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIFloatMenuColors.revColor
        label.font = UIFloatMenuHelper.roundedFont(fontSize: 18, weight: .semibold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIFloatMenuColors.revColor
        label.font = UIFloatMenuHelper.roundedFont(fontSize: 11, weight: .semibold)
        return label
    }()
    
    private var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "multiply.circle.fill", withConfiguration: UIImage.SymbolConfiguration(textStyle: .title3)), for: .normal)
        button.setImage(UIImage(systemName: "multiply.circle.fill", withConfiguration: UIImage.SymbolConfiguration(textStyle: .title3)), for: .highlighted)
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
        let width = (device == .pad ? menuConfig.viewWidth : (UIFloatMenuHelper.Orientation.isPortrait ? appRect.width-30 : appRect.width/2.5))!
        
        self.headerConfig = headerConfig
        
        titleLabel.text = headerConfig.title
        subtitleLabel.text = headerConfig.subtitle
        
        labelsStackView.axis = .vertical
        labelsStackView.distribution = .fillProportionally
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        if headerConfig.showLine {
            lineView.frame.size = CGSize(width: width-(headerConfig.lineInset*2), height: 1)
            lineView.center.x = width/2
            addSubview(lineView)
        }
        
        stackView.axis = .horizontal
        stackView.distribution = .fill
        
        if headerConfig.title != "" && headerConfig.subtitle != "" {
            labelsStackView.addArrangedSubview(titleLabel)
            labelsStackView.addArrangedSubview(subtitleLabel)
        }
        
        if headerConfig.title != "" && headerConfig.subtitle == "" {
            labelsStackView.addArrangedSubview(titleLabel)
        }
        
        stackView.addArrangedSubview(labelsStackView)
        
        if headerConfig.showButton {
            stackView.addArrangedSubview(closeButton)
        }
        
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7)
        ])
        
        stackView.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapClose(_:)))
        closeButton.addGestureRecognizer(tap)
    }
    
    //MARK: - coder
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        if #available(iOS 13.4, *) {
            closeButton.isPointerInteractionEnabled = true
        }
        
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
