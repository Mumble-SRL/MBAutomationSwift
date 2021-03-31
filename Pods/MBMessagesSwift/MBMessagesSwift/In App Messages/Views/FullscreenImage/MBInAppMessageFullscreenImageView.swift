//
//  MBInAppMessageFullscreenImageView.swift
//  MBInAppMessage
//
//  Created by Lorenzo Oliveto on 10/04/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit

/// This view is displayed in the middle of the screen, coming from the bottom (as a modal view) when the in app message has the style `MBInAppMessageStyle.fullscreenImage`.
/// This view has only a big image as the background, the close button, and the actions button as the bottom. It's useful if the content to displayed is just a big visual image.
public class MBInAppMessageFullscreenImageView: MBInAppMessageView {
    var backgroundView: UIView?
    
    var bottomConstraintHidden: NSLayoutConstraint?
    var centerConstraintNotHidden: NSLayoutConstraint?
    
    var closeButton: UIButton?

    override func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
        guard let messageImage = message.inAppMessage?.image else {
            configure(image: nil)
            return
        }
        MBInAppMessageImageLoader.loadImage(url: messageImage) { [weak self] image in
            if let strongSelf = self {
                strongSelf.configure(image: image)
            }
        }
    }
    
    private func configure(image: UIImage?) {
        let padding: CGFloat = 20
        
        guard let inAppMessage = message.inAppMessage else {
            return
        }

        contentView = UIView(frame: .zero)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        contentView.backgroundColor = UIColor.clear
        
        if let image = image {
            let imageView = UIImageView(frame: .zero)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            contentView.addSubview(imageView)
            let aspectRatio = image.size.width / image.size.height
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: aspectRatio)
            ])
            imageView.image = image
            self.imageView = imageView
        }

        if !inAppMessage.isBlocking {
            let closeButton = UIButton(type: .system)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(closeButton)
            closeButton.tintColor = styleDelegate?.closeButtonColor(forMessage: inAppMessage) ?? MBInAppMessageViewStyle.closeButtonColor(forMessage: inAppMessage)
            closeButton.backgroundColor = styleDelegate?.closeButtonBackgroundColor(forMessage: inAppMessage) ?? MBInAppMessageViewStyle.closeButtonBackgroundColor(forMessage: inAppMessage)
            closeButton.layoutIfNeeded()
            closeButton.layer.cornerRadius = 15
            closeButton.imageView?.contentMode = .scaleAspectFit
            let closeButtonPadding: CGFloat = 8
            closeButton.imageEdgeInsets = UIEdgeInsets(top: closeButtonPadding, left: closeButtonPadding, bottom: closeButtonPadding, right: closeButtonPadding)

            UIView.performWithoutAnimation {
                if #available(iOS 13.0, *) {
                    closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
                } else {
                    closeButton.setTitle("X", for: .normal)
                }
                closeButton.layoutIfNeeded()
            }
            NSLayoutConstraint.activate([
                closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                closeButton.widthAnchor.constraint(equalToConstant: 30),
                closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor)
            ])
            closeButton.addTarget(self, action: #selector(closePressed), for: .touchUpInside)
            self.closeButton = closeButton
        }
        
        if let buttons = inAppMessage.buttons {
            if buttons.count > 2 {
                fatalError("Are allowed only a max of 2 buttons")
            }
            var lastButton: UIView?
            for (index, button) in buttons.enumerated().reversed() {
                let font = styleDelegate?.buttonsTextFont(forMessage: inAppMessage) ?? MBInAppMessageViewStyle.buttonsTextFont(forMessage: inAppMessage)
                var backgroundColor: UIColor! = UIColor.white
                var titleColor: UIColor! = UIColor.white
                var borderColor: UIColor?
                if index == 0 {
                    backgroundColor = styleDelegate?.button1BackgroundColor(forMessage: inAppMessage) ??
                        MBInAppMessageViewStyle.button1BackgroundColor(forMessage: inAppMessage)
                    titleColor = styleDelegate?.button1TitleColor(forMessage: inAppMessage) ?? MBInAppMessageViewStyle.button1TitleColor(forMessage: inAppMessage)
                } else {
                    backgroundColor = styleDelegate?.button2BackgroundColor(forMessage: inAppMessage) ??
                        MBInAppMessageViewStyle.button2BackgroundColor(forMessage: inAppMessage)
                    titleColor = styleDelegate?.button2TitleColor(forMessage: inAppMessage) ?? MBInAppMessageViewStyle.button2TitleColor(forMessage: inAppMessage)
                    borderColor = styleDelegate?.button2BorderColor(forMessage: inAppMessage) ?? MBInAppMessageViewStyle.button2BorderColor(forMessage: inAppMessage)
                }
                let button = MBInAppMessageViewStyle.button(forMessageButton: button, backgroundColor: backgroundColor, titleColor: titleColor, borderColor: borderColor, font: font, height: 44)
                button.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(button)
                NSLayoutConstraint.activate([
                    button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
                    button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
                    button.heightAnchor.constraint(equalToConstant: 44),
                    button.bottomAnchor.constraint(equalTo: lastButton?.topAnchor ?? contentView.bottomAnchor, constant: index != 0 ? -padding : -8)
                ])
                if index == 0 {
                    self.button1 = button
                }
                if index == 1 {
                    self.button2 = button
                }
                lastButton = button
            }
        }
        
        button1?.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        button2?.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
    }
    
    override func present() {
        guard let window = UIApplication.shared.windows.first else {
            return
        }

        let blurEffect = UIBlurEffect(style: .dark)
        let backgroundView = UIVisualEffectView(effect: blurEffect)
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
        
        if let inAppMessage = message.inAppMessage {
            if inAppMessage.duration != -1 && !inAppMessage.isBlocking {
                self.perform(#selector(hide), with: nil, afterDelay: inAppMessage.duration)
            }
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
        let isBlockingMessage = inAppMessage?.isBlocking ?? false
        if !isBlockingMessage {
            hide()
        }
    }

    @objc func closePressed() {
        hide()
    }

}
