//
//  Keyboard.swift
//  Demo
//
//  Created by MORITANAOKI on 2015/12/14.
//  Copyright © 2015年 molabo. All rights reserved.
//

import UIKit

public enum KeyboardEventType: String {
    case WillShow
    case DidShow
    case WillHide
    case DidHide
    case WillChangeFrame
    case DidChangeFrame
    
    public var notificationName: String {
        switch self {
        case .WillShow:
            return UIKeyboardWillShowNotification
        case .DidShow:
            return UIKeyboardDidShowNotification
        case .WillHide:
            return UIKeyboardWillHideNotification
        case .DidHide:
            return UIKeyboardDidHideNotification
        case .WillChangeFrame:
            return UIKeyboardWillChangeFrameNotification
        case .DidChangeFrame:
            return UIKeyboardDidChangeFrameNotification
        }
    }
    
    init?(name: String) {
        switch name {
        case UIKeyboardWillShowNotification:
            self = .WillShow
        case UIKeyboardDidShowNotification:
            self = .DidShow
        case UIKeyboardWillHideNotification:
            self = .WillHide
        case UIKeyboardDidHideNotification:
            self = .DidHide
        case UIKeyboardWillChangeFrameNotification:
            self = .WillChangeFrame
        case UIKeyboardDidChangeFrameNotification:
            self = .DidChangeFrame
        default:
            return nil
        }
    }
    
    static func allEventNames() -> [String] {
        return [
            KeyboardEventType.WillShow,
            KeyboardEventType.DidShow,
            KeyboardEventType.WillHide,
            KeyboardEventType.DidHide,
            KeyboardEventType.WillChangeFrame,
            KeyboardEventType.DidChangeFrame
        ].map { $0.notificationName }
    }
}

public struct KeyboardEvent {
    public let type: KeyboardEventType
    public let keyboardFrameBegin: CGRect
    public let keyboardFrameEnd: CGRect
    public let curve: UIViewAnimationOptions
    public let duration: NSTimeInterval
    public var isLocal: Bool?
    init?(name: String, userInfo: [NSObject: AnyObject]) {
        guard let type = KeyboardEventType(name: name) else { return nil }
        self.type = type
        self.keyboardFrameBegin = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        self.keyboardFrameEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.curve = UIViewAnimationOptions(rawValue: UInt(userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber))
        self.duration = NSTimeInterval(userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber)
        if #available(iOS 9, *) {
            self.isLocal = Bool(userInfo[UIKeyboardIsLocalUserInfoKey] as! NSNumber)
        }
    }
}

public enum KeyboardState {
    case Initial
    case Showing
    case Shown
    case Hiding
    case Hidden
    case Changing
}

public typealias KeyboardEventClosure = ((event: KeyboardEvent) -> Void)

public class KeyboardObserver {
    var state = KeyboardState.Initial
    var eventClosures = [KeyboardEventClosure]()
    var enabled = true
    
    deinit {
        eventClosures.removeAll()
        KeyboardEventType.allEventNames().forEach {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: $0, object: nil)
        }
    }
    
    public init() {
        KeyboardEventType.allEventNames().forEach {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "notified:", name: $0, object: nil)
        }
    }
    
    public func observe(event: KeyboardEventClosure) {
        if enabled == false { return }
        eventClosures.append(event)
    }
}

internal extension KeyboardObserver {
    @objc func notified(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let event = KeyboardEvent(name: notification.name, userInfo: userInfo) else { return }
        
        switch event.type {
        case .WillShow:
            state = .Showing
        case .DidShow:
            state = .Shown
        case .WillHide:
            state = .Hiding
        case .DidHide:
            state = .Hidden
        case .WillChangeFrame:
            state = .Changing
        case .DidChangeFrame:
            state = .Shown
        }
        
        eventClosures.forEach { $0(event: event) }
    }
}
