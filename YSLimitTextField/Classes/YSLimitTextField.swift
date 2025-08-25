//
// *************************************************
//  YSLimitTextField.swift
//  YSLimitTextField
//
// Created by Joseph Koh on 2023/11/14.
// Author: Joseph Koh
// Email: Joseph0750@gmail.com
// Create Time: 2023/11/14 00:55
// *************************************************
//

import UIKit

// MARK: - YSLimitTextField

@objc(YSLimitTextField)
public class YSLimitTextField: UITextField, YSLimitCreateProtocol {
    public enum LimitType {
        case none
        case numbersOnly
        case lettersOnly
        case lettersAndNumbers
        case lettersAndSpacesOnly
        /// a-z
        case lettersAndPuncturation
        case wordsAndSpacesOnly
        case email
        case condition((Character) -> Bool)
    }

    public enum LetterCase {
        case none
        case uppercase
        case lowercase
    }

    public enum PreformActionType {
        case none
        case copy
        case paste
        case copyAndPaste
        case all
    }

    public var limitType: LimitType = .none {
        didSet {
            applyTextLimit()
        }
    }

    public var groupSize: Int = -1 {
        didSet {
            applyTextLimit()
        }
    }

    public var letterCase: LetterCase = .none {
        didSet {
            applyTextLimit()
        }
    }

    public var maxLength: Int = -1 {
        didSet {
            applyTextLimit()
        }
    }

    public var focusBorderColor: UIColor? {
        didSet {
            updateBorderColor()
        }
    }

    public var borderColor: UIColor? {
        didSet {
            updateBorderColor()
        }
    }

    public var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    public var allowedPreformAction: PreformActionType = .all
    public let customClearButton = UIButton()
    private let clearButtonWrapper = UIView()
    private let leftWrapperView = UIView()

    public var onTextChange: ((String?) -> Void)?
    public var editStatusChange: ((Bool) -> Void)?
    public var returnButtonClickHandler: (() -> Void)?

    public var contentInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsDisplay()
        }
    }

    override public var text: String? {
        didSet {
            updateClearButton()
            applyTextLimit()
        }
    }

    @objc public dynamic var placeholderColor: UIColor? {
        didSet {
            updatePlaceholder()
        }
    }

    override public var placeholder: String? {
        didSet {
            updatePlaceholder()
        }
    }

    override public var font: UIFont? {
        didSet {
            updatePlaceholder()
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        leftWrapperView.bounds = CGRect(
            x: 0, y: 0, width: contentInsets.left, height: bounds.size.height
        )
    }

    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch allowedPreformAction {
        case .none:
            return false

        case .copy:
            if action == #selector(copy(_:)) {
                return true
            }
            else if action == #selector(paste(_:))
                || action == #selector(cut(_:))
                || action == #selector(select(_:))
                || action == #selector(selectAll(_:)) {
                return false
            }

        case .paste:
            if action == #selector(paste(_:)) {
                return true
            }
            else if action == #selector(copy(_:))
                || action == #selector(cut(_:))
                || action == #selector(select(_:))
                || action == #selector(selectAll(_:)) {
                return false
            }

        case .copyAndPaste:
            if action == #selector(copy(_:)) || action == #selector(paste(_:)) {
                return true
            }
            else if action == #selector(cut(_:))
                || action == #selector(select(_:))
                || action == #selector(selectAll(_:)) {
                return false
            }

        case .all:
            break
        }
        return super.canPerformAction(action, withSender: sender)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        applyTextLimit()
        updateClearButton()
        onTextChange?(textField.text)
    }

    @objc private func returnButtonOnClicked() {
        resignFirstResponder()
        returnButtonClickHandler?()
    }

    @objc private func clearTextField() {
        text = ""
        sendActions(for: .editingChanged)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        onTextChange = nil
        editStatusChange = nil
        returnButtonClickHandler = nil
    }
}

private extension YSLimitTextField {
    func initialSetup() {
        autocorrectionType = .no
        layer.borderColor = borderColor?.cgColor ?? nil

        setupLeftPadding()
        setupClearButton()

        setupNotifications()
        addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        addTarget(self, action: #selector(returnButtonOnClicked), for: .editingDidEndOnExit)
    }

    func setupLeftPadding() {
        leftWrapperView.bounds = CGRect(
            x: 0, y: 0, width: contentInsets.left, height: bounds.size.height
        )
        leftView = leftWrapperView
        leftViewMode = .always
    }

    func setupClearButton() {
        let margin: CGFloat = 5.0
        let wh: CGFloat = 16.0
        customClearButton.setImage(UIImage(named: "ic_close_blue"), for: .normal)
        customClearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        customClearButton.frame = CGRect(x: margin, y: 0, width: wh, height: wh)
        clearButtonWrapper.addSubview(customClearButton)

        rightView = clearButtonWrapper
        rightViewMode = .always

        updateClearButton()
    }

    func updateClearButton() {
        if clearButtonMode == .whileEditing {
            if let _text = text, !_text.isEmpty, isEditing {
                customClearButton.isHidden = false
            }
            else {
                customClearButton.isHidden = true
            }
        }
        else if clearButtonMode == .always {
            customClearButton.isHidden = false
        }
        else {
            customClearButton.isHidden = true
        }

        updateClearButtonWidth()
    }

    func updateClearButtonWidth() {
        if clearButtonMode == .whileEditing || clearButtonMode == .always {
            let margin: CGFloat = 5.0
            let wh: CGFloat = 16.0
            let w = customClearButton.isHidden ? contentInsets.right : wh + margin + contentInsets.right
            clearButtonWrapper.bounds = CGRect(x: 0, y: 0, width: w, height: wh)
        }
    }

    func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editingBeganNotification(_:)),
            name: UITextField.textDidBeginEditingNotification,
            object: self
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editingEndedNotification(_:)),
            name: UITextField.textDidEndEditingNotification,
            object: self
        )
    }

    @objc private func editingBeganNotification(_: Notification) {
        layer.borderColor = focusBorderColor?.cgColor ?? nil
        editStatusChange?(true)

        if clearButtonMode != .never {
            customClearButton.isHidden = (text?.count ?? 0) == 0
            updateClearButtonWidth()
        }
    }

    @objc private func editingEndedNotification(_: Notification) {
        layer.borderColor = borderColor?.cgColor ?? nil

        if clearButtonMode != .always {
            customClearButton.isHidden = true
            updateClearButtonWidth()
        }

        editStatusChange?(false)
    }

    func updateBorderColor() {
        if isEditing {
            layer.borderColor = focusBorderColor != nil ? focusBorderColor!.cgColor : nil
        }
        else {
            layer.borderColor = borderColor != nil ? borderColor!.cgColor : nil
        }
    }

    func applyTextLimit() {
        guard let text else {
            return
        }

        var processedText = text

        switch limitType {
        case .none:
            break

        case .numbersOnly:
            processedText = processedText.filter(\.isNumber)

        case .lettersOnly:
            processedText = processedText.filter(\.isEnglishLetter)

        case .lettersAndNumbers:
            processedText = processedText.filter { $0.isEnglishLetter || $0.isNumber }

        case .lettersAndSpacesOnly:
            processedText = processedText.filter { $0.isEnglishLetter || $0.isWhitespace }

        case .wordsAndSpacesOnly:
            processedText = processedText.filter { $0.isLetter || $0.isWhitespace }

        case .lettersAndPuncturation:
            processedText = processedText
                    .filter { $0.isEnglishLetter || $0.isWhitespace || $0.isEnglishLetterPunctuationOrSpace }

        case .email:
            processedText = processedText.filter(\.isEmailLetter)

        case let .condition(condition):
            processedText = processedText.filter(condition)
        }

        switch letterCase {
        case .none:
            break
        case .uppercase:
            processedText = processedText.uppercased()
        case .lowercase:
            processedText = processedText.lowercased()
        }

        if groupSize > 0 {
            let textWithoutSpaces = processedText.filter { !$0.isWhitespace }
            let trimmedText =
                maxLength > 0 ? String(textWithoutSpaces.prefix(maxLength)) : textWithoutSpaces
            processedText = formatTextWithGrouping(trimmedText, groupSize: groupSize)
        }
        else {
            if maxLength > 0, processedText.count > maxLength {
                processedText = String(processedText.prefix(maxLength))
            }
        }

        super.text = processedText
    }

    func formatTextWithGrouping(_ text: String, groupSize: Int) -> String {
        guard groupSize > 0 else {
            return text
        }

        var formattedText = ""
        var count = 0

        for character in text {
            if count == groupSize {
                formattedText += " "
                count = 0
            }

            formattedText += String(character)
            count += 1
        }

        return formattedText
    }
}

private extension YSLimitTextField {
    func updatePlaceholder() {
        guard let placeholder, let font else {
            return
        }

        var attributes: [NSAttributedString.Key: Any] = [.font: font]

        if let placeholderColor {
            attributes[NSAttributedString.Key.foregroundColor] = placeholderColor
        }

        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
    }
}

// MARK: - YSLimitCreateProtocol

public protocol YSLimitCreateProtocol {}

public extension YSLimitCreateProtocol where Self: YSLimitTextField {
    @discardableResult
    func setLimitType(_ limitType: LimitType) -> Self {
        self.limitType = limitType
        return self
    }

    @discardableResult
    func setGroupSize(_ groupSize: Int) -> Self {
        self.groupSize = groupSize
        return self
    }

    @discardableResult
    func setLetterCase(_ letterCase: LetterCase) -> Self {
        self.letterCase = letterCase
        return self
    }

    @discardableResult
    func setMaxLength(_ maxLength: Int) -> Self {
        self.maxLength = maxLength
        return self
    }

    @discardableResult
    func setFocusBorderColor(_ focusBorderColor: UIColor?) -> Self {
        self.focusBorderColor = focusBorderColor
        return self
    }

    @discardableResult
    func setBorderColor(_ borderColor: UIColor?) -> Self {
        self.borderColor = borderColor
        return self
    }

    @discardableResult
    func setBorderWidth(_ borderWidth: CGFloat) -> Self {
        self.borderWidth = borderWidth
        return self
    }

    @discardableResult
    func setClearButtonMode(_ mode: UITextField.ViewMode) -> Self {
        clearButtonMode = mode
        return self
    }

    @discardableResult
    func setAllowedPreformAction(_ type: PreformActionType) -> Self {
        allowedPreformAction = type
        return self
    }

    @discardableResult
    func setContentInsets(_ contentInsets: UIEdgeInsets) -> Self {
        self.contentInsets = contentInsets
        return self
    }

    @discardableResult
    func onTextChange(_ action: @escaping (String?) -> Void) -> Self {
        onTextChange = action
        return self
    }

    @discardableResult
    func onEditStatusChange(_ action: @escaping (Bool) -> Void) -> Self {
        editStatusChange = action
        return self
    }

    @discardableResult
    func onReturnButtonClick(_ action: @escaping () -> Void) -> Self {
        returnButtonClickHandler = action
        return self
    }
}
