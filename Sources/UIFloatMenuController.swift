//
//  UIFloatMenuController.swift
//  UIFloatMenu
//

import UIKit
import Foundation

class UIFloatMenuController: UIViewController, UIGestureRecognizerDelegate {
    
    private var currentVC = UIViewController()
    
    public var header = UIFloatMenuHeaderConfig()
    public var config = UIFloatMenuConfig()
    public var actions = [UIFloatMenuAction]()
    
    public var customView: UIView?
    
    public var delegate = Delegates()
    
    private var backgroundView = UIView()
    
    public var hideHomeIndicator = false {
        didSet {
            setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
    }
    
    //MARK: - init
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    //MARK: - coder
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - deinit
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UIFloatMenuClose"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UIFloatMenuClose_all"), object: nil)
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundView)
        backgroundView.frame = view.frame
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapClose_background))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        backgroundView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(tapClose_background),
                                               name: NSNotification.Name(rawValue: "UIFloatMenuClose_all"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tapClose(_:)),
                                               name: NSNotification.Name(rawValue: "UIFloatMenuClose"), object: nil)
    }
    
    // MARK: - viewDidAppear
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) {
            if #available(iOS 13.0, *) {
                let userInterfaceStyle = self.traitCollection.userInterfaceStyle
                if userInterfaceStyle == .dark {
                    self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.02)
                } else {
                    self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                }
            } else {
                self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            }
        }
        
        let menu = UIFloatMenu.self
        menu.show(container_VC: self, source_VC: currentVC, headerConfig: header, viewConfig: config, delegate: delegate,
                  actions: actions, customView: customView)
    }
    
    // MARK: - prefersHomeIndicatorAutoHidden
    open override var prefersHomeIndicatorAutoHidden: Bool {
        return hideHomeIndicator
    }
    
    // MARK: - show
    func show(_ vc: UIViewController) {
        currentVC = vc
        vc.present(self, animated: false)
    }
    
    // MARK: - tapClose_background
    @objc private func tapClose_background() {
        if !UIFloatMenu.displayActivityIndicator {
            view.endEditing(true)
            UIView.animate(withDuration: 0.2) {
                self.backgroundView.backgroundColor = .clear
            }
            
            UIFloatMenu.closeMenu(completion: {
                self.dismiss(animated: false)
            })
            
            if delegate.close != nil {
                delegate.close?.UIFloatMenuDidCloseMenu()
            }
        }
    }
    
    // MARK: - tapClose
    @objc private func tapClose(_ notification: NSNotification) {
        if UIFloatMenu.queue_pub.count > 1 {
            UIFloatMenu.showPrevious()
        } else {
            view.endEditing(true)
            UIView.animate(withDuration: 0.2) {
                self.backgroundView.backgroundColor = .clear
            }
            
            UIFloatMenu.closeMenu(completion: {
                self.dismiss(animated: false)
                if let row = notification.userInfo?["row"] as? UIFloatMenuAction {
                    row.action!(row)
                }
            })
            
            if delegate.close != nil {
                delegate.close?.UIFloatMenuDidCloseMenu()
            }
        }
    }
    
    // MARK: - detect theme changes and windows resize
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            if userInterfaceStyle == .dark {
                backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.02)
            } else {
                backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            }
        } else {
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        }
        
        if traitCollection.horizontalSizeClass == .compact {
            let device = UIDevice.current.userInterfaceIdiom
            let menu = UIFloatMenu.self
            
            if let containerView = self.view.viewWithTag(UIFloatMenuID.containerViewID) {
                if device == .pad {
                    let presentation = (UIFloatMenu.queue_pub.last?.config.presentation)!
                    
                    if case .rightDown(_) = presentation {
                        menu.showTo(containerView, position: .default, animation: .default(animated: false))
                    } else if case .rightUp(_) = presentation {
                        menu.showTo(containerView, position: .default, animation: .default(animated: false))
                    } else if case .leftUp(_) = presentation {
                        menu.showTo(containerView, position: .default, animation: .default(animated: false))
                    } else if case .leftDown(_) = presentation {
                        menu.showTo(containerView, position: .default, animation: .default(animated: false))
                    } else if case .default = presentation {
                        menu.showTo(containerView, position: .default, animation: .default(animated: false))
                    } else {
                        menu.showTo(containerView, position: presentation, iPad_window_width: 0)
                    }
                } else {
                    let presentation = (UIFloatMenu.queue_pub.last?.config.presentation)!
                    if case .rightDown(_) = presentation {
                        menu.showTo(containerView, position: .default, animation: .default(animated: false))
                    } else if case .rightUp(_) = presentation {
                        menu.showTo(containerView, position: .default, animation: .default(animated: false))
                    } else if case .leftUp(_) = presentation {
                        menu.showTo(containerView, position: .default, animation: .default(animated: false))
                    } else if case .leftDown(_) = presentation {
                        menu.showTo(containerView, position: .default, animation: .default(animated: false))
                    } else if case .default = presentation {
                        menu.showTo(containerView, position: .default, animation: .default(animated: false))
                    } else {
                        menu.showTo(containerView, position: presentation, iPad_window_width: 0)
                    }
                }
            }
        }
    }
    
    // MARK: - detect device rotations
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        UIView.animate(withDuration: 0.01) {
            self.backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        
        let device = UIDevice.current.userInterfaceIdiom
        let menu = UIFloatMenu.self
        coordinator.animate(alongsideTransition: { (context) in
            if let containerView = self.view.viewWithTag(UIFloatMenuID.containerViewID) {
                for index in 0..<UIFloatMenu.queue_pub.count {
                    if let menuView = containerView.viewWithTag(UIFloatMenu.queue_pub[index].uuid) {
                        menuView.layoutSubviews()
                        menuView.frame.origin = CGPoint(x: 0, y: 0)
                        
                        if device == .phone {
                            containerView.frame.size = CGSize(width: menuView.frame.width, height: menuView.frame.height)
                        }
                    }
                }
                
                if let menuView = containerView.viewWithTag((UIFloatMenu.queue_pub.last?.uuid)!) {
                    menuView.gestureIsEnable(true)
                }
                
                let current_presentation = (UIFloatMenu.queue_pub.last?.config.presentation)!
                
                if device == .pad {
                    let position: UIFloatMenuConfig.UIFloatMenuPresentStyle!
                    
                    if case .default = current_presentation {
                        position = .default
                        if let menuView = containerView.viewWithTag((UIFloatMenu.queue_pub.last?.uuid)!) {
                            menuView.gestureIsEnable(true)
                        }
                    } else if case .center = current_presentation {
                        position = .center
                        if let menuView = containerView.viewWithTag((UIFloatMenu.queue_pub.last?.uuid)!) {
                            menuView.gestureIsEnable(false)
                        }
                    } else {
                        let layout = UIFloatMenuHelper.Layout.determineLayout()
                        if layout == .iPadOneThirdScreen {
                            position = .default
                            if let menuView = containerView.viewWithTag((UIFloatMenu.queue_pub.last?.uuid)!) {
                                menuView.gestureIsEnable(true)
                            }
                        } else if layout == .iPadHalfScreen || layout == .iPadTwoThirdScreen {
                            position = current_presentation
                            if let menuView = containerView.viewWithTag((UIFloatMenu.queue_pub.last?.uuid)!) {
                                menuView.gestureIsEnable(false)
                            }
                        } else {
                            position = current_presentation
                            if let menuView = containerView.viewWithTag((UIFloatMenu.queue_pub.last?.uuid)!) {
                                menuView.gestureIsEnable(false)
                            }
                        }
                    }
                    menu.showTo(containerView, position: position, iPad_window_width: 0, animation: .default(animated: false))
                } else if device == .phone {
                    if UIFloatMenuHelper.Orientation.isLandscape {
                        if case .default = current_presentation {
                            menu.showTo(containerView,
                                        position: .default,
                                        animation: .default(animated: false))
                        } else {
                            containerView.center = self.view.center
                        }
                    } else {
                        menu.showTo(containerView,
                                    position: UIFloatMenuHelper.correctPosition((UIFloatMenu.queue_pub.last?.config.presentation)!),
                                    animation: .default(animated: false))
                    }
                }
            }
        })
    }
    
}
