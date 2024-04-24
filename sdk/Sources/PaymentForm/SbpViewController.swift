//
//  SbpViewController.swift
//  Cloudpayments
//
//  Created by Cloudpayments on 26.07.2023.
//

import UIKit

final class SbpViewController: BaseViewController {
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var sbpTableView: UITableView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var sbpImageView: UIImageView!
    @IBOutlet private weak var closedConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var notFoundBanksView: UIView!
    @IBOutlet private weak var notFoundBanksLabel: UILabel!
    private lazy var currentContainerHeight: CGFloat = contentView.bounds.height
    private var isCloused = false
    private var heightPresentView: CGFloat { return contentView.bounds.height }
    private var payResponse: QrPayResponse!
    private var sbpBanks: [SbpQRDataModel] { payResponse.banks?.dictionary ?? [] }
    private var filteredBanks: [SbpQRDataModel] = []
    var defaultBorderColor: CGColor?
    
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction))
    
    var configuration: PaymentConfiguration!
    private let contentInsetBottom = 50.0
    
    public class func present(with configuration: PaymentConfiguration, from: UIViewController, payResponse: QrPayResponse) {
        let controller = SbpViewController(nibName: "SbpViewController", bundle: .mainSdk)
        controller.payResponse = payResponse
        controller.configuration = configuration
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        controller.view.isOpaque = false
        from.present(controller, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(red: 1, green: 1, blue: 1, alpha: 0.0)
        let nib = UINib(nibName: SbpCell.identifier, bundle: .mainSdk)
        sbpTableView.register(nib, forCellReuseIdentifier: SbpCell.identifier)
       
        filteredBanks = sbpBanks
        sbpTableView.delegate = self
        sbpTableView.dataSource = self
        searchBar.delegate = self
        setupView()
        addGesture()
        sbpTableView.contentInset.bottom = contentInsetBottom
        customizeSearchBar()
        
        view.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.cancelsTouchesInView = false
    }
    
    override var isKeyboardShowing: Bool {
        didSet {
            tapGestureRecognizer.cancelsTouchesInView = isKeyboardShowing
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeightTableViewContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentesionView(true) {}
    }
    
    @objc private func tapAction() {
        view.endEditing(true)
    }
    
    private func customizeSearchBar() {
        searchBar.layer.cornerRadius = 8
        searchBar.clipsToBounds = true
        searchBar.layer.borderWidth = 2
        searchBar.layer.borderColor = UIColor(red: 0.89, green: 0.91, blue: 0.94, alpha: 1).cgColor
        defaultBorderColor = searchBar.layer.borderColor
        
        searchBar.barTintColor = UIColor.white
        searchBar.backgroundColor = UIColor.white
        notFoundBanksLabel.textColor = UIColor(red: 0.55, green: 0.58, blue: 0.62, alpha: 1)
        
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor(red: 0.15, green: 0.15, blue: 0.27, alpha: 1)
            textfield.backgroundColor = UIColor.white
        }
    }
    
    private func updateHeightTableViewContent() {
        //count banks 350
        let defaultHeightTableViewContent = 350.0
        let height = sbpTableView.contentSize.height
        tableViewHeightConstraint.constant = height > defaultHeightTableViewContent ? -(defaultHeightTableViewContent + contentInsetBottom) : -(height + contentInsetBottom)
        view.layoutIfNeeded()
    }
    
    private func setupView() {
        contentView.layer.cornerRadius = 20
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.clipsToBounds = true
        
        sbpImageView.image = UIImage.icn_sbp_logo
    }
    
    @IBAction private func clousedButton(_ sender: UIButton) {
        presentesionView(false) {
            guard let parent = self.presentingViewController else {return}
            self.dismiss(animated: true) {
                PaymentOptionsForm.present(with: self.configuration, from: parent, completion: nil)
            }
        }
    }
    
    private func addGesture() {
        let panGesture = UIPanGestureRecognizer()
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        panGesture.addTarget(self, action: #selector(handlePanGesture(_:)))
        contentView.addGestureRecognizer(panGesture)
    }
    
    // MARK: Pan gesture handler
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let y = gesture.translation(in: view).y
        let newHeight = currentContainerHeight - y
        
        let procent = 30.0
        let defaultHeight = heightPresentView - ((heightPresentView * procent) / 100)
        
        switch gesture.state {
        case .changed:
            if heightPresentView < newHeight {
                closedConstraint.constant = -heightPresentView
                currentContainerHeight = heightPresentView
                view.layoutIfNeeded()
                return
            }
            
            self.closedConstraint.constant = -newHeight
            self.view.layoutIfNeeded()
            
        case .ended, .cancelled:
            
            if newHeight < defaultHeight {
                currentContainerHeight = newHeight
                presentesionView(false) {
                    guard let parent = self.presentingViewController else {return}
                    self.dismiss(animated: false)
                    PaymentForm.present(with: self.configuration, from: parent)
                }
            } else {
                closedConstraint.constant = -heightPresentView
                currentContainerHeight = heightPresentView
                UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
                    self.view.layoutIfNeeded()
                }
            }
            
        default:
            break
        }
    }
    
    private func presentesionView(_ isPresent: Bool, completion: @escaping () -> Void) {
        if isCloused { return }
        isCloused = !isPresent
        let alpha = isPresent ? 0.6 : 0
        self.currentContainerHeight = heightPresentView
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
            self.closedConstraint.constant = isPresent ?  -self.heightPresentView :  0
            self.view.backgroundColor = .init(red: 1, green: 1, blue: 1, alpha: alpha)
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion()
        }
    }
}

extension SbpViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespaces)
        
        if trimmedSearchText.isEmpty {
            filteredBanks = sbpBanks
        } else {
            filteredBanks = sbpBanks.filter { item in
                guard let bankName = item.bankName else { return false }
                return bankName.lowercased().contains(trimmedSearchText.lowercased())
            }
        }
        sbpTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredBanks = sbpBanks
        sbpTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.layer.borderColor = UIColor(red: 0.18, green: 0.44, blue: 0.99, alpha: 1).cgColor
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.layer.borderColor = defaultBorderColor
    }
}

extension SbpViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = filteredBanks.count
        notFoundBanksView.isHidden = count > 0
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SbpCell.identifier, for: indexPath) as? SbpCell else {
            return UITableViewCell()
        }
        let value = filteredBanks[indexPath.row]
        cell.setupCell(model: value)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        removePayObserver()
        let value = filteredBanks[indexPath.row]
        setupLinkForBank(value: value)
    }
}

extension SbpViewController {
    
    private func removePayObserver() {
        NotificationCenter.default.removeObserver(self, name: ObserverKeys.qrPayStatus.key, object: nil)
    }
    
    private func setupLinkForBank(value: SbpQRDataModel) {
        guard let qrURL = payResponse.qrURL else { return }
        var stringUri = qrURL
        
        if let isWebClientActive = value.isWebClientActive, let webClientURL = value.webClientURL, let providerQrId = payResponse.providerQrId {
            stringUri = "\(webClientURL)/\(providerQrId)"
            openSafariViewController(stringUri)
        } else {
            stringUri = qrURL.replacingOccurrences(of: "https", with: value.schema)
            openBanksApp(stringUri)
        }
    }
    
    private func openBanksApp(_ url: String) {
        guard let finalURL = URL(string: url) else { return }
        
        UIApplication.shared.open(finalURL) { success in
            if success {
                self.checkSbpTransactionId()
            } else {
                self.showAlert(title: .errorWord, message: .noBankApps)
            }
        }
    }
    
    private func openSafariViewController(_ string: String) {
        guard let finalURL = URL(string: string) else { return }
        let safariViewController = SafariViewController(url: finalURL)
        if let viewController = UIApplication.topViewController() {
            viewController.present(safariViewController, animated: true)
        }
        checkSbpTransactionId()
    }
    
    private func checkSbpTransactionId() {
        guard let id = payResponse.transactionId else { return }
        removePayObserver()
        
        let url = configuration.apiUrl
        let publicId = configuration.publicId
        //QRStatusPayObserver
        NotificationCenter.default.addObserver(self, selector: #selector(observerPayStatus(_:)),
                                               name: ObserverKeys.qrPayStatus.key, object: nil)
        SbpRequest.getStatusSBPPay(baseURL: url, publicId: publicId, transactionId: id)
    }
    
    private func checkNotificationError(_ notification: NSNotification) -> Bool {
        guard let error = notification.object as? Error else { return false }
        let code = error._code < 0 ? -error._code : error._code
        if code >= 1000 {checkSbpTransactionId(); return true}
        let string = String(code)
        let descriptionError = ApiError.getFullErrorDescription(code: string)
        presentError(descriptionError)
        return true
    }
    
    @objc private func observerPayStatus(_ notification: NSNotification) {
        
        guard let result = notification.object as? ResponseTransactionModel else {
            _ = checkNotificationError(notification)
            return
        }
        
        guard let rawValue = result.model?.status, let status = StatusPay(rawValue: rawValue) else {
            
            if result.success ?? false {
                checkSbpTransactionId()
            } else {
                if checkNotificationError(notification) { return }
                let descriptionError = ApiError.getFullErrorDescription(code: "0")
                presentError(descriptionError)
            }
            
            return
        }
        
        switch status {
        case .created, .pending:
            checkSbpTransactionId()
            
        case .authorized,.completed, .cancelled:
            removePayObserver()
            let transaction = Transaction(transactionId: payResponse.transactionId)
            guard let parent = self.presentingViewController else {return}
            
            presentesionView(false) {
                self.dismiss(animated: false) {
                    PaymentProcessForm.present(with: self.configuration, cryptogram: nil, email: nil, state: .succeeded(transaction), from: parent)
                }
            }
            
        case .declined:
            removePayObserver()
            let error = notification.object as? Error
            let code = error?._code
            let string = code == nil ? "" : String(code!)
            let descriptionError = ApiError.getFullErrorDescription(code: string)
            presentError(descriptionError)
        }
    }
    
    private func presentError(_ error: String! = nil) {
        guard let parent = self.presentingViewController else {return}
        
        presentesionView(false) {
            self.dismiss(animated: false) {
                PaymentProcessForm.present(with: self.configuration, cryptogram: nil, email: nil, state: .failed(nil),from: parent)
            }
        }
    }
}
