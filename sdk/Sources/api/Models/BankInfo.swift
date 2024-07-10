//
//  BankInfo.swift
//  sdk
//
//  Created by Sergey Iskhakov on 09.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

public struct BankInfo: Codable {
    let logoURL: String?
    let convertedAmount: String?
    let currency: String?
    let hideCvvInput: Bool?
    let cardType: NameCardType.RawValue?
    
    enum CodingKeys: String, CodingKey {
        case logoURL = "LogoUrl"
        case convertedAmount = "ConvertedAmount"
        case currency = "Currency"
        case hideCvvInput = "HideCvvInput"
        case cardType = "CardType"
    }
}


