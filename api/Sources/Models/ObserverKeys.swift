//
//  ObserverKeys.swift
//  sdk
//
//  Created by Cloudpayments on 16.08.2023.
//  Copyright © 2023 Cloudpayments. All rights reserved.
//

import Foundation

public enum ObserverKeys: String {
    case tinkoffPayStatus = "TinkoffStatusPayObserver"
    case qrPayStatus = "QRStatusPayObserver"
    case networkConnectStatus = "NetworkConnectStatusObserver"
    
    public var key: NSNotification.Name {
        return NSNotification.Name(rawValue: rawValue)
    }
}
