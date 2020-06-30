//
//  MBInAppMessageCenterView.swift
//  MBInAppMessage
//
//  Created by Lorenzo Oliveto on 17/03/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit

/// This view is displayed in the middle of the screen, coming from the bottom (as a modal view) when the in app message has the style `MBInAppMessageStyle.center`
public class MBInAppMessageCenterView: MBInAppMessageView {

    var backgroundView: UIView?
    
    var bottomConstraintHidden: NSLayoutConstraint?
    var centerConstraintNotHidden: NSLayoutConstraint?
    
    var closeButton: UIButton!
    
    override func configure() {
        layer.cornerRadius = 8
        clipsToBounds = true
        
        let padding: CGFloat = 20
        
        let backgroundStyle = styleDelegate?.backgroundStyle(forMessage: message) ?? MBInAppMessageViewStyle.backgroundStyle(forMessage: message)
        if backgroundStyle == .translucent {
            let blurEffect = UIBlurEffect(style: .regular)
            contentView = UIVisualEffectView(effect: blurEffect)
            contentView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(contentView)
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                contentView.topAnchor.constraint(equalTo: topAnchor),
                contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        } else {
            contentView = UIView(frame: .zero)
            contentView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(contentView)
            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                contentView.topAnchor.constraint(equalTo: topAnchor),
                contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            if #available(iOS 13.0, *) {
                contentView.backgroundColor = UIColor.systemBackground
            } else {
                contentView.backgroundColor = UIColor.white
            }
            if let backgroundColor = styleDelegate?.backgroundColor(forMessage: message) {
                contentView.backgroundColor = backgroundColor
            } else {
                contentView.backgroundColor = MBInAppMessageViewStyle.backgroundColor(forMessage: message)
            }
        }

        var targetView = contentView ?? self
        if let contentView = contentView as? UIVisualEffectView {
            targetView = contentView.contentView
        }
        
        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        targetView.addSubview(closeButton)
        closeButton.tintColor = styleDelegate?.closeButtonColor(forMessage: message) ?? MBInAppMessageViewStyle.button1BackgroundColor(forMessage: message)
        
        UIView.performWithoutAnimation {
            if #available(iOS 13.0, *) {
                closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            } else {
                closeButton.setTitle("X", for: .normal)
            }
            closeButton.layoutIfNeeded()
        }
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor)
        ])
        closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
        self.closeButton = closeButton
        
        var lastVerticalView: UIView?
        if let image = message.image {
            let imageView = UIImageView(frame: .zero)
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            targetView.addSubview(imageView)
            MBInAppMessageImageLoader.loadImage(url: image) { (image) in
                imageView.image = image
            }
            
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
            ])
            lastVerticalView = imageView
        }
        
        if let title = message.title {
            let titleLabel = UILabel(frame: .zero)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.lineBreakMode = .byWordWrapping
            titleLabel.numberOfLines = 0
            titleLabel.font = styleDelegate?.titleFont(forMessage: message) ?? MBInAppMessageViewStyle.titleFont(forMessage: message)
            titleLabel.textColor = styleDelegate?.titleColor(forMessage: message) ?? MBInAppMessageViewStyle.titleColor(forMessage: message)
            titleLabel.text = title
            titleLabel.textAlignment = .center
            targetView.addSubview(titleLabel)

            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: targetView.leadingAnchor, constant: padding),
                titleLabel.trailingAnchor.constraint(equalTo: targetView.trailingAnchor, constant: -padding),
                titleLabel.topAnchor.constraint(equalTo: lastVerticalView?.bottomAnchor ?? targetView.topAnchor, constant: padding)
            ])

            self.titleLabel = titleLabel
            lastVerticalView = titleLabel
        }
        
        let bodyLabel = UILabel(frame: .zero)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.lineBreakMode = .byWordWrapping
        bodyLabel.numberOfLines = 0
        bodyLabel.font = styleDelegate?.bodyFont(forMessage: message) ?? MBInAppMessageViewStyle.bodyFont(forMessage: message)
        bodyLabel.textColor = styleDelegate?.bodyColor(forMessage: message) ?? MBInAppMessageViewStyle.bodyColor(forMessage: message)
        bodyLabel.text = message.body
        addSubview(bodyLabel)
        
        NSLayoutConstraint.activate([
            bodyLabel.leadingAnchor.constraint(equalTo: targetView.leadingAnchor, constant: padding),
            bodyLabel.trailingAnchor.constraint(equalTo: targetView.trailingAnchor, constant: -padding),
            bodyLabel.topAnchor.constraint(equalTo: lastVerticalView?.bottomAnchor ?? targetView.topAnchor, constant: padding)
        ])

        self.bodyLabel = bodyLabel
        lastVerticalView = bodyLabel

        if let buttons = message.buttons {
            if buttons.count > 2 {
                fatalError("Are allowed only a max of 2 buttons")
            }
            for (index, button) in buttons.enumerated() {
                let font = styleDelegate?.buttonsTextFont(forMessage: message) ?? MBInAppMessageViewStyle.buttonsTextFont(forMessage: message)
                var backgroundColor: UIColor! = UIColor.white
                var titleColor: UIColor! = UIColor.white
                var borderColor: UIColor?
                if index == 0 {
                    backgroundColor = styleDelegate?.button1BackgroundColor(forMessage: message) ??
                        MBInAppMessageViewStyle.button1BackgroundColor(forMessage: message)
                    titleColor = styleDelegate?.button1TitleColor(forMessage: message) ?? MBInAppMessageViewStyle.button1TitleColor(forMessage: message)
                } else {
                    backgroundColor = styleDelegate?.button2BackgroundColor(forMessage: message) ??
                        MBInAppMessageViewStyle.button2BackgroundColor(forMessage: message)
                    titleColor = styleDelegate?.button2TitleColor(forMessage: message) ?? MBInAppMessageViewStyle.button2TitleColor(forMessage: message)
                    borderColor = styleDelegate?.button2BorderColor(forMessage: message) ?? MBInAppMessageViewStyle.button2BorderColor(forMessage: message)
                }
                let button = MBInAppMessageViewStyle.button(forMessageButton: button, backgroundColor: backgroundColor, titleColor: titleColor, borderColor: borderColor, font: font, height: 44)
                button.translatesAutoresizingMaskIntoConstraints = false
                addSubview(button)
                NSLayoutConstraint.activate([
                    button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
                    button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
                    button.heightAnchor.constraint(equalToConstant: 44),
                    button.topAnchor.constraint(equalTo: lastVerticalView?.bottomAnchor ?? bodyLabel.bottomAnchor, constant: index == 0 ? padding : 8)
                ])
                if index == 0 {
                    self.button1 = button
                }
                if index == 1 {
                    self.button2 = button
                }
                lastVerticalView = button
            }
            
        }

        if let lastVerticalView = lastVerticalView {
            lastVerticalView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding).isActive = true
        } else {
            bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding).isActive = true
        }
        
        button1?.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        button2?.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
    }
    
    override func present() {
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        let backgroundView = UIView(frame: .zero)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        window.addSubview(backgroundView)
        backgroundView.alpha = 0
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView = backgroundView
        
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            backgroundView.topAnchor.constraint(equalTo: window.topAnchor)
        ])

        window.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        
        let bottomConstraintHidden = self.topAnchor.constraint(equalTo: window.bottomAnchor)
        let centerConstraintNotHidden = self.centerYAnchor.constraint(equalTo: window.centerYAnchor)
        
        self.bottomConstraintHidden = bottomConstraintHidden
        self.centerConstraintNotHidden = centerConstraintNotHidden
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 20),
            trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -20),
            bottomConstraintHidden,
            heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
        
        window.layoutIfNeeded()
        
        bottomConstraintHidden.isActive = false
        centerConstraintNotHidden.isActive = true
        delegate?.viewWillAppear(view: self)
        UIView.animate(withDuration: 0.3, animations: {
            window.layoutIfNeeded()
            backgroundView.alpha = 1
        }, completion: { _ in
            self.delegate?.viewDidAppear(view: self)
        })
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backgroundViewPressed))
        backgroundView.addGestureRecognizer(tap)
        
        if message.duration != -1 {
            self.perform(#selector(hide), with: nil, afterDelay: message.duration)
        }
    }
    
    override func performHide(duration: TimeInterval,
                              completionBlock: (() -> Void)? = nil) {
        centerConstraintNotHidden?.isActive = false
        bottomConstraintHidden?.isActive = true
        
        delegate?.viewWillDisappear(view: self)
        UIView.animate(withDuration: duration, animations: {
            self.superview?.layoutIfNeeded()
            self.backgroundView?.alpha = 0
        }, completion: { _ in
            self.delegate?.viewDidDisappear(view: self)
            if let completionBlock = completionBlock {
                completionBlock()
            }
            self.removeFromSuperview()
            self.backgroundView?.removeFromSuperview()
            self.backgroundView = nil
        })
    }
    
    @objc func backgroundViewPressed() {
        hide()
    }

    @objc func closePressed() {
        hide()
    }
}
