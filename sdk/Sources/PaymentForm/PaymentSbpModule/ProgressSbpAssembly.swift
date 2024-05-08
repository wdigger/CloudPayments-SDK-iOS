//
//  ProgressSbpAssembly.swift
//  sdk
//
//  Created by Cloudpayments on 02.05.2024.
//  Copyright © 2024 Cloudpayments. All rights reserved.
//

import Foundation
import UIKit

public class SbpAssembly {
    class func createSbpVC(configuration: PaymentConfiguration, from: UIViewController, payResponse: QrPayResponse) -> ProgressSbpViewController {
        let presenter = ProgressSbpPresenter(configuration: configuration, payResponse: payResponse)
        let view = ProgressSbpViewController(presenter: presenter)
        presenter.view = view
        
        return view
    }
}
