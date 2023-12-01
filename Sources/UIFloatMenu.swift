//
//  UIFloatMenu.swift
//  UIFloatMenu
//

import UIKit

class UIFloatMenu {
    
    //MARK: - UIFloatMenu_viewType
    public enum UIFloatMenu_viewType {
        case actions(_ actions: [UIFloatMenuAction])
        case custom(view: UIView)
    }
    
    let shared = UIFloatMenu()
    
    //MARK: - setup
    static public func setup(type: UIFloatMenu_viewType) -> UIFloatMenuController {
        let vc = UIFloatMenuController()
        switch type {
        case .actions(let actions):
            vc.actions = actions
        case .custom(let view):
            vc.customView = view
        }
        return vc
    }
    
    //MARK: - containerView
    static private var containerView: UIView!
    
    //MARK: - VC's
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
    
    // Display ActivityIndicator
    static public var displayActivityIndicator: Bool = false
    
    // Queue
    static public var queue_pub = [UIFloatMenuQueue]()
    static private var queue = [UIFloatMenuQueue]() {
        didSet {
            self.queue_pub = queue
        }
    }
    
    // MARK: - Show()
    static func show(container_VC: UIViewController, source_VC: UIViewController,
                     headerConfig: UIFloatMenuHeaderConfig, viewConfig: UIFloatMenuConfig,
                     delegate: Delegates,
                     actions: [UIFloatMenuAction],
                     customView: UIView?) {
        self.viewConfig = viewConfig
        self.headerConfig = headerConfig
        self.delegate = delegate
        
        let correct = UIFloatMenuHelper.correctPosition(viewConfig.presentation)
        let id = UIFloatMenuID.genID(queue.count)
        let menuView = UIFloatMenuView.init(items: actions, customView: customView,
                                            vc: source_VC, container: container_VC,
                                            header: headerConfig, config: viewConfig,
                                            delegate: delegate)
        menuView.tag = id
        
        containerView = ContainerView(config: viewConfig)
        containerView.addSubview(menuView)
        
        containerView.frame.size = menuView.frame.size
        menuView.frame.origin = CGPoint(x: 0, y: 0)
        container_VC.view.addSubview(containerView)
        
        if case .default = correct {
            if viewConfig.dragEnable {
                menuView.gestureIsEnable(true)
            } else {
                menuView.gestureIsEnable(false)
            }
        } else {
            menuView.gestureIsEnable(false)
        }
        
        let customConfig = UIFloatMenuConfig(cornerRadius: viewConfig.cornerRadius,
                                             blurBackground: viewConfig.blurBackground,
                                             presentation: viewConfig.presentation,
                                             viewWidth: viewConfig.viewWidth)
        
        queue.append(.init(uuid: id, viewHeight: menuView.bounds.height, header: headerConfig, config: customConfig, actions: actions))
        
        self.container_VC = container_VC
        self.source_VC = source_VC
        
        showTo(containerView, position: correct)
    }
    
    static public func closeAll() {
        NotificationCenter.default.post(name: NSNotification.Name("UIFloatMenuClose_all"), object: nil)
    }
    
    //MARK: - closeMenu
    static public func closeMenu(completion: @escaping () -> Void) {
        if let container = container_VC.view.viewWithTag(UIFloatMenuID.containerViewID) {
            UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, animations: {
                let correct = UIFloatMenuHelper.correctPosition((queue.last?.config.presentation)!)
                
                if case .default = correct {
                    closeMenu(container)
                } else if case .center = correct {
                    closeMenu(container)
                }
            }, completion: { _ in
                for index in 0..<queue.count {
                    if let UIFloatMenu = container.viewWithTag(queue[index].uuid) {
                        UIView.animate(withDuration: animationDuration, animations: {
                            UIFloatMenu.removeFromSuperview()
                        })
                    }
                    
                    if displayActivityIndicator {
                        if let indicatorView = containerView.viewWithTag(UIFloatMenuID.indicatorID) as? UIActivityIndicatorView {
                            indicatorView.removeFromSuperview()
                        }
                        
                        self.displayActivityIndicator = false
                    }
                }
                
                UIView.animate(withDuration: animationDuration, animations: {
                    container.removeFromSuperview()
                }, completion: { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        completion()
                    }
                })
                
                queue.removeAll()
            })
        }
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
    static public func showTo(_ menuView: UIView, position: UIFloatMenuConfig.UIFloatMenuPresentStyle, iPad_window_width: CGFloat = 0, animation: itemSetup.transition_style = .default()) {
        let appRect = (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.bounds)!
        let topPadding = UIFloatMenuHelper.getPadding(.top)
        let bottomPadding = UIFloatMenuHelper.getPadding(.bottom)
        
        var bottomSpace: CGFloat {
            return bottomPadding.isZero ? 15 : 30
        }
        
        var getPrepare: CGFloat {
            return appRect.height + topPadding + bottomPadding + menuView.bounds.height
        }
        
        var getShow: CGFloat {
            let viewHeight = menuView.bounds.height
            return appRect.height-bottomSpace-(viewHeight/2)
        }
        
        switch position {
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
    static public func showNext(type: UIFloatMenu_viewType,
                                viewWidth: CGFloat = 345, dragEnable: Bool = true,
                                header: UIFloatMenuHeaderConfig,
                                presentation: UIFloatMenuConfig.UIFloatMenuPresentStyle) {
        if displayActivityIndicator {
            var indicatorView: UIView {
                if let indicator = containerView.viewWithTag(UIFloatMenuID.indicatorID) {
                    return indicator
                }
                return UIView()
            }
            
            UIView.transition(with: indicatorView, duration: 0.15, animations: {
                indicatorView.alpha = 0
                indicatorView.removeFromSuperview()
                
                self.displayActivityIndicator = false
            })
        }
        
        let correct = UIFloatMenuHelper.correctPosition(presentation)
        let id = UIFloatMenuID.genID(queue.count)
        let custom_Header_Config = UIFloatMenuHeaderConfig(showHeader: true,
                                                           title: header.title, subtitle: header.subtitle,
                                                           showLine: header.showLine,
                                                           showButton: header.showButton,
                                                           lineInset: header.lineInset)
        let custom_View_Config = UIFloatMenuConfig(cornerRadius: viewConfig.cornerRadius,
                                                   blurBackground: viewConfig.blurBackground,
                                                   presentation: viewConfig.presentation, viewWidth: viewWidth)
        
        var menuView: UIView!
        switch type {
        case .actions(let actions):
            menuView = UIFloatMenuView.init(items: actions, vc: source_VC, container: container_VC,
                                                header: custom_Header_Config, config: custom_View_Config, delegate: delegate)
        case .custom(let view):
            menuView = UIFloatMenuView.init(items: [], customView: view,
                                            vc: source_VC, container: container_VC,
                                            header: custom_Header_Config, config: custom_View_Config,
                                            delegate: delegate)
        }
        
        menuView.tag = id
        menuView.alpha = 0
        
        menuView.frame.origin = .zero
        containerView.addSubview(menuView)
        
        if case .default = correct {
            if dragEnable {
                menuView.gestureIsEnable(true)
            } else {
                menuView.gestureIsEnable(false)
            }
        } else {
            menuView.gestureIsEnable(false)
        }
        
        let customConfig = UIFloatMenuConfig(cornerRadius: viewConfig.cornerRadius,
                                             blurBackground: viewConfig.blurBackground,
                                             presentation: presentation, viewWidth: viewConfig.viewWidth)
        
        var originView: UIView {
            if let uiview = container_VC.view.viewWithTag((queue.last?.uuid)!) {
                return uiview
            }
            return UIView()
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, animations: {
            let position = UIFloatMenuHelper.getPosition(menuView, positions: correct)
            
            containerView.frame.size = CGSize(width: menuView.frame.width, height: menuView.frame.height)
            containerView.center = CGPoint(x: position.x, y: position.y)
            
            UIView.transition(with: originView, duration: 0.15, animations: {
                originView.alpha = 0
            })
            UIView.transition(with: menuView, duration: 0.15, animations: {
                menuView.alpha = 1
            })
        }, completion: { _ in
            originView.isHidden = true
            menuView.isHidden = false
        })
        
        switch type {
        case .actions(let actions):
            queue.append(.init(uuid: id, viewHeight: menuView.bounds.height,
                               header: custom_Header_Config,
                               config: customConfig,
                               actions: actions))
        case .custom(_):
            queue.append(.init(uuid: id, viewHeight: menuView.bounds.height,
                               header: custom_Header_Config,
                               config: customConfig,
                               actions: []))
        }
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
                if let uiview = containerView.viewWithTag((queue.last?.uuid)!) {
                    return uiview
                }
                return UIView()
            }
            var previousView: UIView {
                if let uiview = containerView.viewWithTag(previous_id) {
                    return uiview
                }
                return UIView()
            }
            
            if case .default = correct {
                previousView.gestureIsEnable(true)
            } else {
                previousView.gestureIsEnable(false)
            }
            
            containerView.endEditing(true)
            
            UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, animations: {
                let position = UIFloatMenuHelper.getPosition(previousView, positions: correct)
                
                containerView.frame.size = CGSize(width: previousView.frame.width, height: previousView.frame.height)
                containerView.center = CGPoint(x: position.x, y: position.y)
                
                UIView.transition(with: previousView, duration: 0.15, animations: {
                    previousView.alpha = 1
                })
                UIView.transition(with: lastView, duration: 0.15, animations: {
                    lastView.alpha = 0
                })
            }, completion: { _ in
                lastView.isHidden = true
                previousView.isHidden = false
                
                lastView.removeFromSuperview()
                
                queue.removeLast()
            })
        } else {
            self.closeAll()
        }
    }
    
    // MARK: - displayIndicator()
    /**
    UIFloatMenu: displayIndicator
     
    ```
    UIFloatMenu.displayIndicator(text: "Loading...", presentation: .default)
    ```
    
    - Parameter text: Text message.
    - Parameter presentation: Present style. **UIFloatMenuPresentStyle**
    */
    static func displayIndicator(text: String = "", presentation: UIFloatMenuConfig.UIFloatMenuPresentStyle) {
        let correct = UIFloatMenuHelper.correctPosition(presentation)
        
        self.displayActivityIndicator = true
        
        var originView: UIView {
            if let origin = container_VC.view.viewWithTag((queue.last?.uuid)!) {
                return origin
            }
            return UIView()
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, animations: {
            let indicatorView = UIFloatMenuIndicator(text: text, frameSize: CGSize(width: originView.frame.width, height: 200))
            indicatorView.alpha = 0
            
            let position = UIFloatMenuHelper.getPosition(indicatorView, positions: correct)
            
            containerView.frame.size = CGSize(width: indicatorView.frame.width, height: indicatorView.frame.height)
            containerView.center = CGPoint(x: position.x, y: position.y)
            containerView.addSubview(indicatorView)
            
            UIView.transition(with: originView, duration: 0.15, animations: {
                originView.alpha = 0
            }, completion: { _ in
                UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, animations: {
                    indicatorView.alpha = 1
                })
            })
        }, completion: { _ in
            
        })
    }
    
    // MARK: - stopIndicator()
    /**
    UIFloatMenu: Stop indicator and go to previous view
     
    ```
    UIFloatMenu.stopIndicator()
    ```
    */
    static func stopIndicator() {
        var indicatorView: UIView {
            if let indicator = containerView.viewWithTag(UIFloatMenuID.indicatorID) {
                return indicator
            }
            return UIView()
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, animations: {
            indicatorView.alpha = 0
        }, completion: { _ in
            indicatorView.removeFromSuperview()
            
            var lastView: UIView {
                if let uiview = container_VC.view.viewWithTag((queue.last?.uuid)!) {
                    return uiview
                }
                return UIView()
            }
            
            let correct = UIFloatMenuHelper.correctPosition((queue.last?.config.presentation)!)
            
            if case .default = correct {
                lastView.gestureIsEnable(true)
            } else {
                lastView.gestureIsEnable(false)
            }
            
            UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, animations: {
                let position = UIFloatMenuHelper.getPosition(lastView, positions: correct)
                
                containerView.frame.size = CGSize(width: lastView.frame.width, height: lastView.frame.height)
                containerView.center = CGPoint(x: position.x, y: position.y)
                
                UIView.transition(with: lastView, duration: 0.15, animations: {
                    lastView.alpha = 1
                })
            }, completion: { _ in
                lastView.isHidden = false
            })
            
            self.displayActivityIndicator = false
        })
    }
    
}
