//
//  HorizontalView.swift
//  UIFloatMenu
//

import UIKit

class HorizontalView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPointerInteractionDelegate {
    
    var items = [UIFloatMenuAction]()
    var viewSize = CGSize()
    var heightStyle: h_heightStyle!
    var layout: h_cellLayout!
    
    let cellSpacing: CGFloat = 5
    var cellInsets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    
    //MARK: - itemsView
    let itemsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let itemsView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        
        itemsView.backgroundColor = .clear
        itemsView.isScrollEnabled = true
        itemsView.allowsMultipleSelection = false
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
        
        if case .ActionCell(let icon, let title, _, _, _) = item.item {
            let templateIcon = icon?.withRenderingMode(.alwaysTemplate)
            cell.iconView.image = templateIcon
            cell.iconView.tintColor = UIFloatMenuColors.revColor
            cell.titleLabel.text = title
        }
        
        if #available(iOS 13.4, *) {
            cell.addInteraction(UIPointerInteraction(delegate: self))
        }
        
        return cell
    }
    
    //MARK: - didSelect
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = items[indexPath.item]
        
        if case .ActionCell = row.item {
            row.action!(row)
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
            if count >= 4 { //more then 4 items or 4
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
    public init(items: [UIFloatMenuAction], viewSize: CGSize, height: h_heightStyle, layout: h_cellLayout) {
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
        frame.size = viewSize
        itemsView.frame.size = viewSize
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
    
    var heightStyle: h_heightStyle!
    var layout: h_cellLayout!
    
    private var contentStackView: UIStackView = UIStackView()
    
    let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.85
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel()
        title.adjustsFontSizeToFitWidth = true
        title.textAlignment = .center
        title.numberOfLines = 1
        title.font = UIFloatMenuHelper.roundedFont(fontSize: 13, weight: .medium)
        return title
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(contentStackView)
        
        switch layout {
        case .Icon_Title:
            contentStackView.addArrangedSubview(iconView)
            contentStackView.addArrangedSubview(titleLabel)
            contentStackView.axis = .horizontal
            contentStackView.alignment = .center
            contentStackView.distribution = .equalCentering
            
            titleLabel.font = UIFloatMenuHelper.roundedFont(fontSize: 15, weight: .medium)
            
            NSLayoutConstraint.activate([
                contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
                contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
                contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
                contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
                iconView.heightAnchor.constraint(equalToConstant: 22),
                iconView.widthAnchor.constraint(equalToConstant: 22)
            ])
            break
        case .center:
            contentStackView.addArrangedSubview(iconView)
            contentStackView.addArrangedSubview(titleLabel)
            contentStackView.axis = .vertical
            contentStackView.distribution = .fill
            
            NSLayoutConstraint.activate([
                contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: heightStyle == .compact ? 8 : 15),
                contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
                contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: heightStyle == .compact ? -8 : -10),
                contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
                iconView.heightAnchor.constraint(equalToConstant: 30),
                titleLabel.heightAnchor.constraint(equalToConstant: heightStyle == .compact ? 15 : 20)
            ])
            break
        case .Title_Icon:
            contentStackView.addArrangedSubview(titleLabel)
            contentStackView.addArrangedSubview(iconView)
            contentStackView.axis = .horizontal
            contentStackView.alignment = .center
            contentStackView.distribution = .equalCentering
            
            titleLabel.font = UIFloatMenuHelper.roundedFont(fontSize: 15, weight: .medium)
            
            NSLayoutConstraint.activate([
                contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
                contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
                contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
                contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
                iconView.heightAnchor.constraint(equalToConstant: 22),
                iconView.widthAnchor.constraint(equalToConstant: 22)
            ])
            break
        case .none:
            break
        }
        
        contentStackView.spacing = 2
        contentStackView.isUserInteractionEnabled = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 7
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.12)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: - UIFloatMenuHorizontalCell
class UIFloatMenuHorizontalCell: UITableViewCell {
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: layoutSubviews
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}
