//
//  Button.swift
//  sdk
//
//  Created by Sergey Iskhakov on 17.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import UIKit

class Button: UIButton {
    var onAction: (()->())?
    
    @IBInspectable var borderWidth : CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth;
        }
    }
    @IBInspectable var borderColor : UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    @IBInspectable var cornerRadius : CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    func setAlpha(_ alpha: CGFloat) {
        self.alpha = alpha
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(onAction(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(onAction(_:)), for: .touchUpInside)
    }
    
    @objc func onAction(_ sender: Any) {
        if self.onAction != nil {
            self.onAction!()
        }
    }
}

extension UIButton {
    
    convenience init(_ color: UIColor,
                     _ cornerRadius: CGFloat,
                     _ borderWidth: CGFloat,
                     _ buttonText: String,
                     _ textColor: UIColor) {
        self.init()
        self.layer.borderColor = color.cgColor
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderWidth
        self.setTitle(buttonText, for: .normal)
        self.setTitleColor(textColor, for: .normal)
    }
}
