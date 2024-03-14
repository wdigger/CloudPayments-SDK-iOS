//
//  SbpRequest.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 26.07.2023.
//

import Foundation
import CloudpaymentsNetworking

class SbpRequest {
    private class PrivateSbpRequest<Model: Codable>: BaseRequest, CloudpaymentsRequestType {
        
        var data: CloudpaymentsNetworking.CloudpaymentsRequest
        typealias ResponseType = Model
        
        
        //MARK: - QR Link
        fileprivate init(baseURL: String, model: GetSbpModel) {
            let baseURL = baseURL + "payments/qr/sbp/link"
            
            var params = [
                "PublicId": model.publicId,
                "Amount" : model.amount,
                "InvoiceId": model.invoiceId,
                "Currency" : model.currency,
                "AccountId": model.accountId,
                "Device" : "MobileApp",
                "Email" : model.email,
                "IpAddress":model.ipAddress,
                "TtlMinutes" : model.ttlMinutes,
                "Scenario": "7",
                "JsonData": model.jsonData,
            ] as [String : Any?]
            
            if let saveCard = model.saveCard {
                params["SaveCard"] = saveCard
            }
            
            if let successRedirectUrl = model.successRedirectUrl {
                params["SuccessRedirectUrl"] = successRedirectUrl
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

extension SbpRequest {
    
    public class func getSbpParametrs(baseURL: String, model: GetSbpModel, completion: @escaping (QrPayResponse?, Bool) -> Void) {
        
        PrivateSbpRequest<QrResponseModel>(baseURL: baseURL, model: model).execute { value in
            completion(value.model, true)
        } onError: { error in
            print(error.localizedDescription)
            let code = error._code < 0 ? -error._code : error._code
            if code == 1009 {
                GatewayRequest.connectNetworkNotification = true
                GatewayRequest.connectNetworkNotification()
                return completion(nil, false)
            }
            completion(nil, true)
        }
    }
    
    public static func getStatusSBPPay(baseURL: String, publicId: String, transactionId: Int64) {
        let model = PrivateSbpRequest<ResponseTransactionModel>(baseURL: baseURL, transactionId: transactionId, publicId: publicId)

        model.execute { value in
            NotificationCenter.default.post(name: ObserverKeys.qrPayStatus.key, object: value)

        } onError: { string in
            NotificationCenter.default.post(name: ObserverKeys.qrPayStatus.key, object: string)
            return
        }
    }

}
