//
//  PaymentDelegate.swift
//  sdk
//
//  Created by Sergey Iskhakov on 08.10.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

public protocol PaymentDelegate: AnyObject {
    func onPaymentFinished(_ transactionId: Int64?)
    func onPaymentFailed(_ errorMessage: String?)
}

public protocol PaymentUIDelegate: AnyObject {
    func paymentFormWillDisplay()
    func paymentFormDidDisplay()
    func paymentFormWillHide()
    func paymentFormDidHide()
}

public class PaymentDelegateImpl {
    weak var delegate: PaymentDelegate?
    
    init(delegate: PaymentDelegate?) {
        self.delegate = delegate
    }
    
    public func paymentFinished(_ transaction: Transaction?){
        self.delegate?.onPaymentFinished(transaction?.transactionId)
    }
    
    public func paymentFailed(_ errorMessage: String?) {
        self.delegate?.onPaymentFailed(errorMessage)
    }
}

public class PaymentUIDelegateImpl {
    weak var delegate: PaymentUIDelegate?
    
    init(delegate: PaymentUIDelegate?) {
        self.delegate = delegate
    }
    
    public func paymentFormWillDisplay() {
        self.delegate?.paymentFormWillDisplay()
    }
    
    public func paymentFormDidDisplay() {
        self.delegate?.paymentFormDidDisplay()
    }
    
    public func paymentFormWillHide() {
        self.delegate?.paymentFormWillHide()
    }
    
    public func paymentFormDidHide() {
        self.delegate?.paymentFormDidHide()
    }
}
