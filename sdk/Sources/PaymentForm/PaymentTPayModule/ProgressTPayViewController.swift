//
//  ProgressTPayViewController.swift
//  sdk
//
//  Created by Cloudpayments on 15.11.2023.
//  Copyright © 2023 Cloudpayments. All rights reserved.
//

import UIKit

protocol ProgressTPayPresenterProtocol: AnyObject {
    func getLink()
}

final class ProgressTPayViewController: UIViewController {
    weak var delegate: ProgressTPayProtocol?
    private let customView = ProgressTPayView()
    private let presenter: ProgressTPayPresenterProtocol
    
    //MARK: - Init
    
    init(presenter: ProgressTPayPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: .mainSdk)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        view.isOpaque = false
        view.backgroundColor = .clear
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifeCycle
    
    override func loadView() {
        super.loadView()
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customView.delegate = self
        presenter.getLink()
    }
}

//MARK: - Progress TPay View Controller
extension ProgressTPayViewController: CustomTPayViewDelegate {
    func closePaymentButton() {
        dismiss(animated: true) {
            self.delegate?.resultPayment(result: .close, error: nil, transactionId: nil)
        }
    }
}

//MARK: Presenter Delegate
extension ProgressTPayViewController: ProgressTPayViewControllerProtocol {
    func openLinkURL(url: URL) {
        
        guard UIApplication.shared.canOpenURL(url) else {
            let vc = SafariViewController(url: url)
            self.present(vc, animated: true)
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    func resultPayment(result: PaymentTPayView.PaymentAction, error: String?, transactionId: Int64?) {
        
        dismiss(animated: true) {
            self.delegate?.resultPayment(result: result, error: error, transactionId: transactionId)
        }
    }
}
