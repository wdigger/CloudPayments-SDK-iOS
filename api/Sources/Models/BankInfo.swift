//
//  BankInfo.swift
//  sdk
//
//  Created by Sergey Iskhakov on 09.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

public struct BankInfo: Codable {
    public let logoURL: String?
    public let convertedAmount: String?
    public let currency: String?
    public let hideCvvInput: Bool?
    public let cardType: NameCardType.RawValue?
    
    enum CodingKeys: String, CodingKey {
        case logoURL = "LogoUrl"
        case convertedAmount = "ConvertedAmount"
        case currency = "Currency"
        case hideCvvInput = "HideCvvInput"
        case cardType = "CardType"
    }
}

public enum NameCardType: String, Codable {
    case unknown = "Unknown"
    case visa = "Visa"
    case masterCard = "MasterCard"
    case maestro = "Maestro"
    case mir = "MIR"
    case jcb = "Jcb"
    case jcb15 = "Jcb15"
    case americanExpress = "AmericanExpress"
    case troy = "Troy"
    case dankort = "Dankort"
    case discover = "Discover"
    case diners = "Diners"
    case instapayments = "Instapayments"
    case humo = "Humo"
    case uatp = "Uatp"
    case unionPay = "UnionPay"
    case uzcard = "Uzcard"
    
    var string: String {
        switch self {
        case .jcb, .jcb15: return NameCardType.jcb.rawValue
        default: return rawValue
        }
    }
}
