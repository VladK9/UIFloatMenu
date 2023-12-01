### About

<p align="center">
  <img src="https://github.com/VladK9/UIFloatMenu/blob/main/Assets/UIFloatMenu-Banner.png">
</p>

## Navigate

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Functions](#functions)
- [Delegate](#delegate)

## Features

- Highly customizable
   - support dark/light theme
   - corner radius
   - blurred background (with blur styles)
   - various positions

   ## **Cell type's**
   
   #### - ActionCell
   
   ##### Single action
   ```swift
   .init(item: .ActionCell(selection: .default(icon: UIImage(systemName: "star"), title: "Title")), action: { action in
       print("item Unstar")
   })
   ```
    
   ##### Double action
   ```swift
   .init(item: .ActionCell(selection: .multi(isSelected: true,
                            selectedIcon: UIImage(systemName: "star.slash"), selectedTitle: "Unstar",
                            defaultIcon: UIImage(systemName: "star"), defaultTitle: "Star")), 
          action: { action in
        if action.isSelected ?? false {
            print("item Unstar")
        } else {
            print("item Star")
        }
   })
   ```
   
   ##### Action item color
   ```swift
   - default
   - clear
   - filled parameters: color
   - tinted parameters: color
   - custom parameters: color, textColor, backColor
   ```
   
   ##### Action item Layout
   ```swift
   - Icon_Title (Icon left, title right)
   - Title_Icon (Title left, Icon right)
   ```
   
   ##### Action item height
   ```swift
   - compact
   - default
   - big
   ```
    
   #### - TitleCell
   ```swift
   .init(item: .Title("Title"))
   ```
   
   #### - SpacerCell
   ```swift
   .init(item: .Spacer(type: .empty))
   .init(item: .Spacer(type: .line())) parameters: color, inset
   .init(item: .Spacer(type: .dashedLine())) parameters: color
   .init(item: .Spacer(type: .divider))
   ```
   
   #### - InputCell
   ```swift
   .init(item: .InputCell(type: .textField(), placeholder: "Login", identifier: "Login"))
   .init(item: .InputCell(type: .textView(), placeholder: "Description", identifier: "Description"))
   
   textField parameters: text, isSecure, content, keyboard
   textView parameters: text, content, keyboard
   ```
   
   #### - SwitchCell
   ```swift
   .init(item: .SwitchCell(icon: UIImage(systemName: "bookmark")!, title: "Switch 1", action: #selector(switchAction)))
   ```
   
   #### - SegmentCell
   ```swift
   .init(item: .SegmentCell(items: ["Item 1", UIImage(systemName: "bookmark")!, "Item 3"], selected: 1, action: #selector(segmentAction)))
   ```
   
   #### - CustomCell
   ```swift
   .init(item: .CustomCell(view: CustomViewRow(title: "Custom rows", subtitle: "View custom rows", icon: UIImage(systemName: "tablecells")!)), action: { _ in }
   ```
   
   Horizontal Action item height
   ```swift
   - compact
   - default
   ```

## Installation
Put `Sources` folder in your Xcode project. Make sure to enable `Copy items if needed`.

## Usage

```swift
let actions: [UIFloatMenuAction] = []

//let custom_menu = UIFloatMenu.setup(type: .custom(view: CustomView))
let menu = UIFloatMenu.setup(type: .actions(actions))
menu.header.title = "UIFloatMenu title"
menu.header.subtitle = "UIFloatMenu subtitle"
menu.header.showButton = true
menu.header.showHeader = true
menu.header.showLine = true
menu.header.lineInset = 15
menu.config.cornerRadius = 12
menu.config.blurBackground = true
menu.config.blurStyle = .systemMaterial
menu.config.presentation = .default
menu.delegate.close = self
menu.show(self)
```

## Functions

**Show next view with animation**
```swift
let header = UIFloatMenuHeaderConfig(title: "Activity", showLine: true)
UIFloatMenu.showNext(type: .custom(view: CustomView), header: header, presentation: .center) // custom view
UIFloatMenu.showNext(type: .actions([]), header: header, presentation: .center) // items
```

**Display indicator**
```swift
UIFloatMenu.displayIndicator(text: "Loading...", presentation: .rightUp(overNavBar: true))

//If success, show next
UIFloatMenu.showNext(actions: [], presentation: .rightUp(overNavBar: true), header: header)

//If error, stop indicator and show previous view
UIFloatMenu.stopIndicator()
```

**Show alert**
```swift
let alert = UIAlertController(title: "Delete", message: "message", preferredStyle: .alert)
alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
UIFloatMenuHelper.showAlert(alert)
```

## Delegate

To `know when menu is closed`, set the delegate with protocol `UIFloatMenuCloseDelegate`:

```swift
menu.delegate.close = self
```

```swift
func UIFloatMenuDidCloseMenu() {
    print("didCloseMenu - MenuClosed")
}
```

To get `UITextField` or `UITextView data`, set the delegate with protocol `UIFloatMenuTextFieldDelegate`:

```swift
menu.delegate.input = self
```

```swift
func UIFloatMenuGetInputData(_ rows: [InputRow]) {
    let login = UIFloatMenuHelper.find(rows, by: "Login")
    let password = UIFloatMenuHelper.find(rows, by: "Password")

    print("Login -", login)
    print("Password -", password)
}
```
