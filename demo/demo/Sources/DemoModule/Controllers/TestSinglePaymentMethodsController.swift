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
    private lazy var tinkoffView = PaymentTPayView()
    private lazy var sbpView = PaymentSbpView()
    private lazy var tinkoffLabel = UILabel()
    private lazy var sbpLabel = UILabel()
    private let merchantPublicId = "test_api_00000000000000000000002" // ваш Public_id
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addConfiguration()
        checkButtons()
        
        view.backgroundColor = .white
        view.isOpaque = false
    }
    
    private func addConfiguration() {
        
        let jsonObject: [String: Any?] = [:]

        func JSONStringify(value: [String: Any?], prettyPrinted:Bool = false) -> String {
          let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
          if JSONSerialization.isValidJSONObject(value) {
            do {
              let data = try JSONSerialization.data(withJSONObject: value, options: options)
              if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                return string as String
              }
            } catch {

              print("parsing error")
            }
          }
          return ""
        }

        let dataString = JSONStringify(value: jsonObject)
        
        let paymentData = PaymentData()
          .setAmount("10")
          .setCurrency("RUB")
          .setDescription("Корзина цветов")
          .setAccountId("111")
          .setInvoiceId("123")
          .setEmail("test@cp.ru")
          .setJsonData(dataString)
        
        let configuration = PaymentConfiguration(
          publicId: merchantPublicId,
          paymentData: paymentData,
          useDualMessagePayment: true,
          saveCardForSinglePaymentMode: false)
        
        tinkoffView.configuration = configuration
        sbpView.configuration = configuration
    }
    
    private func setupViews() {
        
        tinkoffView.delegate = self
        sbpView.delegate = self
        
        view.addSubview(tinkoffView)
        tinkoffView.addSubview(tinkoffLabel)
        
        view.addSubview(sbpView)
        sbpView.addSubview(sbpLabel)
    
        tinkoffView.backgroundColor = .black
        tinkoffView.layer.cornerRadius = 8
        
        sbpView.backgroundColor = .systemPink
        sbpView.layer.cornerRadius = 8

        tinkoffLabel.text = "Тинькофф Pay"
        tinkoffLabel.textColor = .white
        
        sbpLabel.text = "СБП"
        sbpLabel.textColor = .white
        
        tinkoffView.translatesAutoresizingMaskIntoConstraints = false
        sbpView.translatesAutoresizingMaskIntoConstraints = false
        tinkoffLabel.translatesAutoresizingMaskIntoConstraints = false
        sbpLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tinkoffView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tinkoffView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tinkoffView.heightAnchor.constraint(equalToConstant: 50),
            tinkoffView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            tinkoffLabel.centerXAnchor.constraint(equalTo: tinkoffView.centerXAnchor),
            tinkoffLabel.centerYAnchor.constraint(equalTo: tinkoffView.centerYAnchor),
            
            sbpView.topAnchor.constraint(equalTo: tinkoffView.bottomAnchor, constant: 20),
            sbpView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sbpView.heightAnchor.constraint(equalToConstant: 50),
            sbpView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            sbpView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            sbpLabel.centerXAnchor.constraint(equalTo: sbpView.centerXAnchor),
            sbpLabel.centerYAnchor.constraint(equalTo: sbpView.centerYAnchor),
        ])
    }
    
    private func checkButtons() {
        tinkoffView.getMerchantConfiguration(publicId: merchantPublicId) { [ weak self ] result in
            guard let self = self, let result = result else { return }
            self.tinkoffView.isHidden = !result.isOnTinkoffButton
            self.sbpView.isHidden = !result.isOnSbpButton
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
