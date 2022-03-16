//
//  UIFloatMenuView.swift
//  UIFloatMenu
//

import UIKit

class UIFloatMenuView: UIView, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
        
    private var currentVC = UIViewController()
    
    private var config = UIFloatMenuConfig()
    private var headerConfig = UIFloatMenuHeaderConfig()
    
    private var itemsData = [UIFloatMenuAction]()
    
    private let space: CGFloat = 8
    
    var delegate = Delegates()
    
    //MARK: - tableView
    lazy var tableView: UITableView = {
        let table = UITableView()
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
    public init(items: [UIFloatMenuAction], vc: UIViewController, header: UIFloatMenuHeaderConfig, config: UIFloatMenuConfig,
                delegate: Delegates) {
        super.init(frame: CGRect.zero)
        
        self.currentVC = vc
        self.itemsData = items
        self.config = config
        self.headerConfig = header
        self.delegate = delegate
        
        backgroundColor = .clear
        
        setupTableView()
        
        addSubview(tableView)
        
        var tableH: CGFloat {
            let height = tableView.contentSizeHeight+(space*2)+(headerConfig.showHeader == true ? 60 : 0)
            return setMaxHeight(height)
        }
        
        let tableW: CGFloat = setMaxWidth(tableView.bounds.width)
        
        let device = UIDevice.current.userInterfaceIdiom
        let width = (device == .pad ? config.viewWidth_iPad : tableW)!
        
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
        
        if config.blurBackground {
            let blurEffect = UIBlurEffect(style: .prominent)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = frame
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(blurView)
            sendSubviewToBack(blurView)
        } else {
            backgroundColor = UIFloatMenuColors.mainColor
        }
        
        layer.cornerRadius = config.cornerRadius
        layer.masksToBounds = true
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.darkGray.withAlphaComponent(0.25).cgColor
        
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
        var tableH: CGFloat {
            let height = tableView.contentSizeHeight+(space*2)+(headerConfig.showHeader == true ? 60 : 0)
            return setMaxHeight(height)
        }
        
        let tableW: CGFloat = setMaxWidth(tableView.bounds.width)
        
        let device = UIDevice.current.userInterfaceIdiom
        let width = (device == .pad ? config.viewWidth_iPad : tableW)!
        
        if headerConfig.showHeader {
            tableView.frame = CGRect(x: 0, y: 60, width: width, height: tableH-60)
            frame.size = CGSize(width: width, height: tableH)
        } else {
            tableView.frame = CGRect(x: 0, y: 0, width: width, height: tableH)
            frame.size = CGSize(width: width, height: tableH)
        }
    }
    
    //MARK: - setupTableView
    internal func setupTableView() {
        tableView.register(UIFloatMenuActionCell.self, forCellReuseIdentifier: "UIFloatMenuActionCell")
        tableView.register(UIFloatMenuInfoCell.self, forCellReuseIdentifier: "UIFloatMenuInfoCell")
        tableView.register(UIFloatMenuTitleCell.self, forCellReuseIdentifier: "UIFloatMenuTitleCell")
        tableView.register(UIFloatMenuSpacerCell.self, forCellReuseIdentifier: "UIFloatMenuSpacerCell")
        tableView.register(UIFloatMenuTextFieldCell.self, forCellReuseIdentifier: "UIFloatMenuTextFieldCell")
        tableView.register(UIFloatMenuSwitchCell.self, forCellReuseIdentifier: "UIFloatMenuSwitchCell")
        tableView.register(UIFloatMenuSegmentCell.self, forCellReuseIdentifier: "UIFloatMenuSegmentCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: - numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsData.count
    }
    
    //MARK: - cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = itemsData[indexPath.item]
        
        switch row.item {
        case .ActionCell(let icon, let title, let subtitle, let layout, let height):
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIFloatMenuActionCell", for: indexPath) as! UIFloatMenuActionCell
            
            cell.itemColor = row.itemColor
            cell.itemLayout = layout
            cell.itemHeight = height
            
            cell.iconImageView.image = icon
            
            cell.titleLabel.text = title
            cell.subtitleLabel.text = subtitle
            
            return cell
        case .InfoCell(let icon, let title, let labelConfig):
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIFloatMenuInfoCell", for: indexPath) as! UIFloatMenuInfoCell
            
            cell.iconImageView.image = icon
            cell.titleLabel.text = title
            if case .config(let fontSize, let fontWeight) = labelConfig {
                cell.titleLabel.font = UIFloatMenuHelper.roundedFont(fontSize: fontSize, weight: fontWeight)
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
        case .TextFieldCell(let title, let placeholder, let isResponder, let isSecure, let content, let keyboard):
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIFloatMenuTextFieldCell", for: indexPath) as! UIFloatMenuTextFieldCell
            cell.TextField.text = title
            cell.TextField.placeholder = placeholder
            
            cell.TextField.isSecureTextEntry = isSecure
            cell.TextField.textContentType = content
            cell.TextField.keyboardType = keyboard
            
            if isResponder {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    cell.TextField.becomeFirstResponder()
                }
            }
            
            return cell
        case .SwitchCell(let icon, let title, let isOn, let tintColor, let action):
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIFloatMenuSwitchCell", for: indexPath) as! UIFloatMenuSwitchCell
            cell.iconImageView.image = icon
            cell.titleLabel.text = title
            
            cell.switchView.onTintColor = tintColor
            cell.switchView.isOn = isOn
            cell.switchView.addTarget(currentVC, action: action, for: .valueChanged)
            
            return cell
        case .SegmentCell(let title, let items, let selected, let action):
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIFloatMenuSegmentCell", for: indexPath) as! UIFloatMenuSegmentCell
            cell.titleLabel.text = title
            
            cell.items = items
            cell.segmentView.addTarget(currentVC, action: action, for: .valueChanged)
            cell.segmentView.selectedSegmentIndex = selected
            
            return cell
        }
    }
    
    //MARK: - didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = itemsData[indexPath.item]
        
        if case .ActionCell = row.item {
            if delegate.textField != nil {
                delegate.textField?.UIFloatMenuGetTextFieldData(getTF_data())
            }
            
            if delegate.close != nil {
                delegate.close?.UIFloatMenuDidCloseMenu()
            }
            
            row.action!(row)
            if row.closeOnTap {
                NotificationCenter.default.post(name: NSNotification.Name("UIFloatMenuClose"), object: nil)
            }
        }
    }
    
    //MARK: - heightForRowAt
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = CGFloat()
        
        let row = itemsData[indexPath.item]
        switch row.item {
        case .ActionCell(_, _, _, _, let heightStyle):
            switch heightStyle {
            case .standard:
                height = 57
            case .compact:
                height = 47
            case .big:
                height = 67
            }
        case .Title(_):
            height = 30
        case .Spacer(_):
            height = 10
        case .InfoCell(_, _, _):
            height = 36
        case .TextFieldCell(_, _, _, _, _, _):
            height = 57
        case .SwitchCell(_, _, _, _, _):
            height = 40
        case .SegmentCell(_, _, _, _):
            height = 50
        }
        
        return height
    }
    
    //MARK: - setMaxHeight()
    private func setMaxHeight(_ currentHeight: CGFloat) -> CGFloat {
        let topPadding = UIFloatMenuHelper.getPadding(.top)
        let bottomPadding = UIFloatMenuHelper.getPadding(.bottom)
        
        let appRect = UIApplication.shared.windows[0].bounds
        var topSpace: CGFloat {
            let device = UIDevice.current.userInterfaceIdiom
            return device == .pad ? 70 : (Orientation.isLandscape ? 30 : 50)
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
            if Orientation.isLandscape {
                return appRect.width/2.5
            } else if Orientation.isPortrait {
                return appRect.width-30
            }
        }
        return appRect.width-30
    }
    
    //MARK: - getTF_data()
    func getTF_data() -> [String] {
        var data = [String]()
        
        for index in 0..<itemsData.count {
            let indexPath = IndexPath(item: index, section: 0)
            let cell = tableView.cellForRow(at: indexPath)
            
            if cell is UIFloatMenuTextFieldCell {
                let cell = tableView.cellForRow(at: indexPath) as! UIFloatMenuTextFieldCell
                data.append("\(cell.TextField.text!)")
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
        let view = gesture.view!
        let translation = gesture.translation(in: gesture.view)
        
        var translationAmount = translation.y >= 0 ? translation.y : -pow(abs(translation.y), 0.55)
        let rubberBanding = !tableView.isScrollEnabled
        if !rubberBanding && translationAmount < 0 { translationAmount = 0 }
        
        view.transform = CGAffineTransform(translationX: 0, y: translationAmount)
    }
    
    // MARK: - panEnded()
    private func panEnded(_ gesture: UIPanGestureRecognizer, point: CGFloat) {
        let velocity = gesture.velocity(in: gesture.view).y
        let view = gesture.view!
        if ((view.frame.origin.y+view.frame.height/1.6) >= point) || (velocity > 200) {
            NotificationCenter.default.post(name: NSNotification.Name("UIFloatMenuClose"), object: nil)
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = .identity
            })
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
        if tableView.contentOffset.y == 0 {
            return true
        }
        return false
    }

}
