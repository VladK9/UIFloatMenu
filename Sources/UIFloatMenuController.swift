//
//  UIFloatMenuController.swift
//  UIFloatMenu
//

import UIKit
import Foundation

class UIFloatMenuController: UIViewController, UIGestureRecognizerDelegate {
    
    fileprivate var currentVC = UIViewController()
    
    private var queue = [UIFloatMenuQueue]()
    
    public var header = UIFloatMenuHeaderConfig()
    public var config = UIFloatMenuConfig()
    public var actions = [UIFloatMenuAction]()
    
    public var delegate = Delegates()
    
    lazy private var backgroundView = UIView()
    
    public var isHomeIndicatorVisible = true {
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
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundView)
        backgroundView.frame = view.frame
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapClose))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        backgroundView.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(tapClose), name: NSNotification.Name(rawValue: "UIFloatMenuClose"), object: nil)
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
                    self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
                }
            } else {
                self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            }
        }
        
        queue.append(.init(uuid: UIFloatMenuID.backViewID, config: config, actions: actions))
        
        let menu = UIFloatMenu.self
        
        menu.currentVC = currentVC
        menu.headerConfig = header
        menu.viewConfig = config
        menu.delegate.close = delegate.close
        menu.delegate.textField = delegate.textField
        menu.show(self, actions: actions)
    }
    
    // MARK: - prefersHomeIndicatorAutoHidden
    open override var prefersHomeIndicatorAutoHidden: Bool {
        return !isHomeIndicatorVisible
    }
    
    // MARK: - show
    func show(_ vc: UIViewController) {
        currentVC = vc
        vc.present(self, animated: false)
    }
    
    // MARK: - tapClose
    @objc private func tapClose() {
        view.endEditing(true)
        UIView.animate(withDuration: 0.2) {
            self.backgroundView.backgroundColor = .clear
        }
        
        UIFloatMenu.closeMenu(completion: {
            self.dismiss(animated: false, completion: nil)
        })
        
        if delegate.close != nil {
            delegate.close?.UIFloatMenuDidCloseMenu()
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
                backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            }
        } else {
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        }
        
        if traitCollection.horizontalSizeClass == .compact {
            let device = UIDevice.current.userInterfaceIdiom
            let menu = UIFloatMenu.self
            
            if let menuView = self.view.viewWithTag(UIFloatMenuID.backViewID) {
                if device == .pad {
                    let last = (queue.last?.config.presentation)!
                    if case .rightDown(_) = last {
                        menu.showTo(menuView, positions: .default)
                    } else if case .rightUp(_) = last {
                        menu.showTo(menuView, positions: .default, animation: false)
                    } else if case .leftUp(_) = last {
                        menu.showTo(menuView, positions: .default)
                    } else if case .leftDown(_) = last {
                        menu.showTo(menuView, positions: .default)
                    } else if case .default = last {
                        menu.showTo(menuView, positions: .default, animation: false)
                    } else {
                        menu.showTo(menuView, positions: last, iPad_window_width: 0)
                    }
                } else {
                    let last = (queue.last?.config.presentation)!
                    if case .rightDown(_) = last {
                        menu.showTo(menuView, positions: .default)
                    } else if case .rightUp(_) = last {
                        menu.showTo(menuView, positions: .default)
                    } else if case .leftUp(_) = last {
                        menu.showTo(menuView, positions: .default)
                    } else if case .leftDown(_) = last {
                        menu.showTo(menuView, positions: .default)
                    } else if case .default = last {
                        menu.showTo(menuView, positions: .default)
                    } else {
                        menu.showTo(menuView, positions: last, iPad_window_width: 0)
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
            if let menuView = self.view.viewWithTag(UIFloatMenuID.backViewID) {
                if device == .pad {
                    let layout = Layout.determineLayout()
                    
                    let last = (self.queue.last?.config.presentation)!
                    let position: UIFloatMenuPresentStyle!
                    
                    if case .default = last {
                        position = .default
                        for gesture in menuView.gestureRecognizers! {
                            gesture.isEnabled = true
                        }
                    } else if case .center = last {
                        position = .center
                        for gesture in menuView.gestureRecognizers! {
                            gesture.isEnabled = false
                        }
                    } else {
                        if layout == .iPadOneThirdScreen {
                            position = .default
                            for gesture in menuView.gestureRecognizers! {
                                gesture.isEnabled = true
                            }
                        } else if layout == .iPadHalfScreen{
                            position = last
                            for gesture in menuView.gestureRecognizers! {
                                gesture.isEnabled = false
                            }
                        } else if layout == .iPadTwoThirdScreen {
                            position = last
                            for gesture in menuView.gestureRecognizers! {
                                gesture.isEnabled = false
                            }
                        } else {
                            position = last
                            for gesture in menuView.gestureRecognizers! {
                                gesture.isEnabled = false
                            }
                        }
                    }
                    menu.showTo(menuView, positions: position, iPad_window_width: 0, animation: false)
                } else if device == .phone {
                    if Orientation.isLandscape {
                        menuView.center = self.view.center
                    } else {
                        menu.showTo(menuView, positions: UIFloatMenuHelper.correctPosition((self.queue.last?.config.presentation)!))
                    }
                }
            }
        })
    }
    
}
