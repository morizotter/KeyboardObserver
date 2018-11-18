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
        
        navigationItem.title = "Observer"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.rightButtonDidTap))
    }
    
    @objc func rightButtonDidTap() {
        let message = keyboard.isEnabled ? "Disable keyboard observing?" : "Enable keyboard ovserving?"
        
        let controller = UIAlertController(title: "Keyboard observing", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { [unowned self] _ in
            self.keyboard.isEnabled = !self.keyboard.isEnabled
        }))
        present(controller, animated: true, completion: nil)
    }
}

