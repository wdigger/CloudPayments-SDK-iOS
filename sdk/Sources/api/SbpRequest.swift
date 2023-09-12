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
                "Email" : model.email,
                "IpAddress":model.ipAddress,
                "TtlMinutes" : model.ttlMinutes,
                "SuccessRedirectUrl" : model.successRedirectURL,
                "FailRedirectUrl" : model.failRedirectURL,
                "Scenario": "7"
            ] as [String : Any?]
            
            if let saveCard = model.saveCard {
                params["SaveCard"] = saveCard
            }
    
            data = .init(path: baseURL, method: .post, params: params)
        }
        
        //MARK: - get status transactionId
        fileprivate init(baseURL: String, transactionId: Int, publicId: String) {
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
    
    public class func getSbpParametrs(baseURL: String, model: GetSbpModel, completion: @escaping (QrPayResponse?) -> Void) {
        
        PrivateSbpRequest<QrResponseModel>(baseURL: baseURL, model: model).execute { value in
            completion(value.model)
        } onError: { string in
            print(string.localizedDescription)
            completion(nil)
        }
    }
    
    public static func getStatusSBPPay(baseURL: String, publicId: String, transactionId: Int) {
        let model = PrivateSbpRequest<RepsonseTransactionModel>(baseURL: baseURL, transactionId: transactionId, publicId: publicId)

        model.execute { value in
            NotificationCenter.default.post(name: ObserverKeys.qrPayStatus.key, object: value)

        } onError: { string in
//            GatewayRequest.resultDataPrint(type: TinkoffRepsonseTransactionModel.self, string.localizedDescription)
            NotificationCenter.default.post(name: ObserverKeys.qrPayStatus.key, object: string)
            return
        }
    }

}
