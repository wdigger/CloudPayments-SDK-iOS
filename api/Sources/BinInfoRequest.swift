//
//  BinInfoRequest.swift
//  sdk
//
//  Created by i.belkin on 05.02.2024.
//  Copyright © 2024 Cloudpayments. All rights reserved.
//

import Foundation
import CloudpaymentsNetworking

final class BinInfoRequest: BaseRequest, CloudpaymentsRequestType {
    typealias ResponseType = BankInfoResponse
    var data: CloudpaymentsRequest {
        let path = CloudpaymentsHTTPResource.binInfo.asUrl(apiUrl: apiUrl)
       
        guard var component = URLComponents(string: path) else { return CloudpaymentsRequest(path: path, headers: headers) }
       
        if !queryItems.isEmpty {
            let items = queryItems.compactMap { return URLQueryItem(name: $0, value: $1) }
            component.queryItems = items
        }
        
        guard let url = component.url else { return CloudpaymentsRequest(path: path, headers: headers) }
        let fullPath = url.absoluteString
        
        return CloudpaymentsRequest(path: fullPath, headers: headers)
    }
}
