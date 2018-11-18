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
        UIResponder.keyboardWillShowNotification,
        UIResponder.keyboardWillHideNotification,
        UIResponder.keyboardWillChangeFrameNotification
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Notification"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        keyboardNotifications.forEach {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardEventNotified(notification:)), name: $0, object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
        let distance = UIScreen.main.bounds.height - keyboardFrameEnd.origin.y
        let bottom = distance >= bottomLayoutGuide.length ? distance : bottomLayoutGuide.length
        
        UIView.animate(withDuration: duration, delay: 0.0, options: [options], animations:
            { () -> Void in
                self.textView.contentInset.bottom = bottom
                self.textView.scrollIndicatorInsets.bottom = bottom
            } , completion: nil)
    }
}
