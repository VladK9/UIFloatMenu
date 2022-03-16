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
    
    static public var currentVC = UIViewController()
    
    // Config
    static public var viewConfig = UIFloatMenuConfig()
    static public var headerConfig = UIFloatMenuHeaderConfig()
    
    // Delegate
    static public var delegate = Delegates()
    
    // KeyboardHelper
    static private var keyboardHelper: KeyboardHelper?
    
    // Max view to show
    static private var maxView: Int = 3
    
    // Animation duration
    static private var animationDuration: TimeInterval = 0.3
    
    // Queue
    static private var queue = [UIFloatMenuQueue]()
    
    //MARK: - Show
    static func show(_ vc: UIViewController, actions: [UIFloatMenuAction]) {
        if queue.count <= maxView {
            let correct = UIFloatMenuHelper.correctPosition(viewConfig.presentation)
            let id = UIFloatMenuID.genUUID(queue.count)
            
            let menuView = UIFloatMenuView.init(items: actions, vc: currentVC, header: headerConfig, config: viewConfig, delegate: delegate)
            menuView.tag = id
            
            vc.view.addSubview(menuView)
            
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
    }
    
    // MARK: - closeMenu()
    static private func closeMenu(_ menuView: UIView) {
        let correct = UIFloatMenuHelper.correctPosition(viewConfig.presentation)
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
            let animator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 1.0) {
                menuView.alpha = 1
            }
            animator.startAnimation()
            break
        case .default:
            if iPad_window_width != 0 {
                menuView.center.x = appRect.width/2
            } else {
                if animation {
                    menuView.center = CGPoint(x: appRect.width/2, y: getPrepare)
                    let animator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 1.0) {
                        menuView.center.y = getShow
                    }
                    animator.startAnimation()
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
                let animator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 1.0) {
                    menuView.alpha = 1
                }
                animator.startAnimation()
            }
            break
        case .leftDown(let overToolBar):
            let space: CGFloat = overToolBar ? 0 : 44
            menuView.center = CGPoint(x: (menuView.frame.size.width/2)+10, y: appRect.height-(menuView.frame.size.height/2)-10-space)
            
            if animation {
                menuView.alpha = 0
                let animator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 1.0) {
                    menuView.alpha = 1
                }
                animator.startAnimation()
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
                    let animator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 1.0) {
                        menuView.alpha = 1
                    }
                    animator.startAnimation()
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
                    let animator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 1.0) {
                        menuView.alpha = 1
                    }
                    animator.startAnimation()
                }
            }
            break
        }
    }
    
}
