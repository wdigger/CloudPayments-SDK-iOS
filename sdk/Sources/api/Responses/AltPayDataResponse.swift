//
//  AltPayDataResponse.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 02.07.2024.
//

import Foundation

struct AltPayDataResponse: Codable {
    let model: AltPayTransactionResponse?
    let success: Bool
    let message: String?

    enum CodingKeys: String, CodingKey {
        case model = "Model"
        case success = "Success"
        case message = "Message"
    }
}

public struct AltPayTransactionResponse: Codable {
    let qrURL: String?
    let transactionId: Int64?
    let providerQrId: String?
    let amount: Int?
    let message: String?
    let isTest: Bool?
    var banks: SbpBanksList?

    enum CodingKeys: String, CodingKey {
        case qrURL = "QrUrl"
        case transactionId = "TransactionId"
        case providerQrId = "ProviderQrId"
        case amount = "Amount"
        case message = "Message"
        case isTest = "IsTest"
        case banks = "Banks"
    }
    
    init(qrURL: String?, transactionId: Int64?, amount: Int?, message: String?, isTest: Bool?, banks: SbpBanksList? = nil, providerQrId: String? = nil) {
        self.qrURL = qrURL
        self.transactionId = transactionId
        self.amount = amount
        self.message = message
        self.isTest = isTest
        self.banks = banks
        self.providerQrId = providerQrId
    }
}
