//
//  TPayDemoViewController.swift
//  demo
//
//  Created by Cloudpayments on 22.11.2023.
//  Copyright © 2023 Cloudpayments. All rights reserved.
//

import Foundation
import Cloudpayments
import UIKit

final class TestSinglePaymentMethodsController: UIViewController {
    private let loaderView = LoaderView()
    private lazy var stackView = UIStackView()
    private lazy var tPayView = PaymentTPayView()
    private lazy var sbpView = PaymentSbpView()
    private lazy var sberPayView = PaymentSberPayView()
    var configuration: PaymentConfiguration?
    
    override func loadView() {
        super.loadView()
        view.addSubview(loaderView)
        loaderView.fullConstraint()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addConfiguration()
        checkButtons()
        
        stackView.isHidden = true
        view.backgroundColor = .white
        view.isOpaque = false
    }
    
    private func addConfiguration() {
        tPayView.configuration = configuration
        sbpView.configuration = configuration
        sberPayView.configuration = configuration
    }
    
    private func setupViews() {
        
        tPayView.delegate = self
        sbpView.delegate = self
        sberPayView.delegate = self
        
        stackView = UIStackView(arrangedSubviews: [tPayView, sbpView, sberPayView])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        
        let tpayImageView = UIImageView(image: .iconTPay)
        tPayView.backgroundColor = .tpayButtonColor
        tPayView.layer.cornerRadius = 8
        tPayView.addSubview(tpayImageView)
        tpayImageView.contentMode = .center
        
        let sbpImageView = UIImageView(image: .iconSbp)
        sbpView.backgroundColor = .sbpButtonColor
        sbpView.layer.cornerRadius = 8
        sbpView.addSubview(sbpImageView)
        sbpImageView.contentMode = .center
        
        let sberPayImageView = UIImageView(image: .iconSberPay)
        sberPayView.backgroundColor = .sberPayButtonColor
        sberPayView.layer.cornerRadius = 8
        sberPayView.addSubview(sberPayImageView)
        sberPayImageView.contentMode = .center
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        tPayView.translatesAutoresizingMaskIntoConstraints = false
        sbpView.translatesAutoresizingMaskIntoConstraints = false
        sberPayView.translatesAutoresizingMaskIntoConstraints = false
        tpayImageView.translatesAutoresizingMaskIntoConstraints = false
        sbpImageView.translatesAutoresizingMaskIntoConstraints = false
        sberPayImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            tpayImageView.centerXAnchor.constraint(equalTo: tPayView.centerXAnchor),
            tpayImageView.centerYAnchor.constraint(equalTo: tPayView.centerYAnchor),
            
            sbpImageView.centerXAnchor.constraint(equalTo: sbpView.centerXAnchor),
            sbpImageView.centerYAnchor.constraint(equalTo: sbpView.centerYAnchor),
            
            sberPayImageView.centerXAnchor.constraint(equalTo: sberPayView.centerXAnchor),
            sberPayImageView.centerYAnchor.constraint(equalTo: sberPayView.centerYAnchor),
            
            tPayView.heightAnchor.constraint(equalToConstant: 50),
            sbpView.heightAnchor.constraint(equalToConstant: 50),
            sberPayView.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    private func checkButtons() {
        loaderView.startAnimated(LoaderType.loaderText.toString())
        self.tPayView.getMerchantConfiguration { [weak self] result in
            guard let self = self, let result = result else { return }
            
            if (configuration?.successRedirectUrl?.isEmpty ?? true),
               let successRedirectUrl = result.successRedirectUrl {
                configuration?.successRedirectUrl = successRedirectUrl
            }
            
            if (configuration?.failRedirectUrl?.isEmpty ?? true), let failRedirectUrl = result.failRedirectUrl {
                configuration?.failRedirectUrl = failRedirectUrl
            }
            
            self.tPayView.isHidden = !result.isOnTPayButton
            self.sbpView.isHidden = !result.isOnSbpButton
            self.sberPayView.isHidden = !result.isOnSberPayButton
            self.loaderView.endAnimated()
            self.loaderView.isHidden = true
            stackView.isHidden = false
        }
    }
}

extension TestSinglePaymentMethodsController: PaymentTPayDelegate {
    func resultPayment(_ tPay: Cloudpayments.PaymentTPayView, result: Cloudpayments.PaymentTPayView.PaymentAction, error: String?, transactionId: Int64?) {
        switch result {
        case .success:
            print("Оплата прошла успешно c транзакцией \(String(describing: transactionId))")
        case .error:
            print("Операция отклонена")
        case .close:
            print("Пользователь закрыл платёжную форму TPay")
        }
    }
}

extension TestSinglePaymentMethodsController: PaymentSbpDelegate {
    func resultPayment(_ sbp: Cloudpayments.PaymentSbpView, result: Cloudpayments.PaymentSbpView.PaymentAction, error: String?, transactionId: Int64?) {
        switch result {
        case .success:
            print("Оплата прошла успешно c транзакцией \(String(describing: transactionId))")
        case .error:
            print("Операция отклонена")
        case .close:
            print("Пользователь закрыл платежную форму со списком банков")
        }
    }
}

extension TestSinglePaymentMethodsController: PaymentSberPayDelegate {
    func resultPayment(_ sberPay: Cloudpayments.PaymentSberPayView, result: Cloudpayments.PaymentSberPayView.PaymentAction, error: String?, transactionId: Int64?) {
        switch result {
        case .success:
            print("Оплата прошла успешно c транзакцией \(String(describing: transactionId))")
        case .error:
            print("Операция отклонена")
        case .close:
            print("Пользователь закрыл платежную форму со SberPay")
        }
    }
}
