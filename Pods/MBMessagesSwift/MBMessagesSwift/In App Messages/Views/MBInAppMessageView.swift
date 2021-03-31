//
//  MBInAppMessageView.swift
//  MBInAppMessage
//
//  Created by Lorenzo Oliveto on 17/03/2020.
//  Copyright © 2020 Lorenzo Oliveto. All rights reserved.
//

import UIKit
import SafariServices

/// This protocol can be used to receive calls when a `MBInAppMessageView` is displayed and is hidden, it will also receives a call when a button is pressed.
/// Implement this delegate if your app need to perform actions when a button is tapped, e.g. open a section of the app if a button with an in-app link is pressed.
/// All functions of this protocol are optional and, by default, they don't do anything.
public protocol MBInAppMessageViewDelegate: class {
    /// This function is called just before a `MBInAppMessageView` appears.
    /// - Parameters:
    ///   - view: The view that will be showed.
    func viewWillAppear(view: MBInAppMessageView)
    /// This function is called just after a `MBInAppMessageView` is displayed, when the animation finishes.
    /// - Parameters:
    ///   - view: The view that has been showed.
    func viewDidAppear(view: MBInAppMessageView)
    /// This function is called just before a `MBInAppMessageView` is being removed.
    /// - Parameters:
    ///   - view: The view that will disappear.
    func viewWillDisappear(view: MBInAppMessageView)
    /// This function is called just after a `MBInAppMessageView` has been removed, when the animation finishes.
    /// - Parameters:
    ///   - view: The view that disappeared.
    func viewDidDisappear(view: MBInAppMessageView)
    /// Ths function is called when a button of the `MBInAppMessageView` has been pressed. Tthis function will be called after the animation for the view has finished.
    /// - Parameters:
    ///   - view: The view that disappeared.
    ///   - button: The button that has been pressed.
    func buttonPressed(view: MBInAppMessageView, button: MBInAppMessageButton)
}

/// Default functions for this protocol, all empty, by default don't do nothing.
public extension MBInAppMessageViewDelegate {
    func viewWillAppear(view: MBInAppMessageView) {}
    func viewDidAppear(view: MBInAppMessageView) {}
    func viewWillDisappear(view: MBInAppMessageView) {}
    func viewDidDisappear(view: MBInAppMessageView) {}
    func buttonPressed(view: MBInAppMessageView, button: MBInAppMessageButton) {}
}

// MARK: - MBInAppMessageViewStyleDelegate

/// This protocol can be used to use different colors and fonts to the in-app messages views.
/// Returning values from those functions will override the defults and the colors and fonts setted in the dashboard.
public protocol MBInAppMessageViewStyleDelegate: class {
    /// The background style that will be used for the message.
    /// The default value is `MBInAppMessageViewBackgroundStyle.translucent` for banner messages, `MBInAppMessageViewBackgroundStyle.solid` otherwise
    /// - Parameters:
    ///   - message: The in app message
    /// - Returns: The background style for the message
    func backgroundStyle(forMessage message: MBInAppMessage) -> MBInAppMessageViewBackgroundStyle
    /// The background color for the view.
    /// Default value: if the message has a background color the function returns that value, otherwise it will return a black color (#1E1E1ED5) for dark style and `UIColor.white.withAlphaComponent(0.9)` for the light style.
    /// - Parameters:
    ///   - message: The in app message
    /// - Returns: The background color for the message
    func backgroundColor(forMessage message: MBInAppMessage) -> UIColor
    /// The title text color for the view.
    /// Default value: if the message has a title color the function returns that value, otherwise it will return `UIColor.black` if the `userInterfaceStyle` is `light`, `UIColor.white` if it's `dark`.
    /// - Parameters:
    ///   - message: The in app message
    /// - Returns: The title color for the message
    func titleColor(forMessage message: MBInAppMessage) -> UIColor
    /// The text color for the body label for the view.
    /// Default value: if the message has a body color the function returns that value, otherwise it will return `UIColor.black` if the `userInterfaceStyle` is `light`, `UIColor.white` if it's `dark`.
    /// - Parameters:
    ///   - message: The in app message
    /// - Returns: The body color for the message
    func bodyColor(forMessage message: MBInAppMessage) -> UIColor
    /// The color for the close button.
    /// Default value: `UIColor.black` if the `userInterfaceStyle` is `light`, `UIColor.white` if it's `dark`.
    /// - Parameters:
    ///   - message: The in app message
    /// - Returns: The close button color for the message
    func closeButtonColor(forMessage message: MBInAppMessage) -> UIColor
    /// The background color for the close button.
    /// Default value: `UIColor.white` if the `userInterfaceStyle` is `light`, `UIColor.black` if it's `dark`.
    /// - Parameters:
    ///   - message: The in app message
    /// - Returns: The close button color for the message
    func closeButtonBackgroundColor(forMessage message: MBInAppMessage) -> UIColor
    /// The background color for the first action button.
    /// The default value is the main MBurger color (#138CFC) if the message is not a fullscreen image, `UIColor.white` otherwise.
    /// - Parameters:
    ///   - message: The in app message
    /// - Returns: The background color for the first action button
    func button1BackgroundColor(forMessage message: MBInAppMessage) -> UIColor
    /// The title color for the first action button.
    /// Possible values: 
    /// - If the first button has a title color the function returns that value.
    /// - If the message is not a fullscreen image it will return `UIColor.white`.
    /// - If the message is a fullscreen image it will return the dark MBurger color (#041444).
    /// - Parameters:
    ///   - message: The in app message
    /// - Returns: The title color for the first action button
    func button1TitleColor(forMessage message: MBInAppMessage) -> UIColor
    /// The background color for the second action button.
    /// If the second button has a background color the function returns that value, otherwise it returns a transparent color `UIColor.clear`.
    /// - Parameters:
    ///   - message: The in app message
    /// - Returns: The background color for the second action button
    func button2BackgroundColor(forMessage message: MBInAppMessage) -> UIColor
    /// The title color for the second action button.
    /// - If the sencond button has a title color the function returns that value.
    /// - If the message is not a fullscreen image it will return the MBurger color (#138CFC). `UIColor.white`.
    /// - If the message is a fullscreen image it will return `UIColor.white`.
    /// - Parameters:
    ///   - message: The in app message
    /// - Returns: The title color for the second action button
    func button2TitleColor(forMessage message: MBInAppMessage) -> UIColor
    /// The border color for the second action button.
    /// Default value: the default value is the same as the title color.
    /// - Parameters:
    ///   - message: The in app message
    /// - Returns: The border color for the second action button
    func button2BorderColor(forMessage message: MBInAppMessage) -> UIColor?
    /// The font used fot the title.
    /// Default value: the default value is a bold font of 20pt `UIFont.systemFont(ofSize: 20, weight: .bold)`.
    /// - Parameters:
    ///   - message: The in app message
    /// - Returns: The title font
    func titleFont(forMessage message: MBInAppMessage) -> UIFont
    /// The font used fot the body.
    /// Default value: the default value is a regular font of 19pt ``UIFont.systemFont(ofSize: 19)``.
    /// - Parameters:
    ///   - message: The in app message
    /// - Returns: The body font
    func bodyFont(forMessage message: MBInAppMessage) -> UIFont
    /// The font used fot the titles of the buttons.
    /// Default values:
    /// - Center messages: semibold font of 17pt `UIFont.systemFont(ofSize: 14, weight: .semibold)`.
    /// - All other messages: semibold font of 14pt `UIFont.systemFont(ofSize: 14, weight: .semibold)`.
    /// - Parameters:
    ///   - message: The in app message
    /// - Returns: The font for the titles of the buttons.
    func buttonsTextFont(forMessage message: MBInAppMessage) -> UIFont
}

public extension MBInAppMessageViewStyleDelegate {
    func backgroundStyle(forMessage message: MBInAppMessage) -> MBInAppMessageViewBackgroundStyle {
        return MBInAppMessageViewStyle.backgroundStyle(forMessage: message)
    }
    func backgroundColor(forMessage message: MBInAppMessage) -> UIColor {
        return MBInAppMessageViewStyle.backgroundColor(forMessage: message)
    }
    
    func titleColor(forMessage message: MBInAppMessage) -> UIColor {
        return MBInAppMessageViewStyle.titleColor(forMessage: message)
    }
    
    func bodyColor(forMessage message: MBInAppMessage) -> UIColor {
        return MBInAppMessageViewStyle.bodyColor(forMessage: message)
    }
    
    func closeButtonColor(forMessage message: MBInAppMessage) -> UIColor {
        return MBInAppMessageViewStyle.closeButtonColor(forMessage: message)
    }
    
    func closeButtonBackgroundColor(forMessage message: MBInAppMessage) -> UIColor {
        return MBInAppMessageViewStyle.closeButtonBackgroundColor(forMessage: message)
    }
    
    func button1BackgroundColor(forMessage message: MBInAppMessage) -> UIColor {
        return MBInAppMessageViewStyle.button1BackgroundColor(forMessage: message)
    }
    
    func button1TitleColor(forMessage message: MBInAppMessage) -> UIColor {
        return MBInAppMessageViewStyle.button1TitleColor(forMessage: message)
    }
    
    func button2BackgroundColor(forMessage message: MBInAppMessage) -> UIColor {
        return MBInAppMessageViewStyle.button2BackgroundColor(forMessage: message)
    }
    
    func button2TitleColor(forMessage message: MBInAppMessage) -> UIColor {
        return MBInAppMessageViewStyle.button2TitleColor(forMessage: message)
    }
    
    func button2BorderColor(forMessage message: MBInAppMessage) -> UIColor? {
        MBInAppMessageViewStyle.button2BorderColor(forMessage: message)
    }
    
    func titleFont(forMessage message: MBInAppMessage) -> UIFont {
        return MBInAppMessageViewStyle.titleFont(forMessage: message)
    }
    
    func bodyFont(forMessage message: MBInAppMessage) -> UIFont {
        return MBInAppMessageViewStyle.bodyFont(forMessage: message)
    }
    
    func buttonsTextFont(forMessage message: MBInAppMessage) -> UIFont {
        return MBInAppMessageViewStyle.buttonsTextFont(forMessage: message)
    }
}

// MARK: - MBInAppMessageView

/// A general view used as an interface. This class is just an interface and should not be instantiate, the SDK will instantiate only subclasses of this class.
public class MBInAppMessageView: UIView {
    var message: MBMessage!
    var inAppMessage: MBInAppMessage? {
        return message.inAppMessage
    }
    weak var delegate: MBInAppMessageViewDelegate?
    weak var styleDelegate: MBInAppMessageViewStyleDelegate?
    
    var contentView: UIView!
    
    var imageView: UIImageView?
    var titleLabel: UILabel?
    var bodyLabel: UILabel!
    var button1: UIButton?
    var button2: UIButton?
    
    weak var viewController: UIViewController?
    
    /// Completion block called by the manager to display next messages if no button is pressed and the message view is dismissed
    internal var completionBlock: (() -> Void)?
    
    /// Block called when a button is pressed, used by the manager to cleanup if a button is pressed
    internal var buttonPressedBlock: (() -> Void)?
    
    init(message: MBMessage,
         delegate: MBInAppMessageViewDelegate? = nil,
         styleDelegate: MBInAppMessageViewStyleDelegate? = nil,
         viewController: UIViewController? = nil) {
        super.init(frame: .zero)
        self.message = message
        self.delegate = delegate
        self.styleDelegate = styleDelegate
        self.viewController = viewController
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        fatalError("Implement in subclasses")
    }
    
    func present() {
        fatalError("Implement in subclasses")
    }
    
    func hideWithDuration(duration: TimeInterval) {
        let isBlockingMessage = inAppMessage?.isBlocking ?? false
        if !isBlockingMessage {
            performHide(duration: duration, completionBlock: self.completionBlock)
        }
    }
    
    @objc func hide() {
        let isBlockingMessage = inAppMessage?.isBlocking ?? false
        if isBlockingMessage {
            return
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if self.superview != nil {
            performHide(duration: 0.3, completionBlock: self.completionBlock)
        }
    }
    
    /// Used when a button is pressed, the completion block of the view is not called, but the one passed yes
    @objc func hideWithoutCallingCompletionBlock(completionBlock: (() -> Void)?) {
        let isBlockingMessage = inAppMessage?.isBlocking ?? false
        if isBlockingMessage {
            if let completionBlock = completionBlock {
                completionBlock()
            }
            return
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if self.superview != nil {
            performHide(duration: 0.3, completionBlock: completionBlock)
        }
    }
    
    func performHide(duration: TimeInterval,
                     completionBlock: (() -> Void)? = nil) {
        fatalError("Implement in subclasses")
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        MBMessageMetrics.createMessageMetricForInAppMessage(metric: .interaction, messageId: message.id)
        if let buttonPressedBlock = buttonPressedBlock {
            buttonPressedBlock()
        }
        hideWithoutCallingCompletionBlock {
            guard let buttons = self.inAppMessage?.buttons else {
                return
            }
            if sender == self.button1 {
                if let delegate = self.delegate {
                    delegate.buttonPressed(view: self, button: buttons[0])
                    print("call delegate button1")
                } else {
                    self.openLink(link: buttons[0].link)
                }
            } else if sender == self.button2 {
                if let delegate = self.delegate {
                    delegate.buttonPressed(view: self, button: buttons[1])
                    print("call delegate button2")
                } else {
                    self.openLink(link: buttons[1].link)
                }
            }
        }
    }
    
    private func openLink(link: String?) {
        guard let link = link else {
            return
        }
        if link.hasPrefix("http") {
            if let viewController = viewController {
                if let url = URL(string: link) {
                    let safariViewController = SFSafariViewController(url: url)
                    viewController.present(safariViewController, animated: true, completion: nil)
                }
            }
        }
    }
}
