//
//  UIImage+Assets.swift
//  sdk
//
//  Created by Sergey Iskhakov on 24.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import UIKit

extension UIImage {
    public class func named(_ name: String) -> UIImage {
        
        let image2 = UIImage.init(named: name, in: Bundle.mainSdk, compatibleWith: nil)
        if image2 != nil {
            return image2!
        }
        return UIImage()
    }
}
