//
//  PaymentConfiguration.swift
//  sdk
//
//  Created by Sergey Iskhakov on 08.10.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

public class PaymentConfiguration {
    let publicId: String
    let paymentData: PaymentData
    let paymentDelegate: PaymentDelegateImpl
    let paymentUIDelegate: PaymentUIDelegateImpl
    let scanner: PaymentCardScanner?
    let requireEmail: Bool
    let useDualMessagePayment: Bool
    let disableApplePay: Bool
    let apiUrl: String
    var successRedirectUrl: String?
    var failRedirectUrl: String?
   
    public init(publicId: String, paymentData: PaymentData, delegate: PaymentDelegate? = nil, uiDelegate: PaymentUIDelegate? = nil, scanner: PaymentCardScanner? = nil,
                requireEmail: Bool = false, useDualMessagePayment: Bool = false, disableApplePay: Bool = false, apiUrl: String = "https://api.cloudpayments.ru/", successRedirectUrl: String? = nil, failRedirectUrl: String? = nil) {
        self.publicId = publicId
        self.paymentData = paymentData
        self.paymentDelegate = PaymentDelegateImpl.init(delegate: delegate)
        self.paymentUIDelegate = PaymentUIDelegateImpl.init(delegate: uiDelegate)
        self.scanner = scanner
        self.requireEmail = requireEmail
        self.useDualMessagePayment = useDualMessagePayment
        self.disableApplePay = disableApplePay
        self.apiUrl = apiUrl
        self.successRedirectUrl = successRedirectUrl
        self.failRedirectUrl = failRedirectUrl
    }
}
