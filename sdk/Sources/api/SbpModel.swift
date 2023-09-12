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

    enum CodingKeys: String, CodingKey {
        case bankName, logoURL, schema
        case packageName = "package_name"
    }
    
    var deeplink: URL? {
        return URL(string: schema + "://qr.nspk.ru/")
    }
}

// MARK: - GetSbpModel
struct GetSbpModel: Codable {
    let device: String
    let amount: String
    let currency: String
    let publicId: String?
    let scheme: Scheme.RawValue
//    let accountId: String?
    let invoiceId: String?
//    let description: String?
    let email, ipAddress: String?
    let ttlMinutes: Int?
    let successRedirectURL: String?
    let failRedirectURL: String?
    let saveCard: Bool?

    enum CodingKeys: String, CodingKey {
        case publicId = "PublicId"
        case device = "Device"
        case amount = "Amount"
        //        case accountId = "AccountId"
        case invoiceId = "InvoiceId"
        case currency = "Currency"
        //        case description = "Description"
        case email = "Email"
        case scheme = "Scheme"
        case ipAddress = "IpAddress"
        case ttlMinutes = "TtlMinutes"
        case successRedirectURL = "SuccessRedirectUrl"
        case failRedirectURL = "FailRedirectUrl"
        case saveCard = "SaveCard"
    }
}
