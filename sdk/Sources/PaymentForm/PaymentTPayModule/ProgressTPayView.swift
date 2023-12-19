//
//  CustomTPayView.swift
//  sdk
//
//  Created by Cloudpayments on 15.11.2023.
//  Copyright © 2023 Cloudpayments. All rights reserved.
//

import Foundation
import UIKit

protocol CustomTPayViewDelegate: AnyObject {
    func closePaymentButton()
}

final class ProgressTPayView: UIView {
    
    weak var delegate: CustomTPayViewDelegate?
    
    //MARK: - Constants
    
    private enum Constants {
        enum ContentView {
            static let leadingAnchor: CGFloat = 40
            static let trailingAnchor: CGFloat = -40
        }
        
        enum AlertImageView {
            static let topAnchor: CGFloat = 40
            static let leadingAnchor: CGFloat = 20
            static let trailingAnchor: CGFloat = -20
            static let heightAnchor: CGFloat = 180
        }
        
        enum CenterStackView {
            static let topAnchor: CGFloat = 12
            static let leadingAnchor: CGFloat = 20
            static let trailingAnchor: CGFloat = -20
        }
        
        enum FooterStackView {
            static let leadingAnchor: CGFloat = 20
            static let trailingAnchor: CGFloat = -20
            static let bottomAnchor: CGFloat = -12
        }
        
        enum Button {
            static let topAnchor: CGFloat = 20
            static let heightAnchor: CGFloat = 56
        }
        
        enum LogoImageView {
            static let topAnchor: CGFloat = 12
            static let heightAnchor: CGFloat = 18
        }
        
        enum Font {
            static let bold: CGFloat = 22
            static let regular: CGFloat = 15
        }
        
        enum Radius {
            static let medium: CGFloat = 14
        }
        
    }

    //MARK: - Private Properties
    
    private lazy var contentView = UIView(backgroundColor: .whiteColor,
                                          cornerRadius: Constants.Radius.medium)
    private lazy var alertImageView = UIImageView(image: .iconProgress, contentMode: .scaleAspectFit)
    private lazy var centerStackView = UIStackView(.vertical,
                                                   .equalSpacing,
                                                   .fill, 12,
                                                   [titleView, textView])
    private lazy var titleView = UIView()
    private lazy var textView = UIView()
    private lazy var footerStackView = UIStackView(.vertical,
                                                   .equalSpacing,
                                                   .fill, 12,
                                                   [buttonView, logoView])
   
    private lazy var buttonView = UIView()
    private lazy var button = UIButton(.colorBlue,
                                       8,
                                       1,
                                       .paymentMethod,
                                       .colorBlue)
    private lazy var logoView = UIView()
    private lazy var logoImageView = UIImageView(image: .iconLogo)
    
    //MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
        setupComponents()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

//MARK: - Progress TPay View

private extension ProgressTPayView {
    
    //MARK: - Add Views
    
    func addViews() {
        self.addSubviews(contentView)
        contentView.addSubviews(alertImageView, centerStackView, footerStackView)
        buttonView.addSubviews(button)
        logoView.addSubviews(logoImageView)
    }
    
    //MARK: - Setup Components
    
    func setupComponents() {
        backgroundColor = .clear
        
        setupLabel(withText: .payResponse,
                   textColor: .mainText,
                   fontSize: Constants.Font.bold,
                   containerView: titleView)
        
        setupLabel(withText: .failedPay,
                   textColor: .colorProgressText,
                   fontSize: Constants.Font.regular,
                   containerView: textView)
        
        button.addTarget(self, action: #selector(closeController), for: .touchUpInside)
    }
    
    //MARK: - Add Constraints
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            //content view
            contentView.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor,
                                                 constant: Constants.ContentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor,
                                                 constant: Constants.ContentView.trailingAnchor),
            
            //alertImageView
            alertImageView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                constant: Constants.AlertImageView.topAnchor),
            alertImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                constant: Constants.AlertImageView.leadingAnchor),
            alertImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: Constants.AlertImageView.trailingAnchor),
            alertImageView.heightAnchor.constraint(equalToConstant: Constants.AlertImageView.heightAnchor),
            
            //centerStackView
            centerStackView.topAnchor.constraint(equalTo: alertImageView.bottomAnchor,
                                                 constant: Constants.CenterStackView.topAnchor),
            centerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                 constant: Constants.CenterStackView.leadingAnchor),
            centerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                 constant: Constants.CenterStackView.trailingAnchor),
            centerStackView.bottomAnchor.constraint(equalTo: footerStackView.topAnchor),
            
            //footerStackView
            footerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                     constant: Constants.FooterStackView.leadingAnchor),
            footerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                     constant: Constants.CenterStackView.trailingAnchor),
            footerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                     constant: Constants.FooterStackView.bottomAnchor),
            
            //buttonView
            buttonView.topAnchor.constraint(equalTo: footerStackView.topAnchor),
            buttonView.leadingAnchor.constraint(equalTo: footerStackView.leadingAnchor),
            buttonView.trailingAnchor.constraint(equalTo: footerStackView.trailingAnchor),
            
            //button
            button.topAnchor.constraint(equalTo: buttonView.topAnchor,
                                        constant: Constants.Button.topAnchor),
            button.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor),
            button.heightAnchor.constraint(equalToConstant: Constants.Button.heightAnchor),
            
            //logoView
            logoView.leadingAnchor.constraint(equalTo: footerStackView.leadingAnchor),
            logoView.trailingAnchor.constraint(equalTo: footerStackView.trailingAnchor),
            
            //logoImage
            logoImageView.topAnchor.constraint(equalTo: logoView.topAnchor,
                                               constant: Constants.LogoImageView.topAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: logoView.centerYAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: logoView.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: Constants.LogoImageView.heightAnchor)
        ])
    }
    
    //MARK: - Setup Labels
    
    func setupLabel(withText text: String,
                    textColor: UIColor,
                    fontSize: CGFloat,
                    containerView: UIView) {
        let label = UILabel(text: text,
                            textColor: textColor,
                            fontSize: fontSize)
        containerView.addSubviews(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    //MARK: - Close Controller
    
    @objc private func closeController() {
        delegate?.closePaymentButton()
    }
    
}
