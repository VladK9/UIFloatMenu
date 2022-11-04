//
//  UIFloatMenuSpacerCell.swift
//  UIFloatMenu
//

import UIKit

class UIFloatMenuSpacerCell: UITableViewCell {
    
    var spacerType: spacerType!
    
    private var isReused: Bool = false
    private var isLoaded: Bool = false
    
    private var contentStackView: UIStackView = UIStackView()
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        isUserInteractionEnabled = false
        backgroundColor = .clear
        
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.axis = .vertical
        contentStackView.distribution = .fillProportionally
        addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -0),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -0)
        ])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: prepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        isReused = true
        isLoaded = true
    }
    
    // MARK: layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isReused && isLoaded == false {
            switch spacerType {
            case .empty:
                break
            case .line(let color, let inset):
                let lineView: UIView = {
                    let uiview = UIView()
                    uiview.backgroundColor = color
                    uiview.frame.size = CGSize(width: frame.width-30, height: 1)
                    uiview.center = CGPoint(x: frame.width/2, y: frame.height/2)
                    uiview.isUserInteractionEnabled = false
                    return uiview
                }()
                
                contentStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 5.5, leading: inset, bottom: 5.5, trailing: inset)
                
                contentStackView.addArrangedSubview(lineView)
                break
            case .dashedLine(let color):
                let dashedView = dashedLine(width: frame.width-30, color: color)
                dashedView.isUserInteractionEnabled = false
                
                contentStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 5.5, leading: 15, bottom: 5.5, trailing: 15)
                
                contentStackView.addArrangedSubview(dashedView)
                break
            case .divider:
                let dividerView: UIView = {
                    let uiview = UIView()
                    uiview.backgroundColor = dividerColor
                    uiview.frame.size = CGSize(width: frame.width, height: frame.size.height)
                    uiview.frame.origin = CGPoint(x: 0, y: 0)
                    uiview.isUserInteractionEnabled = false
                    return uiview
                }()
                
                contentStackView.addArrangedSubview(dividerView)
                break
            case .none:
                break
            }
        }
        isLoaded = true
    }
    
    private var dividerColor: UIColor = {
        if #available(iOS 13, *) {
            return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                if UITraitCollection.userInterfaceStyle == .dark {
                    return UIColor.darkGray.withAlphaComponent(0.2)
                } else {
                    return UIColor.lightGray.withAlphaComponent(0.15)
                }
            }
        } else {
            return UIColor.darkGray.withAlphaComponent(0.15)
        }
    }()
    
    //MARK: - dashedLine()
    private func dashedLine(width: CGFloat, color: UIColor) -> UIView {
        let backView = UIView()
        backView.frame.size.width = width
        backView.frame.size.height = 1
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = 1.1
        shapeLayer.lineDashPattern = [2,3]
        shapeLayer.lineJoin = .round
        
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 0, y: 0), CGPoint(x: width, y: 0)])
        shapeLayer.path = path
        backView.layer.addSublayer(shapeLayer)
        
        return backView
    }
}
