//
//  TinkoffPayRequest.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 16.06.2023.
//

import CloudpaymentsNetworking

struct PayButtonStatus {
    var isOnSbp: Bool
    var isOnTinkoff: Bool
    var isOnSberPay: Bool
    var isSaveCard: Int?
    var failRedirectUrl: String?
    var successRedirectUrl: String?
    var isCvvRequired: Bool?
    var isAllowedNotSanctionedCards: Bool?
    var isQiwi: Bool?
    
    init(isOnSbp: Bool = false,
         isOnTinkoff: Bool = false,
         isOnSberPay: Bool = false,
         isSaveCard: Int? = nil,
         terminalUrl: String? = nil,
         isCvvRequired: Bool? = nil,
         isAllowedNotSanctionedCards: Bool? = nil,
         isQiwi: Bool? = nil) {
        
        self.isOnSbp = isOnSbp
        self.isOnTinkoff = isOnTinkoff
        self.isOnSberPay = isOnSberPay
        self.isSaveCard = isSaveCard
        self.isCvvRequired = isCvvRequired
        self.isAllowedNotSanctionedCards = isAllowedNotSanctionedCards
        self.isQiwi = isQiwi
    }
}

class GatewayRequest {
    static var payButtonStatus: PayButtonStatus?
    
    private class TinkoffPayRequestData<Model: Codable>: BaseRequest, CloudpaymentsRequestType {
        
        var data: CloudpaymentsNetworking.CloudpaymentsRequest
        typealias ResponseType = Model
        
        //MARK: - connect is on tinkoff pay button
        fileprivate init(baseURL: String, terminalPublicId: String?) {
            let baseURL = baseURL + "merchant/configuration/"
            guard var path = URLComponents(string: baseURL) else {
                data = .init(path: "")
                return
            }
            
            let queryItems: [URLQueryItem] = [
                .init(name: "terminalPublicId", value: terminalPublicId),
            ]
            path.queryItems = queryItems
            
            let fullUrl = path.url?.absoluteString ?? ""
            data = .init(path: fullUrl)
        }
        
        //MARK: - QR Link
        fileprivate init(baseURL: String, model: TinkoffPayData) {
            let baseURL = baseURL + "payments/qr/tinkoffpay/link"
            
            var params = [
                "PublicId": model.publicId,
                "Amount" : model.amount,
                "AccountId": model.accountId,
                "InvoiceId": model.invoiceId,
                "Browser" : model.browser,
                "Currency" : model.currency,
                "Device" : "MobileApp",
                "Description" : model.description,
                "Email" : model.email,
                "IpAddress":model.ipAddress,
                "Os" : model.os,
                "Scheme" : model.scheme,
                "TtlMinutes" : model.ttlMinutes,
                "SuccessRedirectUrl" : model.successRedirectURL,
                "FailRedirectUrl" : model.failRedirectURL,
                "Webview" : true,
                "Scenario": "7",
                "JsonData": model.jsonData
            ] as [String : Any?]
            
            if let saveCard = model.saveCard {
                params["SaveCard"] = saveCard
            }
            
            data = .init(path: baseURL, method: .post, params: params)
        }
        
        //MARK: - get status transactionId
        fileprivate init(baseURL: String, transactionId: Int64, publicId: String) {
            let baseURL = baseURL + "payments/qr/status/wait"
            
            let params = [
                "TransactionId": transactionId,
                "PublicId": publicId,
            ] as [String : Any?]
            
            data = .init(path: baseURL, method: .post, params: params)
        }
    }
}

extension GatewayRequest {
    
    public static func isOnGatewayAction(baseURL: String, terminalPublicId: String?, completion: @escaping (PayButtonStatus?) -> Void) {
        var result = PayButtonStatus()
        
        TinkoffPayRequestData<GatewayConfiguration>(baseURL: baseURL, terminalPublicId: terminalPublicId).execute { value in
            result.isSaveCard = value.model.features?.isSaveCard
            result.successRedirectUrl = value.model.terminalFullUrl
            result.failRedirectUrl = value.model.terminalFullUrl
            result.isCvvRequired = value.model.isCvvRequired
            result.isAllowedNotSanctionedCards = value.model.features?.isAllowedNotSanctionedCards
            result.isQiwi = value.model.features?.isQiwi
            
            for element in value.model.externalPaymentMethods {
                guard let rawValue = element.type, let value = CaseOfBank(rawValue: rawValue) else { continue }
                
                switch value {
                case .tinkoff: result.isOnTinkoff = element.enabled
                case .sbp: result.isOnSbp = element.enabled
                case .sberPay: result.isOnSberPay = element.enabled
                }
            }
            
            self.payButtonStatus = result
            
            return completion(result)
            
        } onError: { error in
            print(error.localizedDescription)
            let code = error._code < 0 ? -error._code : error._code
            self.payButtonStatus = code == 1009 ? nil : result
            if code == 1009 {
                return completion(nil)
            }
            
            return completion(result)
        }
    }
    
    public static func isTinkoffQrLink(baseURL: String, model: TinkoffPayData, completion: @escaping (QrPayResponse?, Bool) -> Void) {
        TinkoffPayRequestData<TinkoffResultPayData>(baseURL: baseURL, model: model).execute { value in
            return completion(value.model, true)
            
        } onError: { error in
            print(error.localizedDescription)
            let code = error._code < 0 ? -error._code : error._code
            if code == 1009 {
                return completion(nil, false)
            }
            
            return completion(nil, true)
        }
    }
    
    public static func getStatusTransactionId(baseURL: String, publicId: String, transactionId: Int64) {
        let model = TinkoffPayRequestData<ResponseTransactionModel>(baseURL: baseURL, transactionId: transactionId, publicId: publicId)
        
        model.execute { value in
            NotificationCenter.default.post(name: ObserverKeys.generalObserver.key, object: value)

        } onError: { string in
            NotificationCenter.default.post(name: ObserverKeys.generalObserver.key, object: string)
            return
        }
    }
}
