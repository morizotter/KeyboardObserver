# KeyboardObserver
For less complicated keyboard event handling.

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Features

- Less complicated keyboard event handling.
- Do not use `Notification` , but `event` .

## Difference

**Without KeyboardObserver.swift**

```Swift
let keyboardNotifications: [Notification.Name] = [
    .UIKeyboardWillShow,
    .UIKeyboardWillHide,
    .UIKeyboardWillChangeFrame,
]

override func viewDidLoad() {
    super.viewDidLoad()
}

override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    keyboardNotifications.forEach {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardEventNotified:), name: $0, object: nil)
    }
}

override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)

    keyboardNotifications.forEach {
        NotificationCenter.default.removeObserver(self, name: $0, object: nil)
    }
}

@objc func keyboardEventNotified(notification: NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    let keyboardFrameEnd = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    let curve = UIView.AnimationCurve(rawValue: (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! NSNumber).intValue)!
    let options = UIView.AnimationOptions(rawValue: UInt(curve.rawValue << 16))
    let duration = TimeInterval(truncating: userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber)
    let bottom = keyboardFrameEnd.height - bottomLayoutGuide.length
    
    UIView.animate(withDuration: duration, delay: 0.0, options: [options], animations:
        { () -> Void in
            self.textView.contentInset.bottom = bottom
            self.textView.scrollIndicatorInsets.bottom = bottom
        } , completion: nil)
}
```

**With KeyboardObserver**

```Swift
let keyboard = KeyboardObserver()

override func viewDidLoad() {
    super.viewDidLoad()

    keyboard.observe { [weak self] (event) -> Void in
        guard let self = self else { return }
        switch event.type {
        case .willShow, .willHide, .willChangeFrame:
            print("Fire: \(event.type)")
            let keyboardFrameEnd = event.keyboardFrameEnd
            let bottom = keyboardFrameEnd.height - self.bottomLayoutGuide.length
            
            UIView.animate(withDuration: event.duration, delay: 0.0, options: [event.options], animations: { () -> Void in
                self.textView.contentInset.bottom = bottom
                self.textView.scrollIndicatorInsets.bottom = bottom
                }, completion: nil)
        default:
            break
        }
    }
}
```

## How to use

Create `KeyboardObserver` instance where you want, and the instance observes keyboard untill deinit.

Call `observe(event: KeyboardEvent)` to observe keyboard events. `event` is converted keyboard notification object.

```swift
public struct KeyboardEvent {
    public let type: KeyboardEventType
    public let keyboardFrameBegin: CGRect
    public let keyboardFrameEnd: CGRect
    public let curve: UIViewAnimationCurve
    public let duration: NSTimeInterval
    public var isLocal: Bool?

    public var options: UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: UInt(curve.rawValue << 16))
    }
    ...
```

`event` has properties above. You don't have to convert `Notification` 's userInfo to extract keyboard event values.

`KeyboardEentType` has types same as keyboard's notification name. Like this below:

```Swift
public enum KeyboardEventType {
    case willShow
    case didShow
    case willHide
    case didHide
    case willChangeFrame
    case didChangeFrame
    ...
}
```

It has also `public var notificationName: String` which you can get original notification name.

## Runtime Requirements

- iOS 8.0 or later
- Xcode 10.0 
- Swift4.2

## Installation and Setup

**Information:** To use KeyboardObserver with a project targeting lower than iOS 8.0, you must include the `KeyboardObserver.swift` source file directly in your project.

### Installing with Carthage

Just add to your Cartfile:

```ogdl
github "morizotter/KeyboardObserver"
```

### Installing with CocoaPods

[CocoaPods](http://cocoapods.org) is a centralised dependency manager that automates the process of adding libraries to your Cocoa application. You can install it with the following command:

```bash
$ gem update
$ gem install cocoapods
$ pods --version
```

To integrate KeyboardObserver into your Xcode project using CocoaPods, specify it in your `Podfile` and run `pod install`.

```bash
platform :ios, '8.0'
use_frameworks!
pod "KeyboardObserver", '~>2.0.0'
```

### Manual Installation

To install KeyboardObserver without a dependency manager, please add `KeyboardObserver.swift` to your Xcode Project.

## Contribution

Please file issues or submit pull requests for anything you’d like to see! We're waiting! :)

## License
KeyboardObserver.swift is released under the MIT license. Go read the LICENSE file for more information.
