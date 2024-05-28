//
//  LoaderType.swift
//  sdk
//
//  Created by Cloudpayments on 14.09.2023.
//  Copyright © 2023 Cloudpayments. All rights reserved.
//

import Foundation

enum LoaderType: String {
    case loaderText = "Загружаем способы оплаты"
    case loadingBanks = "Загружаем список банков"
    
    func toString() -> String {
        return self.rawValue
    }
}
