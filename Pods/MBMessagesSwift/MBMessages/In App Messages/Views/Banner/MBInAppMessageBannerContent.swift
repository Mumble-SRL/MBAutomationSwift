//
//  MBInAppMessageBannerContent.swift
//  MBInAppMessage
//
//  Created by Lorenzo Oliveto on 17/03/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit

internal class MBInAppMessageBannerContent: UIView {
    var imageView: UIImageView?
    var titleLabel: UILabel?
    var bodyLabel: UILabel!
    var button1: UIButton?
    var button2: UIButton?

    init(message: MBInAppMessage,
         styleDelegate: MBInAppMessageViewStyleDelegate?) {
        super.init(frame: .zero)
        configure(withMessage: message, styleDelegate: styleDelegate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(withMessage message: MBInAppMessage,
                           styleDelegate: MBInAppMessageViewStyleDelegate?) {
        let padding: CGFloat = 10
        let cornerRadius: CGFloat = 8
        
        var lastVerticalView: UIView?

        if let image = message.image {
            let imageHeight: CGFloat = 80
            let imageView = UIImageView(frame: .zero)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = cornerRadius
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
                imageView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
                imageView.heightAnchor.constraint(equalToConstant: imageHeight),
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
            ])
            MBInAppMessageImageLoader.loadImage(url: image) { (image) in
                imageView.image = image
            }
            
            lastVerticalView = imageView
            self.imageView = imageView
        }
        
        if let title = message.title {
            let titleLabel = UILabel(frame: .zero)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.numberOfLines = 2
            titleLabel.lineBreakMode = .byTruncatingTail
            titleLabel.text = title
            titleLabel.font = styleDelegate?.titleFont(forMessage: message) ?? MBInAppMessageViewStyle.titleFont(forMessage: message)
            titleLabel.textColor = styleDelegate?.titleColor(forMessage: message) ?? MBInAppMessageViewStyle.titleColor(forMessage: message)
            addSubview(titleLabel)

            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: imageView?.trailingAnchor ?? leadingAnchor, constant: padding),
                titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
            ])

            self.titleLabel = titleLabel
        }
        
        let bodyLabel = UILabel(frame: .zero)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.lineBreakMode = .byTruncatingTail
        bodyLabel.numberOfLines = 3
        bodyLabel.font = styleDelegate?.bodyFont(forMessage: message) ?? MBInAppMessageViewStyle.bodyFont(forMessage: message)
        bodyLabel.text = message.body
        bodyLabel.textColor = styleDelegate?.bodyColor(forMessage: message) ?? MBInAppMessageViewStyle.bodyColor(forMessage: message)
        addSubview(bodyLabel)
        
        NSLayoutConstraint.activate([
            bodyLabel.leadingAnchor.constraint(equalTo: imageView?.trailingAnchor ?? leadingAnchor, constant: padding),
            bodyLabel.topAnchor.constraint(equalTo: titleLabel?.bottomAnchor ?? topAnchor, constant: padding),
            bodyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
        if let imageView = imageView {
            bodyLabel.bottomAnchor.constraint(lessThanOrEqualTo: imageView.bottomAnchor).isActive
                = true
        } else {
            lastVerticalView = bodyLabel
        }
        
        self.bodyLabel = bodyLabel

        if let buttons = message.buttons {
            if buttons.count > 2 {
                fatalError("Are allowed only a max of 2 buttons")
            }
            
            let buttonsHeight: CGFloat = 30
            if buttons.count != 0 {
                let buttonsFont = styleDelegate?.buttonsTextFont(forMessage: message) ?? MBInAppMessageViewStyle.buttonsTextFont(forMessage: message)
                if buttons.count == 1 {
                    let button1BackgroundColor = styleDelegate?.button1BackgroundColor(forMessage: message) ??
                        MBInAppMessageViewStyle.button1BackgroundColor(forMessage: message)
                    let button1TitleColor = styleDelegate?.button1TitleColor(forMessage: message) ?? MBInAppMessageViewStyle.button1TitleColor(forMessage: message)
                    let button = MBInAppMessageViewStyle.button(forMessageButton: buttons[0], backgroundColor: button1BackgroundColor, titleColor: button1TitleColor, font:
                        buttonsFont, height: buttonsHeight)
                    button.translatesAutoresizingMaskIntoConstraints = false
                    addSubview(button)
                    NSLayoutConstraint.activate([
                        button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
                        button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
                        button.heightAnchor.constraint(equalToConstant: buttonsHeight),
                        button.topAnchor.constraint(equalTo: lastVerticalView?.bottomAnchor ?? bodyLabel.bottomAnchor, constant: padding)
                    ])
                    self.button1 = button
                    lastVerticalView = button
                } else {
                    let button1BackgroundColor = styleDelegate?.button1BackgroundColor(forMessage: message) ??
                        MBInAppMessageViewStyle.button1BackgroundColor(forMessage: message)
                    let button1TitleColor = styleDelegate?.button1TitleColor(forMessage: message) ?? MBInAppMessageViewStyle.button1TitleColor(forMessage: message)

                    let button2BackgroundColor = styleDelegate?.button2BackgroundColor(forMessage: message) ??
                        MBInAppMessageViewStyle.button2BackgroundColor(forMessage: message)
                    let button2TitleColor = styleDelegate?.button2TitleColor(forMessage: message) ?? MBInAppMessageViewStyle.button2TitleColor(forMessage: message)
                    let button2BorderColor = styleDelegate?.button2BorderColor(forMessage: message) ?? MBInAppMessageViewStyle.button2BorderColor(forMessage: message)

                    let button1 = MBInAppMessageViewStyle.button(forMessageButton: buttons[0], backgroundColor: button1BackgroundColor, titleColor: button1TitleColor, font:
                    buttonsFont, height: buttonsHeight)
                    button1.translatesAutoresizingMaskIntoConstraints = false
                    addSubview(button1)
                    let button2 = MBInAppMessageViewStyle.button(forMessageButton: buttons[1], backgroundColor: button2BackgroundColor, titleColor: button2TitleColor, borderColor: button2BorderColor, font:
                        buttonsFont, height: buttonsHeight)
                    button2.translatesAutoresizingMaskIntoConstraints = false
                    addSubview(button2)
                    NSLayoutConstraint.activate([
                        button1.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
                        button1.heightAnchor.constraint(equalToConstant: buttonsHeight),
                        button1.topAnchor.constraint(equalTo: lastVerticalView?.bottomAnchor ?? bodyLabel.bottomAnchor, constant: padding),
                        button1.trailingAnchor.constraint(equalTo: button2.leadingAnchor, constant: -padding),
                        button2.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
                        button2.topAnchor.constraint(equalTo: button1.topAnchor),
                        button2.heightAnchor.constraint(equalTo: button1.heightAnchor),
                        button1.widthAnchor.constraint(equalTo: button2.widthAnchor)
                    ])
                    self.button1 = button1
                    self.button2 = button2
                    lastVerticalView = button1
                }
            }
        }
        if let lastVerticalView = lastVerticalView {
            lastVerticalView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
}
