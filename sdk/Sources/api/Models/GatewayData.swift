//
//  TinkoffPayData.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 19.06.2023.
//

import Foundation

enum Scheme: String, Codable {
    case charge = "0"
    case auth = "1"
}

// MARK: - TinkoffPayData
struct TinkoffPayData: Codable {
    let publicId: String?
    let amount: String?
    let accountId: String?
    let invoiceId: String?
    let browser: String?
    let description: String?
    let currency: String?
    let email, ipAddress, os: String?
    let scheme: Scheme.RawValue
    let ttlMinutes: Int?
    let successRedirectURL: String?
    let failRedirectURL: String?
    let saveCard: Bool?
    let jsonData: String?

    enum CodingKeys: String, CodingKey {
        case publicId = "PublicId"
        case amount = "Amount"
        case accountId = "AccountId"
        case invoiceId = "InvoiceId"
        case browser = "Browser"
        case currency = "Currency"
        case description = "Description"
        case email = "Email"
        case ipAddress = "IpAddress"
        case os = "Os"
        case scheme = "Scheme"
        case ttlMinutes = "TtlMinutes"
        case successRedirectURL = "SuccessRedirectUrl"
        case failRedirectURL = "FailRedirectUrl"
        case saveCard = "SaveCard"
        case jsonData = "JsonData"
    }
}

// MARK: - TinkoffResultPayData
struct TinkoffResultPayData: Codable {
    let model: QrPayResponse?
    let success: Bool
    let message: String?

    enum CodingKeys: String, CodingKey {
        case model = "Model"
        case success = "Success"
        case message = "Message"
    }
}

struct QrResponseModel: Codable {
    let model: QrPayResponse
    let success: Bool
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case model = "Model"
        case success = "Success"
        case message = "Message"
    }
}


// MARK: - QrPayResponse
public struct QrPayResponse: Codable {
    let qrURL: String?
    let transactionId: Int64?
    let providerQrId: String?
    let amount: Int?
    let message: String?
    let isTest: Bool?
    var banks: SbpQRModel?

    enum CodingKeys: String, CodingKey {
        case qrURL = "QrUrl"
        case transactionId = "TransactionId"
        case providerQrId = "ProviderQrId"
        case amount = "Amount"
        case message = "Message"
        case isTest = "IsTest"
        case banks = "Banks"
    }
    
    init(qrURL: String?, transactionId: Int64?, amount: Int?, message: String?, isTest: Bool?, banks: SbpQRModel? = nil, providerQrId: String? = nil) {
        self.qrURL = qrURL
        self.transactionId = transactionId
        self.amount = amount
        self.message = message
        self.isTest = isTest
        self.banks = banks
        self.providerQrId = providerQrId
    }
}

// MARK: - RepsonseTransactionModel
struct ResponseTransactionModel: Codable {
    let success: Bool?
    let message: String?
    let model: ResponseStatusModel?
    
    enum CodingKeys: String, CodingKey {
        case success = "Success"
        case message = "Message"
        case model = "Model"
    }
}

// MARK: - RepsonseStatusModel
struct ResponseStatusModel: Codable {
    let transactionId: Int64?
    let status: StatusPay.RawValue?
    let statusCode: Int?
    let providerQrId: String?
    
    enum CodingKeys: String, CodingKey {
        case transactionId = "TransactionId"
        case status = "Status"
        case statusCode = "StatusCode"
        case providerQrId = "ProviderQrId"
    }
}

