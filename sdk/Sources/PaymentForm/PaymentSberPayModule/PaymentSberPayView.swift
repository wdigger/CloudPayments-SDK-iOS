//
//  PaymentSberPayView.swift
//  sdk
//
//  Created by Cloudpayments on 20.05.2024.
//  Copyright © 2024 Cloudpayments. All rights reserved.
//

import UIKit

public protocol PaymentSberPayDelegate: AnyObject {
    func resultPayment(_ sberPay: PaymentSberPayView, result: PaymentSberPayView.PaymentAction, error: String?, transactionId: Int64?)
}

//MARK: - PaymentSberPayView

public final class PaymentSberPayView: UIView {
    public weak var delegate: PaymentSberPayDelegate?
    private var buttonResult: ButtonConfiguration?
    public var configuration: PaymentConfiguration! = nil
    
    //MARK: - Init
    
    public init(configuration: PaymentConfiguration! = nil) {
        super.init(frame: .infinite)
        self.configuration = configuration
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTapGesture()
    }
    
    //MARK: - Setup Tap Gesture
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(touchButton))
        addGestureRecognizer(tapGesture)
    }
    
    //MARK: - Touch Button

    @objc private func touchButton() {
        guard let configuration = configuration,
              let topVC = UIApplication.topViewController()
        else { return }
        
        if let successRedirectUrl = buttonResult?.successRedirectUrl, configuration.successRedirectUrl == nil || configuration.successRedirectUrl == "" {
            configuration.successRedirectUrl = successRedirectUrl
        }
        
        if let failRedirectUrl = buttonResult?.failRedirectUrl, configuration.failRedirectUrl == nil || configuration.failRedirectUrl == "" {
            configuration.failRedirectUrl = failRedirectUrl
        }
        
        let vc = ProgressSberPayAssembly.createSberPayVC(configuration: configuration)
        vc.delegate = self
        topVC.present(vc, animated: true)
    }
}

//MARK: - Callbacks

extension PaymentSberPayView {
    public enum PaymentAction {
        case success
        case error
        case close
    }
}

//MARK: - ProgressSberPayProtocol

extension PaymentSberPayView: ProgressSberPayProtocol {
    func resultPayment(result: PaymentAction, error: String?, transactionId: Int64?) {
        delegate?.resultPayment(self, result: result, error: error, transactionId: transactionId)
    }
}
