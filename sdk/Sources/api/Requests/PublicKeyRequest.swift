//
//  PublicKeyRequest.swift
//  Cloudpayments
//
//  Created by CloudPayments on 31.05.2023.
//

import Foundation
import CloudpaymentsNetworking

final class PublicKeyRequest: BaseRequest, CloudpaymentsRequestType {
    var data: CloudpaymentsNetworking.CloudpaymentsRequest
    typealias ResponseType = PublicKeyResponse
    
    private init() { data = .init(path: PublicKeyResponse.apiURL + "payments/publickey") }
    
    public static func updatePublicCryptoKey() {
        PublicKeyRequest().execute { value in
            value.save()
        } onError: { string in
            print(string.localizedDescription)
        }
    }
}
