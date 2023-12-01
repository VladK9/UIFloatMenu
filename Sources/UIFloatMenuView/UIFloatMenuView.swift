//
//  UIFloatMenuView.swift
//  UIFloatMenu
//

import UIKit

class UIFloatMenuView: UIView, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UIPointerInteractionDelegate {
    
    private var container_VC = UIViewController()
    private var source_VC = UIViewController()
    
    private var customView: UIView?
    
    private var config = UIFloatMenuConfig()
    private var headerConfig = UIFloatMenuHeaderConfig()
    
    private var itemsData = [UIFloatMenuAction]()
    
    private let space: CGFloat = 8
    
    var delegate = Delegates()
    
    //MARK: - tableView
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.allowsMultipleSelection = true
        table.delaysContentTouches = true
        table.tag = UIFloatMenuID.backViewID
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.clipsToBounds = true
        table.showsHorizontalScrollIndicator = false
        table.showsVerticalScrollIndicator = false
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        table.separatorStyle = .none
        table.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: space))
        table.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: space))
        return table
    }()
    
    //MARK: - Lifecycle
    public init(items: [UIFloatMenuAction],
                customView: UIView? = nil,
                vc: UIViewController, container: UIViewController,
                header: UIFloatMenuHeaderConfig,
                config: UIFloatMenuConfig,
                delegate: Delegates) {
        super.init(frame: CGRect.zero)
        
        self.customView = customView
        self.container_VC = container
        self.source_VC = vc
        self.itemsData = items
        self.config = config
        self.headerConfig = header
        self.delegate = delegate
        
        backgroundColor = .clear
        
        let appRect = UIApplication.shared.windows[0].bounds
        
        if customView == nil {
            setupTableView()
            
            addSubview(tableView)
            
            var tableH: CGFloat {
                let height = tableView.contentSizeHeight+(space*2)+(headerConfig.showHeader == true ? 60 : 0)
                return setMaxHeight(height)
            }
            
            var width: CGFloat {
                let device = UIDevice.current.userInterfaceIdiom
                if device == .pad {
                    let layout = UIFloatMenuHelper.Layout.determineLayout()
                    
                    if layout == .iPadHalfScreen {
                        return config.viewWidth
                    } else if layout == .iPadOneThirdScreen {
                        return appRect.width-30
                    } else if layout == .iPadFullScreen {
                        return config.viewWidth
                    } else if layout == .iPadTwoThirdScreen {
                        return config.viewWidth
                    }
                } else {
                    return setMaxWidth(tableView.bounds.width)
                }
                
                return setMaxWidth(tableView.bounds.width)
            }
            
            if headerConfig.showHeader {
                let headerView = UIFloatMenuHeaderView.init(headerConfig: header, menuConfig: config)
                
                addSubview(headerView)
                headerView.frame.origin = CGPoint(x: 0, y: 0)
                headerView.frame.size = CGSize(width: width, height: 60)
                
                tableView.frame = CGRect(x: 0, y: 60, width: width, height: tableH-60)
                frame.size = CGSize(width: width, height: tableH)
                headerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            } else {
                tableView.frame = CGRect(x: 0, y: 0, width: width, height: tableH)
                frame.size = CGSize(width: width, height: tableH)
            }
        } else {
            addSubview(customView!)
            
            var width: CGFloat {
                let device = UIDevice.current.userInterfaceIdiom
                if device == .pad {
                    let layout = UIFloatMenuHelper.Layout.determineLayout()
                    
                    if layout == .iPadHalfScreen {
                        return config.viewWidth
                    } else if layout == .iPadOneThirdScreen {
                        return appRect.width-30
                    } else if layout == .iPadFullScreen {
                        return config.viewWidth
                    } else if layout == .iPadTwoThirdScreen {
                        return config.viewWidth
                    }
                } else {
                    return setMaxWidth(customView.bounds.width)
                }
                
                return setMaxWidth(customView.bounds.width)
            }
            
            if headerConfig.showHeader {
                let headerView = UIFloatMenuHeaderView.init(headerConfig: header, menuConfig: config)
                
                addSubview(headerView)
                headerView.frame.origin = CGPoint(x: 0, y: 0)
                headerView.frame.size = CGSize(width: width, height: 60)
                
                customView!.frame = CGRect(x: 0, y: 60, width: width, height: customView!.frame.height)
                frame.size = CGSize(width: width, height: customView!.frame.height+60)
                headerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            } else {
                customView!.frame = CGRect(x: 0, y: 0, width: width, height: customView!.frame.height)
                frame.size = CGSize(width: width, height: customView!.frame.height)
            }
        }
        
        
        layer.masksToBounds = true
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(UIFloatMenuDrag(_:)))
        pan.maximumNumberOfTouches = 1
        pan.cancelsTouchesInView = true
        pan.delegate = self
        addGestureRecognizer(pan)
    }
    
    //MARK: - coder
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        let appRect = UIApplication.shared.windows[0].bounds
        
        if customView == nil {
            var autoWidth: CGFloat {
                let device = UIDevice.current.userInterfaceIdiom
                if device == .pad {
                    let layout = UIFloatMenuHelper.Layout.determineLayout()
                    
                    if layout == .iPadHalfScreen {
                        return config.viewWidth
                    } else if layout == .iPadOneThirdScreen {
                        return appRect.width-30
                    } else if layout == .iPadFullScreen {
                        return config.viewWidth
                    } else if layout == .iPadTwoThirdScreen {
                        return config.viewWidth
                    }
                } else {
                    return setMaxWidth(tableView.bounds.width)
                }
                
                return setMaxWidth(tableView.bounds.width)
            }
            
            var tableH: CGFloat {
                let height = tableView.contentSizeHeight+(space*2)+(headerConfig.showHeader == true ? 60 : 0)
                return setMaxHeight(height)
            }
            
            if headerConfig.showHeader {
                tableView.frame = CGRect(x: 0, y: 60, width: autoWidth, height: tableH-60)
                frame.size = CGSize(width: autoWidth, height: tableH)
            } else {
                tableView.frame = CGRect(x: 0, y: 0, width: autoWidth, height: tableH)
                frame.size = CGSize(width: autoWidth, height: tableH)
            }
        } else {
            var autoWidth: CGFloat {
                let device = UIDevice.current.userInterfaceIdiom
                if device == .pad {
                    let layout = UIFloatMenuHelper.Layout.determineLayout()
                    
                    if layout == .iPadHalfScreen {
                        return config.viewWidth
                    } else if layout == .iPadOneThirdScreen {
                        return appRect.width-30
                    } else if layout == .iPadFullScreen {
                        return config.viewWidth
                    } else if layout == .iPadTwoThirdScreen {
                        return config.viewWidth
                    }
                } else {
                    return setMaxWidth(customView.bounds.width)
                }
                
                return setMaxWidth(customView.bounds.width)
            }
            
            if headerConfig.showHeader {
                customView!.frame = CGRect(x: 0, y: 60, width: autoWidth, height: customView!.frame.height)
                frame.size = CGSize(width: autoWidth, height: customView!.frame.height+60)
            } else {
                customView!.frame = CGRect(x: 0, y: 0, width: autoWidth, height: customView!.frame.height)
                frame.size = CGSize(width: autoWidth, height: customView!.frame.height)
            }
        }
    }
    
    //MARK: - setupTableView
    internal func setupTableView() {
        tableView.register(UIFloatMenuActionCell.self, forCellReuseIdentifier: "UIFloatMenuActionCell")
        tableView.register(UIFloatMenuInfoCell.self, forCellReuseIdentifier: "UIFloatMenuInfoCell")
        tableView.register(UIFloatMenuTitleCell.self, forCellReuseIdentifier: "UIFloatMenuTitleCell")
        tableView.register(UIFloatMenuSpacerCell.self, forCellReuseIdentifier: "UIFloatMenuSpacerCell")
        tableView.register(UIFloatMenuInputCell.self, forCellReuseIdentifier: "UIFloatMenuInputCell")
        tableView.register(UIFloatMenuSwitchCell.self, forCellReuseIdentifier: "UIFloatMenuSwitchCell")
        tableView.register(UIFloatMenuSegmentCell.self, forCellReuseIdentifier: "UIFloatMenuSegmentCell")
        tableView.register(UIFloatMenuHorizontalCell.self, forCellReuseIdentifier: "UIFloatMenuHorizontalCell")
        tableView.register(UIFloatMenuCustomCell.self, forCellReuseIdentifier: "UIFloatMenuCustomCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        preselectCell()
    }
    
    //MARK: - numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsData.count
    }
    
    //MARK: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = itemsData[indexPath.row]
        
        switch row.item {
        case .ActionCell(let selection, let subtitle, let itemColor, let layout, let height):
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIFloatMenuActionCell", for: indexPath) as! UIFloatMenuActionCell
            
            cell.itemColor = itemColor
            cell.itemLayout = layout
            cell.itemHeight = height
            
            if case .default(let icon, let title) = selection {
                cell.iconImageView.image = icon
                cell.titleLabel.text = title
            } else if case .multi(let isSelected, let selectedIcon, let selectedTitle, let defaultIcon, let defaultTitle) = selection {
                cell.selection = selection
                if isSelected {
                    cell.iconImageView.image = selectedIcon
                    cell.titleLabel.text = selectedTitle
                    cell.isSelected = true
                } else {
                    cell.iconImageView.image = defaultIcon
                    cell.titleLabel.text = defaultTitle
                    cell.isSelected = false
                }
            }
            
            cell.subtitleLabel.text = subtitle
            
            if #available(iOS 13.4, *) {
                cell.addInteraction(UIPointerInteraction(delegate: self))
            }
            
            return cell
        case .InfoCell(let icon, let title, let labelConfig):
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIFloatMenuInfoCell", for: indexPath) as! UIFloatMenuInfoCell
            
            cell.iconImageView.image = icon
            cell.titleLabel.text = title
            if case .config(let fontSize, let fontWeight) = labelConfig {
                cell.titleLabel.font = UIFloatMenuHelper.roundedFont(fontSize: fontSize, weight: fontWeight)
            }
            
            if #available(iOS 13.4, *) {
                cell.addInteraction(UIPointerInteraction(delegate: self))
            }
            
            return cell
        case .Title(let title):
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIFloatMenuTitleCell", for: indexPath) as! UIFloatMenuTitleCell
            cell.titleLabel.text = title
            
            return cell
        case .Spacer(let type):
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIFloatMenuSpacerCell", for: indexPath) as! UIFloatMenuSpacerCell
            cell.spacerType = type
            
            return cell
        case .InputCell(let type, let placeholder, let isResponder, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIFloatMenuInputCell", for: indexPath) as! UIFloatMenuInputCell
            cell.inputType = type
            
            switch type {
            case .textView(let text, let content, let keyboard):
                cell.TextView.text = text
                cell.textLayer.string = placeholder
                cell.TextView.keyboardType = keyboard
                cell.TextView.textContentType = content
                
                if isResponder {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        cell.TextView.becomeFirstResponder()
                    }
                }
            case .textField(let text, let isSecure, let content, let keyboard):
                cell.TextField.text = text
                cell.TextField.placeholder = placeholder

                cell.TextField.isSecureTextEntry = isSecure
                cell.TextField.textContentType = content
                cell.TextField.keyboardType = keyboard
                
                if isResponder {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        cell.TextField.becomeFirstResponder()
                    }
                }
            }
            
            return cell
        case .SwitchCell(let icon, let title, let isOn, let tintColor, let action):
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIFloatMenuSwitchCell", for: indexPath) as! UIFloatMenuSwitchCell
            cell.iconImageView.image = icon
            cell.titleLabel.text = title
            
            cell.switchView.onTintColor = tintColor
            cell.switchView.isOn = isOn
            cell.switchView.addTarget(source_VC, action: action, for: .valueChanged)
            
            return cell
        case .SegmentCell(let title, let items, let selected, let action):
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIFloatMenuSegmentCell", for: indexPath) as! UIFloatMenuSegmentCell
            cell.titleLabel.text = title
            
            cell.items = items
            cell.segmentView.addTarget(source_VC, action: action, for: .valueChanged)
            cell.segmentView.selectedSegmentIndex = selected
            
            return cell
        case .HorizontalCell(let items, let heightStyle, let layout):
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIFloatMenuHorizontalCell", for: indexPath) as! UIFloatMenuHorizontalCell
            
            var correctedItems: [UIFloatMenuAction] {
                var corrected = [UIFloatMenuAction]()
                for index in 0..<items.count {
                    if case .ActionCell(_, _, _, _, _) = items[index].item {
                        corrected.append(items[index])
                    }
                }
                return corrected
            }
            
            cell.items = correctedItems
            cell.viewSize = cell.frame.size
            cell.heightStyle = heightStyle
            cell.layout = layout
            
            return cell
        case .CustomCell(let view):
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIFloatMenuCustomCell", for: indexPath) as! UIFloatMenuCustomCell
            cell.customView = view
            
            if #available(iOS 13.4, *) {
                cell.addInteraction(UIPointerInteraction(delegate: self))
            }
            
            return cell
        }
    }
    
    //MARK: - didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = itemsData[indexPath.row]
        
        if case .ActionCell(let selection, _, _, _, _) = row.item {
            if delegate.textField != nil {
                delegate.textField?.UIFloatMenuGetInputData(getTF_data())
            }
            
            if case .multi(_, _, _, _, _) = selection {
                row.isSelected = true
                row.action!(row)
            } else {
                if !row.closeOnTap {
                    row.action!(row)
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name("UIFloatMenuClose"), object: nil,
                                                    userInfo: ["row": row])
                }
            }
        } else if case .CustomCell(_) = row.item {
            if !row.closeOnTap {
                row.action!(row)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name("UIFloatMenuClose"), object: nil,
                                                userInfo: ["row": row])
            }
        }
    }
    
    //MARK: - didDeselectRowAt
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let row = itemsData[indexPath.row]
        
        if case .ActionCell(let selection, _, _, _, _) = row.item {
            if case .multi(_, _, _, _, _) = selection {
                row.isSelected = false
                row.action!(row)
            } else {
                if !row.closeOnTap {
                    row.action!(row)
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name("UIFloatMenuClose"), object: nil,
                                                    userInfo: ["row": row])
                }
            }
        } else if case .CustomCell(_) = row.item {
            if !row.closeOnTap {
                row.action!(row)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name("UIFloatMenuClose"), object: nil,
                                                userInfo: ["row": row])
            }
        }
    }
    
    //MARK: - heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = itemsData[indexPath.row]
        switch row.item {
        case .ActionCell(_, _, _, _, let heightStyle):
            switch heightStyle {
            case .default:
                return 57
            case .compact:
                return 47
            case .big:
                return 67
            }
        case .Title(_):
            return 30
        case .Spacer(let type):
            if case .empty(let height) = type {
                return height
            }
            return 12
        case .InfoCell(_, _, _):
            return 38
        case .InputCell(let type, _, _, _):
            switch type {
            case .textField(_,_,_,_):
                return 57
            case .textView(_,_,_):
                return 140
            }
        case .SwitchCell(_, _, _, _, _):
            return 40
        case .SegmentCell(_, _, _, _):
            return 50
        case .HorizontalCell(_, let heightStyle, _):
            switch heightStyle {
            case .default:
                return 85
            case .compact:
                return 55
            }
        case .CustomCell(let view):
            var height: CGFloat {
                let viewHeight = view.bounds.height
                if viewHeight <= 30 {
                    return 35
                }
                if viewHeight >= 80 {
                    return 85
                }
                return viewHeight+5
            }
            return height
        }
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
            tableView.isScrollEnabled = true
            return maxH
        }
        tableView.isScrollEnabled = false
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
    
    //MARK: - getTF_data()
    func getTF_data() -> [InputRow] {
        var data = [InputRow]()
        
        for index in 0..<itemsData.count {
            let indexPath = IndexPath(item: index, section: 0)
            let cell = tableView.cellForRow(at: indexPath)
            
            if cell is UIFloatMenuInputCell {
                let cell = tableView.cellForRow(at: indexPath) as! UIFloatMenuInputCell
                if case .InputCell(let type, _, _, let identifier) = itemsData[index].item {
                    switch type {
                    case .textField(_,_,_,_):
                        data.append(.init(text: cell.TextField.text, identifier: identifier))
                    case .textView(_,_,_):
                        data.append(.init(text: cell.TextView.text, identifier: identifier))
                    }
                }
            }
        }
        
        return data
    }
    
    //MARK: - UIFloatMenuDrag
    @objc private func UIFloatMenuDrag(_ sender: UIPanGestureRecognizer) {
        let appRect = UIApplication.shared.windows[0].bounds
        let topPadding = UIFloatMenuHelper.getPadding(.top)
        let bottomPadding = UIFloatMenuHelper.getPadding(.bottom)
        
        let screen = topPadding + appRect.height + bottomPadding
        
        var pointToDismiss: CGFloat {
            return bottomPadding.isZero ? screen - (topPadding*4.5) : screen - (bottomPadding*4)
        }
        
        switch sender.state {
        case .began:
            break
        case .changed:
            panChanged(sender)
        case .ended, .cancelled:
            panEnded(sender, point: pointToDismiss)
        case .failed, .possible:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - panChanged()
    private func panChanged(_ gesture: UIPanGestureRecognizer) {
        if let containerView = container_VC.view.viewWithTag(UIFloatMenuID.containerViewID) {
            let translation = gesture.translation(in: gesture.view)
            
            var translationAmount = translation.y >= 0 ? translation.y : -pow(abs(translation.y), 0.55)
            let rubberBanding = !tableView.isScrollEnabled
            if !rubberBanding && translationAmount < 0 { translationAmount = 0 }
            
            containerView.transform = CGAffineTransform(translationX: 0, y: translationAmount)
        }
    }
    
    // MARK: - panEnded()
    private func panEnded(_ gesture: UIPanGestureRecognizer, point: CGFloat) {
        if let containerView = container_VC.view.viewWithTag(UIFloatMenuID.containerViewID) {
            let velocity = gesture.velocity(in: gesture.view).y
            
            if ((containerView.frame.origin.y+containerView.frame.height/1.8) >= point) || (velocity > 200) {
                UIFloatMenu.closeAll()
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    containerView.transform = .identity
                })
            }
        }
    }
    
    //MARK: - scrollViewDidScroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
    
    //MARK: - shouldRecognizeSimultaneouslyWith
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if !tableView.isScrollEnabled {
            return false
        }
        
        if tableView.contentOffset.y == 0 {
            return true
        }
        
        return false
    }
    
    //MARK: - pointerInteraction styleFor
    @available(iOS 13.4, *)
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        var pointerStyle: UIPointerStyle?
        if let interactionViewAction = interaction.view as? UIFloatMenuActionCell {
            let targetedPreview = UITargetedPreview(view: interactionViewAction.backView)
            pointerStyle = UIPointerStyle(effect: UIPointerEffect.hover(targetedPreview, prefersScaledContent: false))
        }
        
        if let interactionViewInfo = interaction.view as? UIFloatMenuInfoCell {
            let targetedPreview = UITargetedPreview(view: interactionViewInfo.backView)
            pointerStyle = UIPointerStyle(effect: UIPointerEffect.hover(targetedPreview, prefersScaledContent: false))
        }
        
        if let interactionViewInfo = interaction.view as? UIFloatMenuCustomCell {
            let targetedPreview = UITargetedPreview(view: interactionViewInfo.customView)
            pointerStyle = UIPointerStyle(effect: UIPointerEffect.hover(targetedPreview, prefersScaledContent: false))
        }
        return pointerStyle
    }
    
    //MARK: - pointerInteraction willEnter
    @available(iOS 13.4, *)
    func pointerInteraction(_ interaction: UIPointerInteraction, willEnter region: UIPointerRegion, animator: UIPointerInteractionAnimating) {
        if let interactionView = interaction.view {
            animator.addAnimations {
                interactionView.alpha = 1.0
            }
        }
    }
    
    //MARK: - pointerInteraction willExit
    @available(iOS 13.4, *)
    func pointerInteraction(_ interaction: UIPointerInteraction, willExit region: UIPointerRegion, animator: UIPointerInteractionAnimating) {
        if let interactionView = interaction.view {
            animator.addAnimations {
                interactionView.alpha = 1.0
            }
        }
    }
    
    //MARK: - preselectCell
    private func preselectCell() {
        for index in 0..<itemsData.count {
            let indexPath = IndexPath(row: index, section: 0)
            let row = itemsData[indexPath.row]
            
            if case .ActionCell(let selection, _, _, _, _) = row.item {
                if case .multi(let preselected, _, _, _, _) = selection {
                    if preselected {
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    }
                }
            }
        }
    }

}

fileprivate extension UITableView {
    var contentSizeHeight: CGFloat {
        var height = CGFloat(0)
        for section in 0..<numberOfSections {
            height = height + rectForHeader(inSection: section).height
            let rows = numberOfRows(inSection: section)
            for row in 0..<rows {
                height = height + rectForRow(at: IndexPath(row: row, section: section)).height
            }
        }
        return height
    }
}
