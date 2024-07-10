//
//  SberPayLinkRequest.swift
//  sdk
//
//  Created by Cloudpayments on 21.05.2024.
//  Copyright © 2024 Cloudpayments. All rights reserved.
//

import Foundation
import CloudpaymentsNetworking

final class SberPayLinkRequest: BaseRequest, CloudpaymentsRequestType {
    typealias ResponseType = AltPayDataResponse
    var data: CloudpaymentsRequest {
        let path = CloudpaymentsHTTPResource.sberPay.asUrl(apiUrl: apiUrl)
       
        guard var component = URLComponents(string: path) else { return CloudpaymentsRequest(path: path, method: .post, params: params, headers: headers) }
       
        if !queryItems.isEmpty {
            let items = queryItems.compactMap { return URLQueryItem(name: $0, value: $1) }
            component.queryItems = items
        }
        
        guard let url = component.url else { return CloudpaymentsRequest(path: path, method: .post, params: params, headers: headers) }
        let fullPath = url.absoluteString
        
        return CloudpaymentsRequest(path: fullPath, method: .post, params: params, headers: headers)
    }
}
