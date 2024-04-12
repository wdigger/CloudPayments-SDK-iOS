//
//  SbpModel.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 26.07.2023.
//

import Foundation

public struct SbpQRModel: Codable {
    public let version: String
    public var dictionary: [SbpQRDataModel]
}

// MARK: - SbpQRDataModel
public struct SbpQRDataModel: Codable {
    public let bankName: String?
    public let logoURL: String?
    public let schema: String
    public let packageName: String?
    public let webClientURL: String?
    public let isWebClientActive: String?

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
public struct GetSbpModel: Codable {
    public let publicId: String?
    public let amount: String?
    public let currency: String
    public let accountId: String?
    public let invoiceId: String?
    public let description: String?
    public let email, ipAddress: String?
    public let scheme: Scheme.RawValue
    public let ttlMinutes: Int?
    public let saveCard: Bool?
    public let jsonData: String?
    public let successRedirectUrl: String?
    
    public init(publicId: String?, amount: String?, currency: String, accountId: String?,
                invoiceId: String?, description: String?, email: String?, ipAddress: String?,
                scheme: Scheme.RawValue, ttlMinutes: Int?, saveCard: Bool?, jsonData: String?,
                successRedirectUrl: String?) {
        self.publicId = publicId
        self.amount = amount
        self.currency = currency
        self.accountId = accountId
        self.invoiceId = invoiceId
        self.description = description
        self.email = email
        self.ipAddress = ipAddress
        self.scheme = scheme
        self.ttlMinutes = ttlMinutes
        self.saveCard = saveCard
        self.jsonData = jsonData
        self.successRedirectUrl = successRedirectUrl
    }
    
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
