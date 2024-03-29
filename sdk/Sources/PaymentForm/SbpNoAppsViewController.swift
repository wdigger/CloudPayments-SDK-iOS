//
//  SbpNoAppsViewController.swift
//  sdk
//
//  Created by Cloudpayments on 22.08.2023.
//  Copyright © 2023 Cloudpayments. All rights reserved.
//

import Foundation
import UIKit

final class SbpNoAppsViewController: BaseViewController {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    
    var configuration: PaymentConfiguration!
    
    private lazy var currentContainerHeight: CGFloat = contentView.bounds.height
    private var heightPresentView: CGFloat { return contentView.bounds.height }
    
    public class func present(with configuration: PaymentConfiguration, from: UIViewController) {
        let controller = SbpNoAppsViewController(nibName: "SbpNoAppsViewController", bundle: .mainSdk)
        controller.configuration = configuration
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        controller.view.isOpaque = false
        from.present(controller, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .init(red: 1, green: 1, blue: 1, alpha: 0.0)
        setupView()
        addGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentesionView(true) {}
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
                bottomConstraint.constant = -heightPresentView
                currentContainerHeight = heightPresentView
                view.layoutIfNeeded()
                return
            }
            
            self.bottomConstraint.constant = -newHeight
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
                bottomConstraint.constant = -heightPresentView
                currentContainerHeight = heightPresentView
                UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
                    self.view.layoutIfNeeded()
                }
            }
            
        default:
            break
        }
    }
    
    private func setupView() {
        contentView.layer.cornerRadius = 20
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.clipsToBounds = true
    }
    
    @IBAction private func closedButton(_ sender: UIButton) {
        presentesionView(false) {
            guard let parent = self.presentingViewController else {return}

            self.dismiss(animated: true) {
                PaymentOptionsForm.present(with: self.configuration, from: parent, completion: nil)
            }
        }
    }
    
    private func presentesionView(_ isPresent: Bool, completion: @escaping () -> Void) {
        let alpha = isPresent ? 0.4 : 0
        self.currentContainerHeight = heightPresentView
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
            self.bottomConstraint.constant = isPresent ?  -self.heightPresentView :  0
            self.view.backgroundColor = .init(red: 1, green: 1, blue: 1, alpha: alpha)
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion()
        }
    }
}




