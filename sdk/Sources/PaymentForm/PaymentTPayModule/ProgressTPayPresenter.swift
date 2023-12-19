//
//  ProgressTPayPresenter.swift
//  sdk
//
//  Created by Cloudpayments on 15.11.2023.
//  Copyright © 2023 Cloudpayments. All rights reserved.
//

import Foundation

protocol ProgressTPayProtocol: AnyObject {
    func resultPayment(result: PaymentTPayView.PaymentAction, error: String?, transactionId: Int64?)
}

protocol ProgressTPayViewControllerProtocol: AnyObject {
    func resultPayment(result: PaymentTPayView.PaymentAction, error: String?, transactionId: Int64?)
    func openLinkURL(url: URL)
}

final class ProgressTPayPresenter {
    
    //MARK: - Properties
    
    private let configuration: PaymentConfiguration
    private var transactionId: Int64?
    weak var view: ProgressTPayViewControllerProtocol?
    
    //MARK: - Init
    
    init(configuration: PaymentConfiguration) {
        self.configuration = configuration
    }
    
    //MARK: - Private Methods
    
    private func checkTransactionId() {
        let publicId = configuration.publicId
        guard let transactionId = transactionId else { return }
    
        NotificationCenter.default.removeObserver(self, name: ObserverKeys.tinkoffPayStatus.key, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(observerStatus(_:)),
                                               name: ObserverKeys.tinkoffPayStatus.key, object: nil)
        CloudpaymentsApi.waitStatus(transactionId,publicId)
    }

    @objc private func observerStatus(_ notification: NSNotification) {
        
        guard let result = notification.object as? ResponseTransactionModel,
              let rawValue = result.model?.status,
              let status = StatusPay(rawValue: rawValue)
        else {
            if let error = notification.object as? Error {
                let code = error._code < 0 ? -error._code : error._code
                if code > 1000 {checkTransactionId(); return }
                let string = String(code)
                let description = ApiError.getFullErrorDescription(code: string)
                view?.resultPayment(result: .error, error: description, transactionId: nil)
                return
            }
            
            checkTransactionId()
            return
        }
        
        switch status {
        case .created, .pending:
            checkTransactionId()
            
        case .authorized, .completed, .cancelled:
            let id = transactionId
            transactionId = nil
            NotificationCenter.default.removeObserver(self, name: ObserverKeys.tinkoffPayStatus.key, object: nil)
            self.view?.resultPayment(result: .success, error: nil, transactionId: id)
            
        case .declined:
            transactionId = nil
            let error = notification.object as? Error
            let code = error?._code
            let string = code == nil ? "" : String(code!)
            let descriptionError = ApiError.getFullErrorDescription(code: string)
            view?.resultPayment(result: .error, error: descriptionError, transactionId: nil)
        }
    }
}

//MARK: Input

extension ProgressTPayPresenter: ProgressTPayPresenterProtocol {
    func getLink() {
        CloudpaymentsApi.getTinkoffPayLink(with: configuration) { [weak self] result in
            guard let self = self, let transactionId = result?.transactionId, let string = result?.qrURL, let url = URL(string: string) else {
                self?.view?.resultPayment(result: .error, error: result?.message, transactionId: nil)
                return
            }
            
            let message = result?.message
            self.transactionId = transactionId
            
            var status: StatusPay {
                guard let message = message, let value = StatusPay(rawValue: message) else { return .declined }
                return value
            }
            
            switch status {
            case .created, .pending:
                self.checkTransactionId()
            default:
                return
            }
            
            self.view?.openLinkURL(url: url)
        }
    }
}
