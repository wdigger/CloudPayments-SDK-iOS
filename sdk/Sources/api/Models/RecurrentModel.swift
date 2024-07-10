//
//  RecurrentModel.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 10.07.2023.
//

import Foundation

struct CloudPaymentsModel: Codable {
    let cloudPayments: CloudPayments?
}

struct CloudPayments: Codable {
    let recurrent: Recurrent?
}

struct Recurrent: Codable {
    let interval, period: String?
    let amount: Int?
}
