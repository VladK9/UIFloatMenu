### About

<p align="center">
  <img src="https://github.com/VladK9/UIFloatMenu/blob/main/Assets/UIFloatMenu-Banner.png">
</p>

## Navigate

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Delegate](#delegate)

## Features

- Highly customizable
   - support dark/light theme
   - corner radius
   - blured background
   - width (iPad)
   - various positions

   ### Item config
   
   Item type
   ```swift
   - ActionCell
   - Title
   - Spacer
   - InfoCell
   - TextFieldCell
   - SwitchCell
   - SegmentCell
   ```
   
   Action item color
   ```swift
   - standard
   - clear
   - filled
   - tinted
   - custom
   ```
    
   Action item Layout
   ```swift
   - Icon_Title (Icon left, title right)
   - Title_Icon (Title left, Icon right)
   ```
   
   Action item height
   ```swift
   - compact
   - standard
   - big
   ```
   
   Spacer type
   ```swift
   - empty
   - line
   - dashedLine
   - divider
   ```

## Installation
Put `Sources` folder in your Xcode project. Make sure to enable `Copy items if needed`.

## Usage

```swift
let actions: [UIFloatMenuAction] = [
    .init(item: .Title("Title")),
    .init(item: .SegmentCell(items: ["Item 1", UIImage(systemName: "bookmark")!, "Item 3"], selected: 1, action: #selector(segmentAction))),
    .init(item: .SwitchCell(icon: UIImage(systemName: "bookmark")!, title: "Switch 1", action: #selector(switchAction))),
    .init(item: .InfoCell(icon: UIImage(systemName: "questionmark.square")!, title: "Data title", label: .config(fontSize: 15, fontWeight: .semibold))),
    .init(item: .Spacer(type: .divider)),
    .init(item: .Title("Title")),
    .init(item: .ActionCell(icon: UIImage(systemName: "arrow.down.square.fill")!, title: "Title", layout: .Icon_Title), itemColor: .tinted(.systemBlue), action: { _ in
        print("Action")
    }),
    .init(item: .Spacer(type: .line())),
    .init(item: .ActionCell(icon: UIImage(systemName: "arrow.right.square.fill")!, title: "Title", subtitle: "Test subtitle", layout: .Icon_Title), itemColor: .filled(.systemPurple), action: { _ in
        print("Action")
    })
]
        
let menu = UIFloatMenu.setup(actions: actions)
menu.header.title = "UIFloatMenu title"
menu.header.subTitle = "UIFloatMenu subtitle"
menu.header.showHeader = true
menu.header.showLine = true
menu.header.lineInset = 15
menu.config.cornerRadius = 12
menu.config.blurBackground = true
menu.config.viewWidth_iPad = 350
menu.config.presentation = .default
menu.delegate.close = self
menu.show(self)
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

To get `UITextField data`, set the delegate with protocol `UIFloatMenuTextFieldDelegate`:

```swift
menu.delegate.textField = self
```

```swift
func UIFloatMenuGetTextFieldData(_ data: [String]) {
    print("TextField -", data)
}
```
