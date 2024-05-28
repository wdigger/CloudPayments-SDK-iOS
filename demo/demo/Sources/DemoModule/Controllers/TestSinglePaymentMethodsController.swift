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
    private lazy var stackView = UIStackView()
    private lazy var tinkoffView = PaymentTPayView()
    private lazy var sbpView = PaymentSbpView()
    private lazy var sberPayView = PaymentSberPayView()
    private lazy var tinkoffLabel = UILabel()
    private lazy var sbpLabel = UILabel()
    private lazy var sberPayLabel = UILabel()
    var configuration: PaymentConfiguration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addConfiguration()
        checkButtons()
        
        view.backgroundColor = .white
        view.isOpaque = false
    }
    
    private func addConfiguration() {
        tinkoffView.configuration = configuration
        sbpView.configuration = configuration
        sberPayView.configuration = configuration
    }
    
    private func setupViews() {
        
        tinkoffView.delegate = self
        sbpView.delegate = self
        sberPayView.delegate = self
        
        stackView = UIStackView(arrangedSubviews: [tinkoffView, sbpView, sberPayView])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        tinkoffView.addSubview(tinkoffLabel)
        sbpView.addSubview(sbpLabel)
        sberPayView.addSubview(sberPayLabel)
        
        tinkoffView.backgroundColor = .black
        tinkoffView.layer.cornerRadius = 8
        
        sbpView.backgroundColor = .systemPink
        sbpView.layer.cornerRadius = 8
        
        sberPayView.backgroundColor = .systemGreen
        sberPayView.layer.cornerRadius = 8
        
        tinkoffLabel.text = "Тинькофф Pay"
        tinkoffLabel.textColor = .white
        
        sbpLabel.text = "СБП"
        sbpLabel.textColor = .white
        
        sberPayLabel.text = "SberPay"
        sberPayLabel.textColor = .white
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        tinkoffView.translatesAutoresizingMaskIntoConstraints = false
        sbpView.translatesAutoresizingMaskIntoConstraints = false
        sberPayView.translatesAutoresizingMaskIntoConstraints = false
        tinkoffLabel.translatesAutoresizingMaskIntoConstraints = false
        sbpLabel.translatesAutoresizingMaskIntoConstraints = false
        sberPayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            tinkoffView.heightAnchor.constraint(equalToConstant: 50),
            tinkoffLabel.centerXAnchor.constraint(equalTo: tinkoffView.centerXAnchor),
            tinkoffLabel.centerYAnchor.constraint(equalTo: tinkoffView.centerYAnchor),
            
            sbpView.heightAnchor.constraint(equalToConstant: 50),
            sbpLabel.centerXAnchor.constraint(equalTo: sbpView.centerXAnchor),
            sbpLabel.centerYAnchor.constraint(equalTo: sbpView.centerYAnchor),
            
            sberPayView.heightAnchor.constraint(equalToConstant: 50),
            sberPayLabel.centerXAnchor.constraint(equalTo: sberPayView.centerXAnchor),
            sberPayLabel.centerYAnchor.constraint(equalTo: sberPayView.centerYAnchor),
        ])
    }
    
    private func checkButtons() {
        tinkoffView.getMerchantConfiguration { [ weak self ] result in
            guard let self = self, let result = result else { return }
            self.tinkoffView.isHidden = !result.isOnTinkoffButton
            self.sbpView.isHidden = !result.isOnSbpButton
            self.sberPayView.isHidden = !result.isOnSberPayButton
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
            print("Пользователь закрыл платёжную форму TinkoffPay")
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
