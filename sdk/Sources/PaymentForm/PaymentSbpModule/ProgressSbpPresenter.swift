//
//  ProgressSbpPresenter.swift
//  sdk
//
//  Created by Cloudpayments on 02.05.2024.
//  Copyright © 2024 Cloudpayments. All rights reserved.
//

import Foundation

protocol ProgressSbpViewControllerProtocol: AnyObject {
    func resultPayment(result: PaymentSbpView.PaymentAction, error: String?, transactionId: Transaction?)
    func tableViewReloadData()
    func openBanksApp(_ url: URL)
    func openSafariViewController(_ url: URL)
    func presentError(_ error: String?)
    func showAlert(message: String?, title: String?)
    var loading: Bool { get set }
}

final class ProgressSbpPresenter {
    
    //MARK: - Properties
    
    private (set) var configuration: PaymentConfiguration
    private (set) var altPayTransactionResponse: AltPayTransactionResponse?
    private var sbpBanks: [SbpData] { altPayTransactionResponse?.banks?.dictionary ?? [] }
    private (set) var filteredBanks: [SbpData] = []
    weak var view: ProgressSbpViewControllerProtocol?
    
    //MARK: - Init
    
    init(configuration: PaymentConfiguration) {
        self.configuration = configuration
    }
    
    //MARK: - Private Methods
    
    private func getSbpLink() {
        
        view?.loading = true
        
        CloudpaymentsApi.getSbpLink(with: configuration) { [weak self] result in
            guard let self = self else { return }
            
            guard let result = result else {
                self.view?.loading = false
                view?.showAlert(message: .errorWord, title: .anotherPaymentMethod)
                return
            }
            
            altPayTransactionResponse = result
            filteredBanks = sbpBanks
            view?.loading = false
            view?.tableViewReloadData()
        }
        
    }
    
    private func setupLinkForBank(value: SbpData) {
    
        guard let qrURL = altPayTransactionResponse?.qrURL else { return }
        
        var stringUri = qrURL
        
        if let _ = value.isWebClientActive, let webClientURL = value.webClientURL, let providerQrId = altPayTransactionResponse?.providerQrId {
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
        checkTransactionId()
    }
    
    private func checkNotificationError(_ notification: NSNotification) -> Bool {
        guard let error = notification.object as? Error else { return false }
        let code = error._code < 0 ? -error._code : error._code
        if code >= 1000 {checkTransactionId(); return true}
        let string = String(code)
        let descriptionError = ApiError.getFullErrorDescription(code: string)
        view?.presentError(descriptionError)
        return true
    }
    
    @objc private func observerPayStatus(_ notification: NSNotification) {
        
        guard let transactionStatus = notification.object as? TransactionStatusResponse else {
            _ = checkNotificationError(notification)
            return
        }
        
        guard let rawValue = transactionStatus.model?.status, let status = StatusPay(rawValue: rawValue) else {
            
            if transactionStatus.success ?? false {
                checkTransactionId()
            } else {
                if checkNotificationError(notification) { return }
                let descriptionError = ApiError.getFullErrorDescription(code: "0")
                view?.presentError(descriptionError)
            }
            
            return
        }
        
        switch status {
            
        case .created, .pending:
            checkTransactionId()
            
        case .authorized, .completed, .cancelled:
            removePayObserver()
            let transactionId = Transaction(transactionId: altPayTransactionResponse?.transactionId)
            view?.resultPayment(result: .success, error: nil, transactionId: transactionId)
            
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
        getSbpLink()
    }
    
    func didSelectRow(_ row: Int) {
        let value = filteredBanks[row]
        setupLinkForBank(value: value)
    }
    
    func removePayObserver() {
        NotificationCenter.default.removeObserver(self, name: ObserverKeys.generalObserver.key, object: nil)
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
    
    func checkTransactionId() {
        guard let transactionId = altPayTransactionResponse?.transactionId else { return }
        removePayObserver()
        
        let publicId = configuration.publicId
        NotificationCenter.default.addObserver(self, selector: #selector(observerPayStatus(_:)),
                                               name: ObserverKeys.generalObserver.key, object: nil)
        CloudpaymentsApi.getWaitStatus(configuration, transactionId, publicId)
    }
}
