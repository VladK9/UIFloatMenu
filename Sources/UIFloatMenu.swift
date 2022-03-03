//
//  UIFloatMenu.swift
//  UIFloatMenu
//

import UIKit

class UIFloatMenu {
    
    let shared = UIFloatMenu()
    
    static public func setup(actions: [UIFloatMenuAction]) -> UIFloatMenuController {
        let vc = UIFloatMenuController()
        vc.actions = actions
        return vc
    }
    
    static private var initY = [CGFloat]()
    
    static public var currentVC = UIViewController()
    
    static public var viewConfig = UIFloatMenuConfig()
    static public var headerConfig = UIFloatMenuHeaderConfig()
    
    static private var keyboardHelper: KeyboardHelper?
    
    //MARK: - Config
    // Max view to show
    static private var maxView: Int = 3
    
    // Animation duration
    static private var animationDuration: TimeInterval = 0.3
    
    // Delegate
    static var closeDelegate: UIFloatMenuCloseDelegate?
    static var textFieldDelegate: UIFloatMenuTextFieldDelegate?
    
    // Queue
    static private var queue = [UIFloatMenuQueue]()
    
    //MARK: - Show
    static func show(_ vc: UIViewController, actions: [UIFloatMenuAction]) {
        if queue.count <= maxView {
            let correct = correctPosition(viewConfig.presentation)
            let id = UIFloatMenuID.genUUID(queue.count)
            
            let menuView = UIFloatMenuView.init(items: actions, vc: currentVC, header: headerConfig, config: viewConfig,
                                                closeDelegate: closeDelegate, textFieldDelegate: textFieldDelegate)
            menuView.tag = id
            
            vc.view.addSubview(menuView)
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(UIFloatMenuDrag(_:)))
            pan.maximumNumberOfTouches = 1
            pan.cancelsTouchesInView = true
            menuView.addGestureRecognizer(pan)
            
            if case .default = correct {
                for gesture in menuView.gestureRecognizers! {
                    gesture.isEnabled = true
                }
            } else {
                for gesture in menuView.gestureRecognizers! {
                    gesture.isEnabled = false
                }
            }
            
            let customConfig = UIFloatMenuConfig(cornerRadius: viewConfig.cornerRadius, blurBackground: viewConfig.blurBackground,
                                                 viewWidth_iPad: viewConfig.viewWidth_iPad)
            
            queue.append(.init(uuid: id, viewHeight: menuView.bounds.height, config: customConfig, actions: actions))
            currentVC = vc
            
            keyboardHelper = KeyboardHelper { animation, keyboardFrame, duration in
                switch animation {
                case .keyboardWillShow:
                    let yValue = (menuView.frame.size.height/2.2)-(UIFloatMenuHelper.getPadding(.bottom)*2.4)
                    menuView.transform = CGAffineTransform(translationX: 0, y: -yValue)
                case .keyboardWillHide:
                    menuView.transform = .identity
                }
            }
            
            showTo(menuView, positions: correct)
            
            initY.append(menuView.frame.origin.y)
        } else {
            print("Max view count")
        }
    }
    
    //MARK: - closeMenu
    static public func closeMenu(slideAnimation: Bool = true, completion: @escaping () -> Void) {
        if let UIFloatMenu = currentVC.view.viewWithTag(UIFloatMenuID.backViewID) {
            UIView.animate(withDuration: 0.2, animations: {
                closeMenu(UIFloatMenu)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    completion()
                }
            }, completion: { (finished: Bool) in
                UIFloatMenu.removeFromSuperview()
            })
        }
        
        queue.removeAll()
        initY.removeAll()
    }
    
    //MARK: - UIFloatMenuDrag
    @objc static private func UIFloatMenuDrag(_ sender: UIPanGestureRecognizer) {
        let appRect = UIApplication.shared.windows[0].bounds
        let topPadding = UIFloatMenuHelper.getPadding(.top)
        let bottomPadding = UIFloatMenuHelper.getPadding(.bottom)
        
        let screen = topPadding + appRect.height + bottomPadding
        
        var dismissDragSize: CGFloat {
            return bottomPadding.isZero ? screen - (topPadding*4.5) : screen - (bottomPadding*4)
        }
        
        switch sender.state {
        case .began:
            break
        case .changed:
            panChanged(sender)
        case .ended, .cancelled:
            panEnded(sender, dismissDragSize: dismissDragSize)
        case .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - panChanged()
    static private func panChanged(_ gesture: UIPanGestureRecognizer) {
        let view = gesture.view!
        let translation = gesture.translation(in: gesture.view)
        let velocity = gesture.velocity(in: gesture.view)
        
        var translationAmount = translation.y >= 0 ? translation.y : -pow(abs(translation.y), 0.7)
        
        let rubberBanding = true
        
        if !rubberBanding && translationAmount < 0 { translationAmount = 0 }
        
        if gesture.direction(in: view) == .Up && gesture.view!.frame.origin.y < initY.last! {
            if let UIFloatMenu = currentVC.view.viewWithTag(queue.last!.uuid!) {
                let backTranslationAmount = translation.y >= 0 ? translation.y : -pow(abs(translation.y), 0.6)
                UIFloatMenu.transform = CGAffineTransform(translationX: 0, y: backTranslationAmount)
            }
        }
        
        if gesture.direction(in: view) == .Down {
            for order in 0..<queue.count-1 {
                if let UIFloatMenu = currentVC.view.viewWithTag(queue[order].uuid) {
                    if velocity.y > 180 {
                        UIView.animate(withDuration: 0.2, animations: {
                            UIFloatMenu.transform = .identity
                        })
                    } else {
                        if UIFloatMenu.frame.origin.y <= initY[order] {
                            let backTranslationAmount = translation.y >= 0 ? translation.y : -pow(abs(translation.y), 0.6)
                            UIFloatMenu.transform = CGAffineTransform(translationX: 0, y: backTranslationAmount)
                        }
                    }
                }
            }
        }
        
        view.transform = CGAffineTransform(translationX: 0, y: translationAmount)
    }
    
    // MARK: - panEnded()
    static private func panEnded(_ gesture: UIPanGestureRecognizer, dismissDragSize: CGFloat) {
        let velocity = gesture.velocity(in: gesture.view).y
        if ((gesture.view!.frame.origin.y+40) >= dismissDragSize) || (velocity > 180) {
            NotificationCenter.default.post(name: NSNotification.Name("UIFloatMenuClose"), object: nil)
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                if let UIFloatMenu = currentVC.view.viewWithTag(queue.last!.uuid!) {
                    UIFloatMenu.transform = .identity
                }
            })
        }
    }
    
    // MARK: - correctPosition()
    static public func correctPosition(_ position: UIFloatMenuPresentStyle) -> UIFloatMenuPresentStyle {
        let device = UIDevice.current.userInterfaceIdiom
        
        if device == .pad {
            let layout = Layout.determineLayout()
            
            if layout == .iPadOneThirdScreen {
                if case .center = position {
                    return .center
                }
                return .default
            }
            return position
        } else if device == .phone {
            if case .center = position {
                return .center
            }
            return .default
        } else {
            return position
        }
    }
    
    // MARK: - closeMenu()
    static private func closeMenu(_ menuView: UIView) {
        let correct = correctPosition(viewConfig.presentation)
        let appRect = UIApplication.shared.windows[0].bounds
        let topPadding = UIFloatMenuHelper.getPadding(.top)
        
        var getClose: CGFloat {
            return appRect.height + queue[0].viewHeight + (topPadding)
        }
        
        switch correct {
        case .default:
            menuView.layer.position.y = getClose
        case .center:
            menuView.alpha = 0
        case .leftDown:
            menuView.alpha = 0
            break
        case .leftUp:
            menuView.alpha = 0
            break
        case .rightUp:
            menuView.alpha = 0
            break
        case .rightDown:
            menuView.alpha = 0
            break
        }
    }
    
    // MARK: - showTo()
    static public func showTo(_ menuView: UIView, positions: UIFloatMenuPresentStyle, iPad_window_width: CGFloat = 0, animation: Bool = true) {
        let appRect = (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds)!
        let topPadding = UIFloatMenuHelper.getPadding(.top)
        let bottomPadding = UIFloatMenuHelper.getPadding(.bottom)
        
        var bottomSpace: CGFloat {
            return bottomPadding.isZero ? 15 : 30
        }
        
        var getPrepare: CGFloat {
            return appRect.height + bottomPadding + topPadding + menuView.bounds.height
        }
        
        var getShow: CGFloat {
            let lastHeight = menuView.bounds.height
            return appRect.height-lastHeight-bottomSpace+(lastHeight/2)
        }
        
        switch positions {
        case .center:
            if iPad_window_width != 0 {
                menuView.center = CGPoint(x: iPad_window_width/2, y: appRect.height/2)
            } else {
                menuView.center = CGPoint(x: appRect.width/2, y: appRect.height/2)
            }
            
            menuView.alpha = 0
            UIView.animate(withDuration: animationDuration, animations: {
                menuView.alpha = 1
            })
            break
        case .default:
            if iPad_window_width != 0 {
                menuView.center.x = appRect.width/2
            } else {
                if animation {
                    menuView.center = CGPoint(x: appRect.width/2, y: getPrepare)
                    
                    UIView.animate(withDuration: animationDuration, delay: 0, options: .transitionCurlUp, animations: {
                        menuView.center.y = getShow
                    })
                } else {
                    menuView.center = CGPoint(x: appRect.width/2, y: getShow)
                }
            }
            break
        case .leftUp(let overNavBar):
            let space: CGFloat = overNavBar ? 5 : 44
            menuView.center = CGPoint(x: (menuView.frame.size.width/2)+10, y: (menuView.frame.size.height/2)+topPadding+space)
            
            if animation {
                menuView.alpha = 0
                UIView.animate(withDuration: animationDuration, animations: {
                    menuView.alpha = 1
                })
            }
            break
        case .leftDown(let overToolBar):
            let space: CGFloat = overToolBar ? 0 : 44
            menuView.center = CGPoint(x: (menuView.frame.size.width/2)+10, y: appRect.height-(menuView.frame.size.height/2)-10-space)
            
            if animation {
                menuView.alpha = 0
                UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
                    menuView.alpha = 1
                })
            }
            break
        case .rightUp(let overNavBar):
            let space: CGFloat = overNavBar ? 5 : 44
            if iPad_window_width != 0 {
                menuView.center = CGPoint(x: iPad_window_width-(menuView.frame.size.width/2)-10, y: (menuView.frame.size.height/2)+topPadding+space)
            } else {
                menuView.center = CGPoint(x: appRect.width-(menuView.frame.size.width/2)-10, y: (menuView.frame.size.height/2)+topPadding+space)
                
                if animation {
                    menuView.alpha = 0
                    UIView.animate(withDuration: animationDuration, animations: {
                        menuView.alpha = 1
                    })
                }
            }
            break
        case .rightDown(let overToolBar):
            if iPad_window_width != 0 {
                menuView.center.x = iPad_window_width-(menuView.frame.size.width/2)-10
            } else {
                let space: CGFloat = overToolBar ? 0 : 44
                menuView.center = CGPoint(x: appRect.width-(menuView.frame.size.width/2)-10, y: appRect.height-(menuView.frame.size.height/2)-10-space)
                
                if animation {
                    menuView.alpha = 0
                    UIView.animate(withDuration: animationDuration, animations: {
                        menuView.alpha = 1
                    })
                }
            }
            break
        }
    }
    
}
