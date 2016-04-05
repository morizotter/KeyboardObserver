//
//  KeyboardNotificationViewController.swift
//  Demo
//
//  Created by MORITANAOKI on 2015/12/14.
//  Copyright © 2015年 molabo. All rights reserved.
//

import UIKit

class KeyboardNotificationViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    let keyboardNotifications = [
        UIKeyboardWillShowNotification,
        UIKeyboardWillHideNotification,
        UIKeyboardWillChangeFrameNotification
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Notification"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        keyboardNotifications.forEach {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardEventNotified(_:)), name: $0, object: nil)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        keyboardNotifications.forEach {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: $0, object: nil)
        }
    }
    
    func keyboardEventNotified(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        let keyboardFrameEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let curve = UIViewAnimationOptions(rawValue: UInt(userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber))
        let duration = NSTimeInterval(userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber)
        let distance = UIScreen.mainScreen().bounds.height - keyboardFrameEnd.origin.y
        let bottom = distance >= bottomLayoutGuide.length ? distance : bottomLayoutGuide.length
        
        UIView.animateWithDuration(duration, delay: 0.0, options: [curve], animations:
            { [weak self] () -> Void in
                self?.textView.contentInset.bottom = bottom
                self?.textView.scrollIndicatorInsets.bottom = bottom
            } , completion: nil)
    }
}
