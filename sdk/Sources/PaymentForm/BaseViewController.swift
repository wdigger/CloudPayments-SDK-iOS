//
//  BaseViewController.swift
//  sdk
//
//  Created by Sergey Iskhakov on 21.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import UIKit

public class BaseViewController: UIViewController {
    // MARK: - Public Properties
    var isKeyboardShowing: Bool = false
    var keyboardFrame: CGRect = .zero
    
    // MARK: - Public methods
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow(_:)), name: UITextField.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide(_:)), name: UITextField.keyboardWillHideNotification, object: nil)
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    // MARK: - Internal methods
    @objc internal func onKeyboardWillShow(_ notification: Notification) {
        self.isKeyboardShowing = true
        self.keyboardFrame = (notification.userInfo?[UITextField.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
    }
    
    @objc internal func onKeyboardWillHide(_ notification: Notification) {
        self.isKeyboardShowing = false
        self.keyboardFrame = .zero
    }
}

extension BaseViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /* Shows default OK action if actions is nil */
    func showAlert(title: String?, message: String?, completion: (() -> Void)? = nil, shouldDismiss: (() -> Bool)? = nil) {
        let alert = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            if let shouldDismiss = shouldDismiss, shouldDismiss() {
                self.dismiss(animated: true, completion: nil)
            } else {
                completion?()
            }
        }
        
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
