## Navigate

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Delegate](#delegate)

## Features

- Highly customizable
   - support dark/light theme
   - cornerRadius
   - width (iPad)

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
   
   Item color
   ```swift
   - standard
   - clear
   - filled
   - tinted
   - custom
   ```
    
   Item Layout
   ```swift
   - Icon_Title (Icon left, title right)
   - Title_Icon (Title left, Icon right)
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
menu.config.cornerRadius = 12
menu.config.blurBackground = true
menu.config.viewWidth_iPad = 350
menu.config.presentation = .default
menu.closeDelegate = self
menu.show(self)
```

## Delegate

To `know when menu is closed`, set the delegate with protocol `UIFloatMenuCloseDelegate`:

```swift
func didCloseMenu() {
    print("didCloseMenu - MenuClosed")
}
```

To get `UITextField data`, set the delegate with protocol `UIFloatMenuTextFieldDelegate`:

```swift
func getTextFieldData(_ data: [String]) {
    print("TextField -", data)
}
```
