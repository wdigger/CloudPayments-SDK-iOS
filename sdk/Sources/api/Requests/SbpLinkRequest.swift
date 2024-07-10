//
//  SbpLinkRequest.swift
//  sdk
//
//  Created by Cloudpayments on 02.07.2024.
//  Copyright © 2024 Cloudpayments. All rights reserved.
//

import Foundation
import CloudpaymentsNetworking

final class SbpLinkRequest: BaseRequest, CloudpaymentsRequestType {
    typealias ResponseType = SbpDataResponse
    var data: CloudpaymentsRequest {
        let path = CloudpaymentsHTTPResource.sbp.asUrl(apiUrl: apiUrl)
       
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
