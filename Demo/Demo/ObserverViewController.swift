//
//  KeyboardObserverViewController.swift
//  Demo
//
//  Created by MORITANAOKI on 2015/12/14.
//  Copyright © 2015年 molabo. All rights reserved.
//

import UIKit

final class KeyboardObserverViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    let keyboard = KeyboardObserver()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Observer"
        
        keyboard.observe { [weak self] (event) -> Void in
            guard let s = self else { return }
            switch event.type {
            case .WillShow, .WillHide, .WillChangeFrame:
                let distance = UIScreen.mainScreen().bounds.height - event.keyboardFrameEnd.origin.y
                let bottom = distance >= s.bottomLayoutGuide.length ? distance : s.bottomLayoutGuide.length
                
                UIView.animateWithDuration(event.duration, delay: 0.0, options: [event.options], animations:
                    { [weak self] () -> Void in
                        self?.textView.contentInset.bottom = bottom
                        self?.textView.scrollIndicatorInsets.bottom = bottom
                    } , completion: nil)
            default:
                break
            }
        }
    }
}

