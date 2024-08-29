//
//  Bundle+Extenstions.swift
//  sdk
//
//  Created by Sergey Iskhakov on 16.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import UIKit

extension Bundle {
    class var mainSdk: Bundle {
        let bundle = Bundle.init(for: AuthRequest.self)
        var bundleUrl = bundle.url(forResource: "CloudpaymentsSDK", withExtension: "bundle")
        if bundleUrl == nil {
            bundleUrl = bundle.url(forResource: "CloudPayments_CloudpaymentsSDK", withExtension: "bundle")
        }
        return Bundle.init(url: bundleUrl!)!
    }
    
    class var cocoapods: Bundle? {
        return Bundle(identifier: "org.cocoapods.Cloudpayments")
    }
}
