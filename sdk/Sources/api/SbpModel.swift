//
//  SbpModel.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 26.07.2023.
//

import Foundation

struct SbpQRModel: Codable {
    let version: String
    var dictionary: [SbpQRDataModel]
}

// MARK: - SbpQRDataModel
struct SbpQRDataModel: Codable {
    let bankName: String?
    let logoURL: String?
    let schema: String
    let packageName: String?
    let webClientURL: String?
    let isWebClientActive: String?

    enum CodingKeys: String, CodingKey {
        case bankName, logoURL, schema
        case packageName = "package_name"
        case webClientURL = "webClientUrl"
        case isWebClientActive
    }
    
    var deeplink: URL? {
        return URL(string: schema + "://qr.nspk.ru/")
    }
}

// MARK: - GetSbpModel
struct GetSbpModel: Codable {
    let publicId: String?
    let amount: String?
    let currency: String
    let accountId: String?
    let invoiceId: String?
    let description: String?
    let email, ipAddress: String?
    let scheme: Scheme.RawValue
    let ttlMinutes: Int?
    let saveCard: Bool?
    let jsonData: String?
    let successRedirectUrl: String?

    enum CodingKeys: String, CodingKey {
        case publicId = "PublicId"
        case amount = "Amount"
        case accountId = "AccountId"
        case invoiceId = "InvoiceId"
        case currency = "Currency"
        case description = "Description"
        case email = "Email"
        case scheme = "Scheme"
        case ipAddress = "IpAddress"
        case ttlMinutes = "TtlMinutes"
        case saveCard = "SaveCard"
        case jsonData = "JsonData"
        case successRedirectUrl = "SuccessRedirectUrl"
    }
}
