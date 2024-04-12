//
//  RecurrentModel.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 10.07.2023.
//

import Foundation

// MARK: - CloudPaymentsModel
public struct CloudPaymentsModel: Codable {
    public let cloudPayments: CloudPayments?
}

// MARK: - CloudPayments
public struct CloudPayments: Codable {
    public let recurrent: Recurrent?
}

// MARK: - Recurrent
public struct Recurrent: Codable {
    public let interval, period: String?
    public let amount: Int?
}
