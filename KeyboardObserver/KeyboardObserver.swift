//
//  Keyboard.swift
//  Demo
//
//  Created by MORITANAOKI on 2015/12/14.
//  Copyright © 2015年 molabo. All rights reserved.
//

import UIKit

#if swift(>=4.2)

public enum KeyboardEventType {
	case willShow
	case didShow
	case willHide
	case didHide
	case willChangeFrame
	case didChangeFrame
	
	public var notificationName: NSNotification.Name {
		switch self {
		case .willShow:
			return UIResponder.keyboardWillShowNotification
		case .didShow:
			return UIResponder.keyboardDidShowNotification
		case .willHide:
			return UIResponder.keyboardWillHideNotification
		case .didHide:
			return UIResponder.keyboardDidHideNotification
		case .willChangeFrame:
			return UIResponder.keyboardWillChangeFrameNotification
		case .didChangeFrame:
			return UIResponder.keyboardDidChangeFrameNotification
		}
	}
	
	init?(name: NSNotification.Name) {
		switch name {
		case UIResponder.keyboardWillShowNotification:
			self = .willShow
		case UIResponder.keyboardDidShowNotification:
			self = .didShow
		case UIResponder.keyboardWillHideNotification:
			self = .willHide
		case UIResponder.keyboardDidHideNotification:
			self = .didHide
		case UIResponder.keyboardWillChangeFrameNotification:
			self = .willChangeFrame
		case UIResponder.keyboardDidChangeFrameNotification:
			self = .didChangeFrame
		default:
			return nil
		}
	}
	
	static func allEventNames() -> [NSNotification.Name] {
		return [
			KeyboardEventType.willShow,
			KeyboardEventType.didShow,
			KeyboardEventType.willHide,
			KeyboardEventType.didHide,
			KeyboardEventType.willChangeFrame,
			KeyboardEventType.didChangeFrame
			].map { $0.notificationName }
	}
}

public struct KeyboardEvent {
	public let type: KeyboardEventType
	public let keyboardFrameBegin: CGRect
	public let keyboardFrameEnd: CGRect
	public let curve: UIView.AnimationCurve
	public let duration: TimeInterval
	public var isLocal: Bool?
	
	public var options: UIView.AnimationOptions {
		return UIView.AnimationOptions(rawValue: UInt(curve.rawValue << 16))
	}
	
	init?(notification: Notification) {
		guard let userInfo = (notification as NSNotification).userInfo else { return nil }
		guard let type = KeyboardEventType(name: notification.name) else { return nil }
		guard let begin = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return nil }
		guard let end = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return nil }
		guard
			let curveInt = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
			let curve = UIView.AnimationCurve(rawValue: curveInt)
			else { return nil }
		guard
			let durationDouble = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
			else { return nil }
		
		self.type = type
		self.keyboardFrameBegin = begin
		self.keyboardFrameEnd = end
		self.curve = curve
		self.duration = TimeInterval(durationDouble)
		if #available(iOS 9, *) {
			guard let isLocalInt = (userInfo[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber)?.intValue else { return nil }
			self.isLocal = isLocalInt == 1
		}
	}
}

public enum KeyboardState {
	case initial
	case showing
	case shown
	case hiding
	case hidden
	case changing
}

public typealias KeyboardEventClosure = ((_ event: KeyboardEvent) -> Void)

open class KeyboardObserver {
	open var state = KeyboardState.initial
	open var isEnabled = true
	fileprivate var eventClosures = [KeyboardEventClosure]()
	
	deinit {
		eventClosures.removeAll()
		KeyboardEventType.allEventNames().forEach {
			NotificationCenter.default.removeObserver(self, name: $0, object: nil)
		}
	}
	
	public init() {
		KeyboardEventType.allEventNames().forEach {
			NotificationCenter.default.addObserver(self, selector: #selector(notified(_:)), name: $0, object: nil)
		}
	}
	
	open func observe(_ event: @escaping KeyboardEventClosure) {
		eventClosures.append(event)
	}
}

internal extension KeyboardObserver {
	@objc func notified(_ notification: Notification) {
		guard let event = KeyboardEvent(notification: notification) else { return }
		
		switch event.type {
		case .willShow:
			state = .showing
		case .didShow:
			state = .shown
		case .willHide:
			state = .hiding
		case .didHide:
			state = .hidden
		case .willChangeFrame:
			state = .changing
		case .didChangeFrame:
			state = .shown
		}
		
		if !isEnabled { return }
		eventClosures.forEach { $0(event) }
	}
}


#else


public enum KeyboardEventType {
    case willShow
    case didShow
    case willHide
    case didHide
    case willChangeFrame
    case didChangeFrame
    
    public var notificationName: NSNotification.Name {
        switch self {
        case .willShow:
            return .UIKeyboardWillShow
        case .didShow:
            return .UIKeyboardDidShow
        case .willHide:
            return .UIKeyboardWillHide
        case .didHide:
            return .UIKeyboardDidHide
        case .willChangeFrame:
            return .UIKeyboardWillChangeFrame
        case .didChangeFrame:
            return .UIKeyboardDidChangeFrame
        }
    }
    
    init?(name: NSNotification.Name) {
        switch name {
        case NSNotification.Name.UIKeyboardWillShow:
            self = .willShow
        case NSNotification.Name.UIKeyboardDidShow:
            self = .didShow
        case NSNotification.Name.UIKeyboardWillHide:
            self = .willHide
        case NSNotification.Name.UIKeyboardDidHide:
            self = .didHide
        case NSNotification.Name.UIKeyboardWillChangeFrame:
            self = .willChangeFrame
        case NSNotification.Name.UIKeyboardDidChangeFrame:
            self = .didChangeFrame
        default:
            return nil
        }
    }
    
    static func allEventNames() -> [NSNotification.Name] {
        return [
            KeyboardEventType.willShow,
            KeyboardEventType.didShow,
            KeyboardEventType.willHide,
            KeyboardEventType.didHide,
            KeyboardEventType.willChangeFrame,
            KeyboardEventType.didChangeFrame
        ].map { $0.notificationName }
    }
}

public struct KeyboardEvent {
    public let type: KeyboardEventType
    public let keyboardFrameBegin: CGRect
    public let keyboardFrameEnd: CGRect
    public let curve: UIViewAnimationCurve
    public let duration: TimeInterval
    public var isLocal: Bool?
    
    public var options: UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: UInt(curve.rawValue << 16))
    }
    
    init?(notification: Notification) {
        guard let userInfo = (notification as NSNotification).userInfo else { return nil }
        guard let type = KeyboardEventType(name: notification.name) else { return nil }
        guard let begin = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return nil }
        guard let end = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return nil }
        guard
            let curveInt = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
            let curve = UIViewAnimationCurve(rawValue: curveInt)
            else { return nil }
        guard
            let durationDouble = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
            else { return nil }
        
        self.type = type
        self.keyboardFrameBegin = begin
        self.keyboardFrameEnd = end
        self.curve = curve
        self.duration = TimeInterval(durationDouble)
        if #available(iOS 9, *) {
            guard let isLocalInt = (userInfo[UIKeyboardIsLocalUserInfoKey] as? NSNumber)?.intValue else { return nil }
            self.isLocal = isLocalInt == 1
        }
    }
}

public enum KeyboardState {
    case initial
    case showing
    case shown
    case hiding
    case hidden
    case changing
}

public typealias KeyboardEventClosure = ((_ event: KeyboardEvent) -> Void)

open class KeyboardObserver {
    open var state = KeyboardState.initial
    open var isEnabled = true
    fileprivate var eventClosures = [KeyboardEventClosure]()
    
    deinit {
        eventClosures.removeAll()
        KeyboardEventType.allEventNames().forEach {
            NotificationCenter.default.removeObserver(self, name: $0, object: nil)
        }
    }
    
    public init() {
        KeyboardEventType.allEventNames().forEach {
            NotificationCenter.default.addObserver(self, selector: #selector(notified(_:)), name: $0, object: nil)
        }
    }
    
    open func observe(_ event: @escaping KeyboardEventClosure) {
        eventClosures.append(event)
    }
}

internal extension KeyboardObserver {
    @objc func notified(_ notification: Notification) {
        guard let event = KeyboardEvent(notification: notification) else { return }
        
        switch event.type {
        case .willShow:
            state = .showing
        case .didShow:
            state = .shown
        case .willHide:
            state = .hiding
        case .didHide:
            state = .hidden
        case .willChangeFrame:
            state = .changing
        case .didChangeFrame:
            state = .shown
        }

        if !isEnabled { return }
        eventClosures.forEach { $0(event) }
    }
}

#endif
