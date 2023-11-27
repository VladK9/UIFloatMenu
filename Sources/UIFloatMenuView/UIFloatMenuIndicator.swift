//
//  UIFloatMenuIndicator.swift
//  UIFloatMenuExample
//

import UIKit
import Foundation

class UIFloatMenuIndicator: UIView {
    
    private var contentStackView: UIStackView = UIStackView()
    
    private let indicator = UIActivityIndicatorView(style: .medium)
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIFloatMenuColors.revColor?.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.isUserInteractionEnabled = false
        label.font = UIFloatMenuHelper.roundedFont(fontSize: 15, weight: .semibold)
        return label
    }()
    
    var frameSize: CGSize!
    
    public init(text: String, frameSize: CGSize) {
        super.init(frame: CGRect.zero)
        self.frameSize = frameSize
        self.titleLabel.text = text
        
        frame.size = CGSize(width: frameSize.width, height: frameSize.height)
        
        addSubview(contentStackView)
        contentStackView.axis = .vertical
        contentStackView.distribution = .fillProportionally
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        indicator.startAnimating()
        contentStackView.addArrangedSubview(indicator)
        if text != "" {
            contentStackView.addArrangedSubview(titleLabel)
        }
        
        self.tag = UIFloatMenuID.indicatorID
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        frame.size = CGSize(width: frameSize.width, height: frameSize.height)
        
        NSLayoutConstraint.activate([
            indicator.heightAnchor.constraint(equalToConstant: 25),
            indicator.widthAnchor.constraint(equalToConstant: 25),
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 70),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -70),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
