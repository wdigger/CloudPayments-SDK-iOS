//
//  TPayDemoViewController.swift
//  demo
//
//  Created by Cloudpayments on 22.11.2023.
//  Copyright © 2023 Cloudpayments. All rights reserved.
//

import Foundation
import Cloudpayments

final class TPayDemoViewController: UIViewController {
    private lazy var tinkoffView = PaymentTPayView()
    private lazy var tinkoffLabel = UILabel()
    private let merchantPublicId = "" // ваш Public_id
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTinkoffView()
        addConfiguration()
        checkTPayView()
        
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
          useDualMessagePayment: true)
        
        tinkoffView.configuration = configuration
    }
    
    private func setupTinkoffView() {
        
        tinkoffView.delegate = self
        
        view.addSubview(tinkoffView)
        tinkoffView.addSubview(tinkoffLabel)
        
        tinkoffView.backgroundColor = .black
        tinkoffView.layer.cornerRadius = 8
        
        tinkoffLabel.text = "Тинькофф Pay"
        tinkoffLabel.textColor = .white
        
        tinkoffView.translatesAutoresizingMaskIntoConstraints = false
        tinkoffLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tinkoffView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tinkoffView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tinkoffView.heightAnchor.constraint(equalToConstant: 50),
            tinkoffView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            tinkoffLabel.centerXAnchor.constraint(equalTo: tinkoffView.centerXAnchor),
            tinkoffLabel.centerYAnchor.constraint(equalTo: tinkoffView.centerYAnchor)
        ])
    }
    
    private func checkTPayView() {
        tinkoffView.getMerchantConfiguration(publicId: merchantPublicId) { [ weak self ] result in
            guard let self = self, let result = result else { return }
            self.tinkoffView.isHidden = !result.isOnButton         }
    }
}

extension TPayDemoViewController: PaymentTPayDelegate {
    func resultPayment(_ tPay: Cloudpayments.PaymentTPayView, result: Cloudpayments.PaymentTPayView.PaymentAction, error: String?, transactionId: Int64?) {
        switch result {
        case .success:
            print("Оплата прошла успешно")
        case .error:
            print("Ошибка")
        case .close:
            print("Пользователь закрыл платёжную форму TinkoffPay")
        }
    }
}
