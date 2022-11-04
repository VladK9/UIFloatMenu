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
    
    static private var containerView = ContainerView()
    
    static private var container_VC = UIViewController()
    static private var source_VC = UIViewController()
    
    // Config
    static private var viewConfig = UIFloatMenuConfig()
    static private var headerConfig = UIFloatMenuHeaderConfig()
    
    // Delegate
    static private var delegate = Delegates()
    
    // KeyboardHelper
    static private var keyboardHelper: KeyboardHelper?
    
    // Animation duration
    static private var animationDuration: TimeInterval = 0.4
    static private var animationDurationNext: TimeInterval = 0.3
    
    // Queue
    static public var queue = [UIFloatMenuQueue]()
    
    //MARK: - Show
    static func show(container_VC: UIViewController, source_VC: UIViewController,
                     headerConfig: UIFloatMenuHeaderConfig, viewConfig: UIFloatMenuConfig,
                     delegate: Delegates,
                     actions: [UIFloatMenuAction]) {
        self.viewConfig = viewConfig
        self.headerConfig = headerConfig
        self.delegate = delegate
        
        let correct = UIFloatMenuHelper.correctPosition(viewConfig.presentation)
        let id = UIFloatMenuID.genUUID(queue.count)
        let menuView = UIFloatMenuView.init(items: actions, vc: source_VC, header: headerConfig, config: viewConfig, delegate: delegate)
        menuView.tag = id
        
        container_VC.view.addSubview(menuView)
        
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
                                             presentation: viewConfig.presentation,
                                             viewWidth_iPad: viewConfig.viewWidth_iPad)
        
        queue.append(.init(uuid: id, viewHeight: menuView.bounds.height,
                           header: headerConfig, config: customConfig,
                           actions: actions))
        self.container_VC = container_VC
        self.source_VC = source_VC
        
        keyboardHelper = KeyboardHelper { animation, keyboardFrame, _ in
            switch animation {
            case .keyboardWillShow:
                var y: CGFloat {
                    if case .center = correct {
                        return (menuView.frame.size.height/2.2)-(UIFloatMenuHelper.getPadding(.bottom)*2.4)
                    } else if case .default = correct {
                        return keyboardFrame.height
                    }
                    return 0
                }
                
                UIView.animate(withDuration: animationDuration, animations: {
                    menuView.transform = CGAffineTransform(translationX: 0, y: -y)
                })
            case .keyboardWillHide:
                menuView.transform = .identity
            }
        }
        
        showTo(menuView, positions: correct)
    }
    
    //MARK: - closeMenu
    static public func closeMenu(slideAnimation: Bool = true, completion: @escaping () -> Void) {
        for index in 0..<queue.count {
            if let UIFloatMenu = container_VC.view.viewWithTag(queue[index].uuid) {
                let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1.0) {
                    closeMenu(UIFloatMenu)
                }
                animator.addCompletion({ _ in
                    UIFloatMenu.removeFromSuperview()
                    completion()
                })
                animator.startAnimation()
            }
        }

        queue.removeAll()
    }
    
    // MARK: - closeMenu()
    static private func closeMenu(_ menuView: UIView) {
        let correct = UIFloatMenuHelper.correctPosition((queue.last?.config.presentation)!)
        let appRect = UIApplication.shared.windows[0].bounds
        let topPadding = UIFloatMenuHelper.getPadding(.top)
        let bottomPadding = UIFloatMenuHelper.getPadding(.bottom)
        
        var getClose: CGFloat {
            return appRect.height + topPadding + bottomPadding + menuView.bounds.height
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
    static public func showTo(_ menuView: UIView, positions: UIFloatMenuPresentStyle, iPad_window_width: CGFloat = 0, animation: transition_style = .default()) {
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
            
            if case .default(let animated) = animation {
                if animated {
                    menuView.alpha = 0
                    let animator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 1.0) {
                        menuView.alpha = 1
                    }
                    animator.startAnimation()
                }
            }
            break
        case .default:
            if iPad_window_width != 0 {
                menuView.center.x = appRect.width/2
            } else {
                if case .default(let animated) = animation {
                    if animated {
                        menuView.center = CGPoint(x: appRect.width/2, y: getPrepare)
                        let animator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 1.0) {
                            menuView.center.y = getShow
                        }
                        animator.startAnimation()
                    } else {
                        menuView.center = CGPoint(x: appRect.width/2, y: getShow)
                    }
                } else {
                    menuView.center = CGPoint(x: appRect.width/2, y: getShow)
                }
            }
            break
        case .leftUp(let overNavBar):
            let space: CGFloat = overNavBar ? 5 : 44
            menuView.center = CGPoint(x: (menuView.frame.size.width/2)+10, y: (menuView.frame.size.height/2)+topPadding+space)
            
            if case .default(let animated) = animation {
                if animated {
                    menuView.alpha = 0
                    let animator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 1.0) {
                        menuView.alpha = 1
                    }
                    animator.startAnimation()
                }
            }
            break
        case .leftDown(let overToolBar):
            let space: CGFloat = overToolBar ? 0 : 44
            menuView.center = CGPoint(x: (menuView.frame.size.width/2)+10, y: appRect.height-(menuView.frame.size.height/2)-10-space)
            
            if case .default(let animated) = animation {
                if animated {
                    menuView.alpha = 0
                    let animator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 1.0) {
                        menuView.alpha = 1
                    }
                    animator.startAnimation()
                }
            }
            break
        case .rightUp(let overNavBar):
            let space: CGFloat = overNavBar ? 5 : 44
            if iPad_window_width != 0 {
                menuView.center = CGPoint(x: iPad_window_width-(menuView.frame.size.width/2)-10, y: (menuView.frame.size.height/2)+topPadding+space)
            } else {
                menuView.center = CGPoint(x: appRect.width-(menuView.frame.size.width/2)-10, y: (menuView.frame.size.height/2)+topPadding+space)
                
                if case .default(let animated) = animation {
                    if animated {
                        menuView.alpha = 0
                        let animator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 1.0) {
                            menuView.alpha = 1
                        }
                        animator.startAnimation()
                    }
                }
            }
            break
        case .rightDown(let overToolBar):
            if iPad_window_width != 0 {
                menuView.center.x = iPad_window_width-(menuView.frame.size.width/2)-10
            } else {
                let space: CGFloat = overToolBar ? 0 : 44
                menuView.center = CGPoint(x: appRect.width-(menuView.frame.size.width/2)-10, y: appRect.height-(menuView.frame.size.height/2)-10-space)
                
                if case .default(let animated) = animation {
                    if animated {
                        menuView.alpha = 0
                        let animator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 1.0) {
                            menuView.alpha = 1
                        }
                        animator.startAnimation()
                    }
                }
            }
            break
        }
    }
    
    // MARK: - showNext()
    /**
    UIFloatMenu: showNext
     
     ```
     let header = UIFloatMenuHeaderConfig(title: "Title", showLine: true)
     UIFloatMenu.showNext(actions: [actions], presentation: .default, header: UIFloatMenuHeaderConfig)
     ```
    
    - Parameter actions: Actions. **[UIFloatMenuAction]**
    - Parameter presentation: Present style. **UIFloatMenuPresentStyle**
    - Parameter header: Header config. **UIFloatMenuHeaderConfig**
    */
    static public func showNext(actions: [UIFloatMenuAction], presentation: UIFloatMenuPresentStyle, header: UIFloatMenuHeaderConfig) {
        let correct = UIFloatMenuHelper.correctPosition(presentation)
        let id = UIFloatMenuID.genUUID(queue.count)
        let custom_Header_Config = UIFloatMenuHeaderConfig(showHeader: true, title: header.title, subtitle: header.subtitle,
                                                           showLine: header.showLine, lineInset: header.lineInset)
        
        let menuView = UIFloatMenuView.init(items: actions, vc: source_VC, header: custom_Header_Config, config: viewConfig, delegate: delegate)
        menuView.tag = id
        menuView.isHidden = true
        
        container_VC.view.addSubview(menuView)
        
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
                                             presentation: presentation, viewWidth_iPad: viewConfig.viewWidth_iPad)
        
        keyboardHelper = KeyboardHelper { animation, keyboardFrame, _ in
            switch animation {
            case .keyboardWillShow:
                var y: CGFloat {
                    if case .center = presentation {
                        return (menuView.frame.size.height/2.2)-(UIFloatMenuHelper.getPadding(.bottom)*2.4)
                    } else if case .default = presentation {
                        return keyboardFrame.height
                    }
                    return 0
                }
                
                UIView.animate(withDuration: animationDuration, animations: {
                    menuView.transform = CGAffineTransform(translationX: 0, y: -y)
                })
            case .keyboardWillHide:
                menuView.transform = .identity
            }
        }
        
        var originView: UIView {
            if let origin = container_VC.view.viewWithTag((queue.last?.uuid)!) {
                return origin
            }
            return UIView()
        }
        
        var newView: UIView {
            if let new = container_VC.view.viewWithTag(id) {
                //new.isHidden = true
                return new
            }
            return UIView()
        }

        showTo(newView, positions: correct, iPad_window_width: 0, animation: .fade)
        
        let animator = UIViewPropertyAnimator(duration: animationDurationNext, dampingRatio: 1) {
            originView.isHidden = true
            menuView.isHidden = false
        }
        animator.addMovingAnimation(from: originView, to: newView, sourceView: newView, in: originView)
        animator.startAnimation()
        
        queue.append(.init(uuid: id, viewHeight: menuView.bounds.height, header: custom_Header_Config, config: customConfig, actions: actions))
    }
    
    // MARK: - showPrev()
    /**
    UIFloatMenu: showPrevious
     
    ```
    UIFloatMenu.showPrevious()
    ```
    */
    static public func showPrevious() {
        if queue.count > 1 {
            let previous_id = queue[queue.count-2].uuid!
            let correct = UIFloatMenuHelper.correctPosition(queue[queue.count-2].config.presentation)
            
            var lastView: UIView {
                if let origin = container_VC.view.viewWithTag((queue.last?.uuid)!) {
                    return origin
                }
                return UIView()
            }
            var previousView: UIView {
                if let previous = container_VC.view.viewWithTag(previous_id) {
                    return previous
                }
                return UIView()
            }
            
            let animator = UIViewPropertyAnimator(duration: animationDurationNext, dampingRatio: 1) {
                previousView.isHidden = false
                lastView.isHidden = true
            }
            
            animator.addMovingAnimation(from: lastView, to: previousView, sourceView: previousView, in: previousView)
            animator.addCompletion({ _ in
                showTo(containerView, positions: correct, animation: .fade)
                lastView.removeFromSuperview()
                queue.removeLast()
            })
            animator.startAnimation()
        }
    }
    
}
