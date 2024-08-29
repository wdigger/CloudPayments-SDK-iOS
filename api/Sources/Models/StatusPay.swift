//
//  StatusPay.swift
//  sdk
//
//  Created by Cloudpayments on 12.09.2023.
//  Copyright © 2023 Cloudpayments. All rights reserved.
//

import Foundation

public enum StatusPay: String {
    case created = "Created"
    case pending = "Pending"
    case authorized = "Authorized"
    case completed = "Completed"
    case cancelled = "Cancelled"
    case declined = "Declined"
}
