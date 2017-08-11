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
            guard let s = self else { return }
            switch event.type {
            case .willShow, .willHide, .willChangeFrame:
                print("Fire: \(event.type)")
                let distance = UIScreen.main.bounds.height - event.keyboardFrameEnd.origin.y
                let bottom = distance >= s.bottomLayoutGuide.length ? distance : s.bottomLayoutGuide.length
                
                UIView.animate(withDuration: event.duration, delay: 0.0, options: [event.options], animations: { () -> Void in
                    s.textView.contentInset.bottom = bottom
                    s.textView.scrollIndicatorInsets.bottom = bottom
                    }, completion: nil)
            default:
                break
            }
        }
        
        navigationItem.title = "Observer"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.rightButtonDidTap))
    }
    
    func rightButtonDidTap() {
        let message = keyboard.isEnabled ? "Disable keyboard observing?" : "Enable keyboard ovserving?"
        
        let controller = UIAlertController(title: "Keyboard observing", message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: { [unowned self] _ in
            self.keyboard.isEnabled = !self.keyboard.isEnabled
        }))
        present(controller, animated: true, completion: nil)
    }
}

