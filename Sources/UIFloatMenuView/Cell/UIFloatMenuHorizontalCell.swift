//
//  HorizontalView.swift
//  UIFloatMenu
//

import UIKit

class HorizontalView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPointerInteractionDelegate {
    
    var updatedWidth: CGFloat!
    
    var items = [UIFloatMenuAction]()
    var viewSize = CGSize()
    var heightStyle: itemSetup.h_heightStyle!
    var layout: itemSetup.h_cellLayout!
    
    let cellSpacing: CGFloat = 5
    var cellInsets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    
    //MARK: - itemsView
    let itemsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let itemsView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        
        itemsView.backgroundColor = .clear
        itemsView.isScrollEnabled = true
        itemsView.allowsMultipleSelection = true
        itemsView.showsHorizontalScrollIndicator = false
        
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 5
        
        return itemsView
    }()
    
    fileprivate let cellID = "UIFloatMenu_HorizontalItemCell"
    
    //MARK: - count
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    //MARK: - cellForItem
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! HorizontalItemCell
        
        let item = items[indexPath.item]
        cell.heightStyle = heightStyle
        cell.layout = layout
        
        if case .ActionCell(let selection, _, _, _, _) = item.item {
            if case .default(let icon, let title) = selection {
                let templateIcon = icon?.withRenderingMode(.alwaysTemplate)
                cell.iconImageView.image = templateIcon
                cell.titleLabel.text = title
            } else if case .multi(let isSelected,
                                  let selectedIcon, let selectedTitle,
                                  let defaultIcon, let defaultTitle) = selection {
                
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
            cell.iconImageView.tintColor = UIFloatMenuColors.revColor
        }
        
        if #available(iOS 13.4, *) {
            cell.addInteraction(UIPointerInteraction(delegate: self))
        }
        
        return cell
    }
    
    //MARK: - didSelect
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = items[indexPath.item]
        
        if case .ActionCell(let selection, _, _, _, _) = row.item {
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
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let row = items[indexPath.item]
        
        if case .ActionCell(let selection, _, _, _, _) = row.item {
            if case .multi(_, _, _, _, _) = selection {
                row.isSelected = false
                row.action!(row)
            } else {
                row.action!(row)
                if row.closeOnTap {
                    NotificationCenter.default.post(name: NSNotification.Name("UIFloatMenuClose"), object: nil)
                }
            }
        } else if case .CustomCell(_) = row.item {
            row.action?(row)
            if row.closeOnTap {
                NotificationCenter.default.post(name: NSNotification.Name("UIFloatMenuClose"), object: nil)
            }
        }
    }
    
    //MARK: - layout cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewHeight = Double(viewSize.height)
        let count = CGFloat(items.count)
        let full_width = viewSize.width-20-(5*(count-1))
        
        var item: CGSize {
            if count >= 4 {
                return CGSize(width: (Double(full_width)/Double(4)), height: viewHeight-4)
            }
            return CGSize(width: (Double(full_width)/Double(count)), height: viewHeight-4)
        }
        
        return item
    }
    
    //MARK: - layout cell insets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: cellInsets.top, left: cellInsets.left, bottom: cellInsets.bottom, right: cellInsets.right)
    }
    
    //MARK: - init
    public init(items: [UIFloatMenuAction], viewSize: CGSize, height: itemSetup.h_heightStyle, layout: itemSetup.h_cellLayout) {
        super.init(frame: CGRect.zero)
        
        self.items = items
        self.viewSize = viewSize
        self.heightStyle = height
        self.layout = layout
        
        setupView()
        
        frame.size = viewSize
        itemsView.frame.origin = CGPoint(x: 0, y: 0)
        itemsView.frame.size = viewSize
    }
    
    //MARK: - aCoder
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    //MARK: - layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        let appRect = UIApplication.shared.windows[0].bounds
        
        if updatedWidth == nil {
            frame.size = viewSize
            itemsView.frame.size = viewSize
        } else {
            viewSize = CGSize(width: updatedWidth, height: viewSize.height)
            
            DispatchQueue.main.async {
                self.frame.size = CGSize(width: self.updatedWidth, height: self.viewSize.height)
                self.itemsView.frame.size = CGSize(width: self.updatedWidth, height: self.viewSize.height)
                self.itemsView.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    //MARK: - setupView
    private func setupView() {
        itemsView.delegate = self
        itemsView.dataSource = self
        itemsView.register(HorizontalItemCell.self, forCellWithReuseIdentifier: cellID)
        
        addSubview(itemsView)
    }
    
    //MARK: - pointerInteraction styleFor
    @available(iOS 13.4, *)
    func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
        var pointerStyle: UIPointerStyle?
        if let interactionView = interaction.view {
            let targetedPreview = UITargetedPreview(view: interactionView)
            pointerStyle = UIPointerStyle(effect: UIPointerEffect.hover(targetedPreview,
                                                                        prefersScaledContent: false))
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
    
}

//MARK: - HorizontalItemCell
class HorizontalItemCell: UICollectionViewCell {
    
    var heightStyle: itemSetup.h_heightStyle!
    var layout: itemSetup.h_cellLayout!
    
    var selection: itemSetup.selectionConfig!
    
    private var contentStackView: UIStackView = UIStackView()
    
    var backView: UIView = {
        let uiview = UIView()
        uiview.backgroundColor = UIColor.lightGray.withAlphaComponent(0.08)
        uiview.isUserInteractionEnabled = false
        uiview.layer.cornerRadius = 7
        uiview.layer.masksToBounds = true
        uiview.layer.borderWidth = 0.6
        uiview.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.05).cgColor
        return uiview
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel()
        title.adjustsFontSizeToFitWidth = true
        title.textAlignment = .center
        title.numberOfLines = 1
        title.font = UIFloatMenuHelper.roundedFont(fontSize: 13, weight: .medium)
        title.alpha = 0.8
        return title
    }()
    
    private var isReused: Bool = false
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backView.alpha = UIFloatMenuHelper.theme() == .dark ? 0.7 : 0.6
            } else {
                backView.alpha = 1
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if case .multi(_, let selectedIcon, let selectedTitle, let defaultIcon, let defaultTitle) = selection {
                if isSelected {
                    titleLabel.text = selectedTitle
                    if selectedIcon != nil {
                        iconImageView.image = selectedIcon
                    }
                } else {
                    titleLabel.text = defaultTitle
                    if defaultIcon != nil {
                        iconImageView.image = defaultIcon
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isReused = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isReused {
            contentView.addSubview(backView)
            backView.frame.size = CGSize(width: frame.width, height: frame.height)
            backView.center.x = frame.width/2
            backView.center.y = frame.height/2
            
            addSubview(contentStackView)
            
            switch layout {
            case .Icon_Title:
                contentStackView.addArrangedSubview(iconImageView)
                contentStackView.addArrangedSubview(titleLabel)
                contentStackView.axis = .horizontal
                contentStackView.alignment = .center
                contentStackView.distribution = .equalCentering
                
                titleLabel.font = UIFloatMenuHelper.roundedFont(fontSize: 15, weight: .semibold)
                
                NSLayoutConstraint.activate([
                    contentStackView.topAnchor.constraint(equalTo: backView.topAnchor, constant: 14),
                    contentStackView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 14),
                    contentStackView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -14),
                    contentStackView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -14),
                    iconImageView.heightAnchor.constraint(equalToConstant: 22),
                    iconImageView.widthAnchor.constraint(equalToConstant: 22)
                ])
                break
            case .center:
                contentStackView.addArrangedSubview(iconImageView)
                contentStackView.addArrangedSubview(titleLabel)
                contentStackView.axis = .vertical
                contentStackView.distribution = .fill
                
                NSLayoutConstraint.activate([
                    contentStackView.topAnchor.constraint(equalTo: backView.topAnchor, constant: heightStyle == .compact ? 8 : 15),
                    contentStackView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 5),
                    contentStackView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: heightStyle == .compact ? -8 : -10),
                    contentStackView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -5),
                    iconImageView.heightAnchor.constraint(equalToConstant: 30),
                    titleLabel.heightAnchor.constraint(equalToConstant: heightStyle == .compact ? 15 : 20)
                ])
                break
            case .Title_Icon:
                contentStackView.addArrangedSubview(titleLabel)
                contentStackView.addArrangedSubview(iconImageView)
                contentStackView.axis = .horizontal
                contentStackView.alignment = .center
                contentStackView.distribution = .equalCentering
                
                titleLabel.font = UIFloatMenuHelper.roundedFont(fontSize: 15, weight: .semibold)
                
                NSLayoutConstraint.activate([
                    contentStackView.topAnchor.constraint(equalTo: backView.topAnchor, constant: 14),
                    contentStackView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 14),
                    contentStackView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -14),
                    contentStackView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -14),
                    iconImageView.heightAnchor.constraint(equalToConstant: 22),
                    iconImageView.widthAnchor.constraint(equalToConstant: 22)
                ])
                break
            case .none:
                break
            }
            
            contentStackView.spacing = 2
            contentStackView.isUserInteractionEnabled = false
            contentStackView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 7
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: UIFloatMenuHorizontalCell
class UIFloatMenuHorizontalCell: UITableViewCell {
    
    var items = [UIFloatMenuAction]()
    var viewSize: CGSize!
    var heightStyle: itemSetup.h_heightStyle!
    var layout: itemSetup.h_cellLayout!
    
    private var isReused: Bool = false
    private var isLoaded: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isReused = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isReused && !isLoaded {
            let h_view = HorizontalView.init(items: items, viewSize: viewSize, height: heightStyle, layout: layout)
            contentView.addSubview(h_view)
            h_view.frame.origin = .zero
        }
        
        isLoaded = true
    }
    
}
