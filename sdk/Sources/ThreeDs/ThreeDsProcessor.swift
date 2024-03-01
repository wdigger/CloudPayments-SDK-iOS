//
//  ThreeDSDialog.swift
//  sdk
//
//  Created by Sergey Iskhakov on 09.09.2020.
//  Copyright © 2020 Cloudpayments. All rights reserved.
//

import WebKit

public protocol ThreeDsDelegate: AnyObject  {
    func willPresentWebView(_ webView: WKWebView)
    func onAuthorizationCompleted(with md: String, paRes: String)
    func onAuthorizationFailed(with html: String)
}

public class ThreeDsProcessor: NSObject, WKNavigationDelegate {
    private static let POST_BACK_URL = "https://demo.cloudpayments.ru/WebFormPost/GetWebViewData"
    
    private weak var delegate: ThreeDsDelegate?
    
    public func make3DSPayment(with data: ThreeDsData, delegate: ThreeDsDelegate) {
        self.delegate = delegate
        
        if let url = URL.init(string: data.acsUrl) {
            var request = URLRequest.init(url: url)
            request.httpMethod = "POST"
            request.cachePolicy = .reloadIgnoringCacheData
            
            let requestBody = String.init(format: "MD=%@&PaReq=%@&TermUrl=%@", data.transactionId, data.paReq, ThreeDsProcessor.POST_BACK_URL).replacingOccurrences(of: "+", with: "%2B")
            request.httpBody = requestBody.data(using: .utf8)
            
            URLCache.shared.removeCachedResponse(for: request)
            
            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else {
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, (httpResponse.statusCode == 200 || httpResponse.statusCode == 201), let data = data {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else {
                            return
                        }
                        
                        let webView = WKWebView.init()
                        webView.configuration.preferences.javaScriptEnabled = true
                        if #available(iOS 14.0, *) {
                            webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
                        }
                        webView.navigationDelegate = self
                        if let mimeType = httpResponse.mimeType,
                           let url = httpResponse.url {
                            
                            let textEncodingName = httpResponse.textEncodingName ?? ""
                            webView.load(data, mimeType: mimeType, characterEncodingName: textEncodingName, baseURL: url)
                        }
                        
                        self.delegate?.willPresentWebView(webView)
                    }
                } else if let httpResponse = response as? HTTPURLResponse {
                    DispatchQueue.main.async { [weak self] in
                        self?.delegate?.onAuthorizationFailed(with: "Unable to load 3DS autorization page.\nStatus code: \(httpResponse.statusCode)")
                    }
                }
            }.resume()
        }
    }

    //MARK: - WKNavigationDelegate -
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let url = webView.url
        
        if url?.absoluteString.elementsEqual(ThreeDsProcessor.POST_BACK_URL) == true {
            webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (result, error) in
                var str = result as? String ?? ""
                repeat {
                    let startIndex = str.firstIndex(of: "{")
                    if startIndex == nil {
                        break
                    }
                    
                    let endIndex = str.lastIndex(of: "}")
                    if endIndex == nil {
                        break
                    }
                    str = String(str[startIndex!...endIndex!])
                    if let data = str.data(using: .utf8), let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                        if let md = dict["MD"] as? String, let paRes = dict["PaRes"] as? String {
                            self.delegate?.onAuthorizationCompleted(with: md, paRes: paRes)
                        } else {
                            self.delegate?.onAuthorizationFailed(with: str)
                        }
                        
                        return
                    }
                } while false

                self.delegate?.onAuthorizationFailed(with: str)
            }
        }
    }
}
