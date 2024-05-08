//
//  ProgressSbpPresenter.swift
//  sdk
//
//  Created by Cloudpayments on 02.05.2024.
//  Copyright © 2024 Cloudpayments. All rights reserved.
//

import Foundation

protocol ProgressSbpViewControllerProtocol: AnyObject {
    func resultPayment(result: PaymentSbpView.PaymentAction, error: String?, transaction: Transaction?)
    func tableViewReloadData()
    func openBanksApp(_ url: URL)
    func openSafariViewController(_ url: URL)
    func presentError(_ error: String?)
}

final class ProgressSbpPresenter {
    
    //MARK: - Properties
    
    let configuration: PaymentConfiguration
    let payResponse: QrPayResponse
    var sbpBanks: [SbpQRDataModel] { payResponse.banks?.dictionary ?? [] }
    private (set) var filteredBanks: [SbpQRDataModel] = []
    weak var view: ProgressSbpViewControllerProtocol?
    
    //MARK: - Init
    
    init(configuration: PaymentConfiguration, payResponse: QrPayResponse) {
        self.payResponse = payResponse
        self.configuration = configuration
    }
    
    //MARK: - Private Methods
    
    private func setupLinkForBank(value: SbpQRDataModel) {
        guard let qrURL = payResponse.qrURL else { return }
        var stringUri = qrURL
        
        if let _ = value.isWebClientActive, let webClientURL = value.webClientURL, let providerQrId = payResponse.providerQrId {
            stringUri = "\(webClientURL)/\(providerQrId)"
            openSafariViewController(stringUri)
        } else {
            stringUri = qrURL.replacingOccurrences(of: "https", with: value.schema)
            openBanksApp(stringUri)
        }
    }
    
    private func openBanksApp(_ url: String) {
        guard let finalURL = URL(string: url) else { return }
        view?.openBanksApp(finalURL)
    }
    
    private func openSafariViewController(_ string: String) {
        guard let finalURL = URL(string: string) else { return }
        view?.openSafariViewController(finalURL)
        checkSbpTransactionId()
    }
    
    private func checkNotificationError(_ notification: NSNotification) -> Bool {
        guard let error = notification.object as? Error else { return false }
        let code = error._code < 0 ? -error._code : error._code
        if code >= 1000 {checkSbpTransactionId(); return true}
        let string = String(code)
        let descriptionError = ApiError.getFullErrorDescription(code: string)
        view?.presentError(descriptionError)
        return true
    }
    
    @objc private func observerPayStatus(_ notification: NSNotification) {
        
        guard let result = notification.object as? ResponseTransactionModel else {
            _ = checkNotificationError(notification)
            return
        }
        
        guard let rawValue = result.model?.status, let status = StatusPay(rawValue: rawValue) else {
            
            if result.success ?? false {
                checkSbpTransactionId()
            } else {
                if checkNotificationError(notification) { return }
                let descriptionError = ApiError.getFullErrorDescription(code: "0")
                view?.presentError(descriptionError)
            }
            
            return
        }
        
        switch status {
        case .created, .pending:
            checkSbpTransactionId()
            
        case .authorized, .completed, .cancelled:
            removePayObserver()
            let transaction = Transaction(transactionId: payResponse.transactionId)
            
            view?.resultPayment(result: .success, error: nil, transaction: transaction)
            
        case .declined:
            removePayObserver()
            let error = notification.object as? Error
            let code = error?._code
            let string = code == nil ? "" : String(code!)
            let descriptionError = ApiError.getFullErrorDescription(code: string)
            view?.presentError(descriptionError)
        }
    }
}

//MARK: Input

extension ProgressSbpPresenter {
    
    func viewDidLoad() {
        filteredBanks = sbpBanks
    }
    
    func didSelectRow(_ row: Int) {
        let value = filteredBanks[row]
        setupLinkForBank(value: value)
    }
    
    
    func removePayObserver() {
        NotificationCenter.default.removeObserver(self, name: ObserverKeys.qrPayStatus.key, object: nil)
    }
    
    func editingSearchBar(_ text: String) {
        if text.isEmpty {
            filteredBanks = sbpBanks
        } else {
            filteredBanks = sbpBanks.filter { item in
                guard let bankName = item.bankName else { return false }
                return bankName.lowercased().contains(text.lowercased())
            }
        }
        
        view?.tableViewReloadData()
    }
    
    func checkSbpTransactionId() {
        guard let id = payResponse.transactionId else { return }
        removePayObserver()
        
        let url = configuration.apiUrl
        let publicId = configuration.publicId
        //QRStatusPayObserver
        NotificationCenter.default.addObserver(self, selector: #selector(observerPayStatus(_:)),
                                               name: ObserverKeys.qrPayStatus.key, object: nil)
        SbpRequest.getStatusSBPPay(baseURL: url, publicId: publicId, transactionId: id)
    }
}
