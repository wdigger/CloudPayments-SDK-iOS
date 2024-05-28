//
//  PaymentSbpView.swift
//  sdk
//
//  Created by Cloudpayments on 02.05.2024.
//  Copyright © 2024 Cloudpayments. All rights reserved.
//

import UIKit
import CloudpaymentsNetworking

public protocol PaymentSbpDelegate: AnyObject {
    func resultPayment(_ sbp: PaymentSbpView, result: PaymentSbpView.PaymentAction, error: String?, transactionId: Int64?)
}

//MARK: - PaymentSbpView

public class PaymentSbpView: UIView {
    
    //MARK: - Private & Public properties
    
    public weak var delegate: PaymentSbpDelegate?
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
        
        let vc = SbpAssembly.createSbpVC(configuration: configuration, from: topVC)
        vc.delegate = self
        topVC.present(vc, animated: true)
    }
}

//MARK: - Callbacks

extension PaymentSbpView {
    public enum PaymentAction {
        case success
        case error
        case close
    }
}

//MARK: - Progress Sbp Protocol

extension PaymentSbpView: ProgressSbpPresenterProtocol {
    func resultPayment(_ result: PaymentAction, error: String?, transactionId: Int64?) {
        delegate?.resultPayment(self, result: result, error: error, transactionId: transactionId)
    }
}
