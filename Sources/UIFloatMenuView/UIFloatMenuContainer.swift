//
//  UIFloatMenuContainer.swift
//  UIFloatMenu
//

import UIKit
import Foundation

final class ContainerView: UIView, UIGestureRecognizerDelegate {
    
    // Config
    private var viewConfig = UIFloatMenuConfig()
    
    // KeyboardHelper
    private var keyboardHelper: KeyboardHelper?
    
    // Animation duration
    private var animationDuration: TimeInterval = 0.4
    
    //MARK: - init
    init(config: UIFloatMenuConfig) {
        super.init(frame: .zero)
        self.viewConfig = config
        
        let appRect = UIApplication.shared.windows[0].bounds
        
        self.tag = UIFloatMenuID.containerViewID
        self.isUserInteractionEnabled = true
        
        if viewConfig.blurBackground {
            let blurEffect = UIBlurEffect(style: viewConfig.blurStyle)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = frame
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(blurView)
            sendSubviewToBack(blurView)
        } else {
            backgroundColor = UIFloatMenuColors.mainColor()
        }
        
        self.layer.cornerRadius = viewConfig.cornerRadius
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.25).cgColor
        
        keyboardHelper = KeyboardHelper { animation, keyboardFrame, _ in
            switch animation {
            case .keyboardWillShow:
                var y: CGFloat {
                    return (self.frame.size.height/2)
                }
                
                UIView.animate(withDuration: self.animationDuration, animations: {
                    self.transform = CGAffineTransform(translationX: 0, y: -y)
                })
            case .keyboardWillHide:
                self.transform = .identity
            case .keyboardDidShow:
                break
            case .keyboardDidHide:
                break
            }
        }
    }
    
    //MARK: - layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK: - setMaxHeight()
    private func setMaxHeight(_ currentHeight: CGFloat) -> CGFloat {
        let topPadding = UIFloatMenuHelper.getPadding(.top)
        let bottomPadding = UIFloatMenuHelper.getPadding(.bottom)
        
        let appRect = UIApplication.shared.windows[0].bounds
        var topSpace: CGFloat {
            let device = UIDevice.current.userInterfaceIdiom
            return device == .pad ? 250 : (UIFloatMenuHelper.Orientation.isLandscape ? 30 : 120)
        }
        
        let maxH = appRect.height-topPadding-bottomPadding-topSpace
        
        if currentHeight >= maxH {
            return maxH
        }
        return currentHeight
    }
    
    //MARK: - setMaxWidth()
    private func setMaxWidth(_ currentWidth: CGFloat) -> CGFloat {
        let appRect = UIApplication.shared.windows[0].bounds
        let device = UIDevice.current.userInterfaceIdiom
        
        if device == .pad {
            return currentWidth
        } else if device == .phone {
            if UIFloatMenuHelper.Orientation.isLandscape {
                return appRect.height-30
            } else if UIFloatMenuHelper.Orientation.isPortrait {
                return appRect.width-30
            }
        }
        return appRect.width-30
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
