//
//  RootViewController.swift
//  SecureBlock
//
//  Created by Zach Kagin on 1/26/19.
//  Copyright © 2019 Zach Kagin. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    // MARK:- Static Constants
    static let vSpacing:CGFloat = 26
    static let hPadding:CGFloat = 24
    static let standardHeight:CGFloat = 40
    static let standardFontSize:CGFloat = 16
    static let logoSize:CGFloat = 130
    static let countryInfo = PhoneNumber.countryInfo()
    static let textColor = UIColor(white: 0.4, alpha: 1)
    static let blueButtonColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.6)
    
    // MARK:- Global Variables
    let countryCodeButton = createCountryCodeButton()
    let countryCodePicker = UIPickerView()
    let countryCodeHiddenTextField = UITextField()
    let enableButton = RootViewController.createBlueButton(title: "Enable Call Blocking")
    let numberInputField = createNumberInputField()
    let instructionLabel = RootViewController.createInstructionLabel()
    lazy var inputContainer = RootViewController.createInputContainer(button: countryCodeButton, textField: numberInputField)
    let blockButton = RootViewController.createBlueButton(title: "Block")
    let deleteAllButton = createTableHeaderViewButton(title: "Delete All")
    let editButton = createTableHeaderViewButton(title: "Edit")
    let blockListTableView = createBlockListTableView()
    var topPaddingConstraint: NSLayoutConstraint?
    var currentBlockedNumbers = PhoneNumber.retrieveStoredNumbers()
    var currentCountryCode = 0
    var blockingIsEnabled = true // Default to true for now until this can be locally cached.
    
    // MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.85, green: 0.9, blue: 1, alpha: 1)
        configureSubviews()
    }
    
    private func configureSubviews() {
        // Create non-global views
        let infoButton = RootViewController.createInfoButton()
        let logoImageView = RootViewController.createLogoImageView()
        let tableHeaderView = RootViewController.createTableHeaderView(deleteAllButton: deleteAllButton, editButton: editButton)
        let countryCodeToolbar = createCountryCodeToolbar()

        
        // Add all views to their correct superview
        view.addSubview(infoButton)
        view.addSubview(logoImageView)
        view.addSubview(enableButton)
        view.addSubview(instructionLabel)
        view.addSubview(inputContainer)
        view.addSubview(blockButton)
        view.addSubview(tableHeaderView)
        view.addSubview(blockListTableView)
        view.addSubview(countryCodeHiddenTextField)
        
        // Configure global objects that require self.
        blockListTableView.dataSource = self
        blockListTableView.delegate = self
        numberInputField.delegate = self
        countryCodePicker.dataSource = self
        countryCodePicker.delegate = self
        
        countryCodeHiddenTextField.isHidden = true
        countryCodeHiddenTextField.inputView = countryCodePicker
        countryCodeHiddenTextField.inputAccessoryView = countryCodeToolbar

        infoButton.addTarget(self, action: #selector(didTapInfoButton), for: .touchUpInside)
        enableButton.addTarget(self, action: #selector(didTapEnableButton), for: .touchUpInside)
        countryCodeButton.addTarget(self, action: #selector(didTapCountryCodeButton), for: .touchUpInside)
        blockButton.addTarget(self, action: #selector(didTapBlockButton), for: .touchUpInside)
        deleteAllButton.addTarget(self, action: #selector(didTapDeleteAllButton), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
        
        // Gesture recognizer for dismissing when you "tap anywhere"
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
        
        // Set up constraints
        topPaddingConstraint = logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: RootViewController.vSpacing)
        topPaddingConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            infoButton.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            infoButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: RootViewController.logoSize),
            logoImageView.widthAnchor.constraint(equalToConstant: RootViewController.logoSize),
            enableButton.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: RootViewController.vSpacing),
            enableButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enableButton.widthAnchor.constraint(equalToConstant: RootViewController.standardHeight*5),
            enableButton.heightAnchor.constraint(equalToConstant: RootViewController.standardHeight),
            instructionLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: RootViewController.vSpacing),
            instructionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: RootViewController.hPadding),
            instructionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -RootViewController.hPadding),
            inputContainer.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: RootViewController.vSpacing),
            inputContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: RootViewController.hPadding*2),
            inputContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -RootViewController.hPadding*2),
            inputContainer.heightAnchor.constraint(equalToConstant: RootViewController.standardHeight),
            blockButton.topAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: RootViewController.vSpacing),
            blockButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blockButton.widthAnchor.constraint(equalToConstant: RootViewController.standardHeight*2),
            blockButton.heightAnchor.constraint(equalToConstant: RootViewController.standardHeight),
            tableHeaderView.topAnchor.constraint(equalTo: blockButton.bottomAnchor, constant: RootViewController.vSpacing/2),
            tableHeaderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableHeaderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableHeaderView.heightAnchor.constraint(equalToConstant: RootViewController.standardHeight),
            blockListTableView.topAnchor.constraint(equalTo: tableHeaderView.bottomAnchor),
            blockListTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            blockListTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            blockListTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // Set up defaults
        updateCountryCode(codeNumber: 1)  // USA
        updateVisibleObjects(animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkBlockingEnabled()
    }

    public func checkBlockingEnabled() {
        PhoneNumber.checkBlockingEnabled { (enabled) in
            if self.blockingIsEnabled != enabled {
                self.blockingIsEnabled = enabled
                self.updateVisibleObjects(animated: true)
            }
        }
    }
}

// MARK:- Object Creation Methods
extension RootViewController {
    
    private static func createLogoImageView() -> UIView {
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(named: "logo")
        logoImageView.contentMode = .scaleAspectFit
        return logoImageView
    }
    
    private static func createInstructionLabel() -> UILabel {
        let instructionLabel = UILabel()
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.textAlignment = .center
        instructionLabel.textColor = RootViewController.textColor
        instructionLabel.text = "Block numbers that start with..."
        instructionLabel.font = UIFont.systemFont(ofSize: RootViewController.standardFontSize, weight: .medium)
        return instructionLabel
    }
    
    private static func createInputContainer(button: UIButton, textField: UITextField) -> UIView {
        let inputContainer = UIView()
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.backgroundColor = UIColor.white
        inputContainer.layer.cornerRadius = 3
        inputContainer.clipsToBounds = true
        inputContainer.layer.borderColor = UIColor(white: 0.8, alpha: 1).cgColor
        inputContainer.layer.borderWidth = 1
        
        inputContainer.addSubview(button)
        inputContainer.addSubview(textField)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: inputContainer.topAnchor),
            button.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor),
            button.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: textField.leadingAnchor, constant: -10),
            button.widthAnchor.constraint(equalToConstant: 100),
            textField.topAnchor.constraint(equalTo: inputContainer.topAnchor),
            textField.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor),
            textField.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor),
        ])
        
        return inputContainer
    }
    
    private static func createCountryCodeButton() -> UIButton {
        let countryCodeButton = UIButton(type: UIButton.ButtonType.system)
        countryCodeButton.translatesAutoresizingMaskIntoConstraints = false
        countryCodeButton.setTitleColor(UIColor(red: 0.3, green: 0.3, blue: 0.8, alpha: 0.6), for: .normal)
        countryCodeButton.titleLabel?.font = UIFont.systemFont(ofSize: RootViewController.standardFontSize, weight: .regular)
        countryCodeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0)
        countryCodeButton.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        countryCodeButton.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 1, alpha: 1)
        return countryCodeButton
    }
    
    private static func createNumberInputField() -> UITextField {
        let numberInputField = UITextField()
        numberInputField.translatesAutoresizingMaskIntoConstraints = false
        numberInputField.clearButtonMode = .whileEditing
        numberInputField.backgroundColor = UIColor.white
        numberInputField.placeholder = "415 888 8888"
        numberInputField.borderStyle = .none
        numberInputField.keyboardType = .phonePad
        numberInputField.textColor = RootViewController.textColor
        return numberInputField
    }
    
    private static func createBlueButton(title: String) -> UIButton {
        let blueButton = UIButton(type: UIButton.ButtonType.system)
        blueButton.translatesAutoresizingMaskIntoConstraints = false
        blueButton.setTitle(title, for: .normal)
        blueButton.setTitleColor(UIColor.white, for: .normal)
        blueButton.titleLabel?.font = UIFont.systemFont(ofSize: RootViewController.standardFontSize, weight: .semibold)
        blueButton.backgroundColor = RootViewController.blueButtonColor
        blueButton.layer.cornerRadius = 3
        blueButton.clipsToBounds = true
        return blueButton
    }

    private static func createInfoButton() -> UIButton {
        let infoButton = UIButton(type: UIButton.ButtonType.system)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.setBackgroundImage(UIImage(named: "info")?.withRenderingMode(.alwaysTemplate), for: .normal)
        infoButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        infoButton.heightAnchor.constraint(equalTo: infoButton.widthAnchor).isActive = true
        infoButton.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.7, alpha: 1)
        return infoButton
    }
    
    private static func createTableHeaderView(deleteAllButton: UIButton, editButton: UIButton) -> UIView {
        let tableHeaderView = UIView()
        tableHeaderView.translatesAutoresizingMaskIntoConstraints = false
        tableHeaderView.addSubview(deleteAllButton)
        tableHeaderView.addSubview(editButton)
        NSLayoutConstraint.activate([
            deleteAllButton.centerYAnchor.constraint(equalTo: tableHeaderView.centerYAnchor),
            deleteAllButton.leadingAnchor.constraint(equalTo: tableHeaderView.leadingAnchor, constant: RootViewController.hPadding),
            editButton.centerYAnchor.constraint(equalTo: tableHeaderView.centerYAnchor),
            editButton.trailingAnchor.constraint(equalTo: tableHeaderView.trailingAnchor, constant: -RootViewController.hPadding),
        ])
        return tableHeaderView
    }
    
    private static func createTableHeaderViewButton(title: String) -> UIButton {
        let tableHeaderViewButton = UIButton(type: UIButton.ButtonType.system)
        tableHeaderViewButton.translatesAutoresizingMaskIntoConstraints = false
        tableHeaderViewButton.setTitle(title, for: .normal)
        return tableHeaderViewButton
    }
    
    private static func createBlockListTableView() -> UITableView {
        let blockListTableView = UITableView(frame: CGRect.zero, style: .grouped)
        blockListTableView.translatesAutoresizingMaskIntoConstraints = false
        blockListTableView.backgroundColor = UIColor.white
        blockListTableView.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        blockListTableView.allowsSelection = false
        return blockListTableView
    }
    
    private func createCountryCodeToolbar() -> UIToolbar {
        let countryCodeToolbar = UIToolbar()
        countryCodeToolbar.sizeToFit()
        countryCodeToolbar.isTranslucent = true
        countryCodeToolbar.tintColor = UIColor.darkGray
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapCountryCodeDoneButton))
        countryCodeToolbar.setItems([flexButton, doneButton], animated: false)
        return countryCodeToolbar
    }
}

// MARK:- Button Responses
extension RootViewController {
    
    @objc private func didTapCountryCodeButton() {
        countryCodeHiddenTextField.becomeFirstResponder()
    }
    
    @objc private func didTapCountryCodeDoneButton() {
        countryCodeHiddenTextField.resignFirstResponder()
        updateCountryCode(codeNumber: countryCodePicker.selectedRow(inComponent: 0))
    }

    @objc private func didTapInfoButton() {
        let infoVC = InfoViewController(infoViewType: .info)
        infoVC.modalPresentationStyle = .overCurrentContext
        present(infoVC, animated: true, completion: nil)
    }

    @objc private func didTapEnableButton() {
        let infoVC = InfoViewController(infoViewType: .enableBlocking)
        infoVC.modalPresentationStyle = .overCurrentContext
        present(infoVC, animated: true, completion: nil)
    }
    
    @objc private func didTapBlockButton() {
        let inputValue = numberInputField.text?.replacingOccurrences(of: " ", with: "")
        if let inputValue = inputValue, inputValue.count > 0 {
            numberInputField.text = nil
            let countryCode = RootViewController.countryInfo[currentCountryCode].2
            let newBlockedPhoneNumber = PhoneNumber(countryCode: countryCode, phoneNumber: inputValue)
            addNumber(newBlockedPhoneNumber)
            setTableViewEditMode(false)
            blockListTableView.reloadData()
            
        }
        dismissKeyboard()
    }
    
    @objc private func didTapEditButton() {
        if currentBlockedNumbers.count > 0 {
            setTableViewEditMode(!blockListTableView.isEditing)
        }
    }
    
    @objc private func didTapDeleteAllButton() {
        deleteAllNumbers()
        blockListTableView.reloadData()
    }
    
    @objc private func dismissKeyboard() {
        if numberInputField.isFirstResponder {
            numberInputField.resignFirstResponder()
        }
        if countryCodeHiddenTextField.isFirstResponder {
            countryCodeHiddenTextField.resignFirstResponder()
        }
    }
}

// MARK:- Private Helpers
extension RootViewController {

    /**
     Updates all items in the view to the proper visibility, including:
      - Delete All Button
      - Edit Button
      - List of blocked numbers
      - Constraints for the main page.
     */
    private func updateVisibleObjects(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.4 : 0.0) {
            let hasBlockedNumbers = self.currentBlockedNumbers.count > 0 && self.blockingIsEnabled
            let blockListAlpha: CGFloat = hasBlockedNumbers ? 1 : 0
            self.enableButton.alpha = self.blockingIsEnabled ? 0 : 1
            self.instructionLabel.alpha = self.blockingIsEnabled ? 1 : 0
            self.inputContainer.alpha = self.blockingIsEnabled ? 1 : 0
            self.blockButton.alpha = self.blockingIsEnabled ? 1 : 0
            self.deleteAllButton.alpha = self.blockListTableView.isEditing ? blockListAlpha : 0
            self.editButton.alpha = blockListAlpha
            self.blockListTableView.alpha = blockListAlpha
            self.topPaddingConstraint?.constant = hasBlockedNumbers ? RootViewController.vSpacing : 120
            self.view.layoutIfNeeded()
        }
    }
    
    private func setTableViewEditMode(_ isEditing: Bool) {
        blockListTableView.setEditing(isEditing, animated: true)
        updateVisibleObjects(animated: true)
    }
    
    private func addNumber(_ number: PhoneNumber) {
        if !currentBlockedNumbers.contains(number) {
            currentBlockedNumbers.append(number)
            PhoneNumber.storeNumbers(currentBlockedNumbers)
        }
    }
    
    private func removeNumber(_ number: PhoneNumber) {
        currentBlockedNumbers = currentBlockedNumbers.filter{ $0 != number}
        PhoneNumber.storeNumbers(currentBlockedNumbers)
    }
    
    private func deleteAllNumbers() {
        currentBlockedNumbers = []
        PhoneNumber.storeNumbers(currentBlockedNumbers)
        setTableViewEditMode(false)
    }
    
    private func updateCountryCode(codeNumber: Int) {
        currentCountryCode = codeNumber
        let countryCodeTitle = RootViewController.stringForCountryCode(codeNumber, fullName: false)
        countryCodeButton.setTitle(countryCodeTitle, for: .normal)
        countryCodePicker.selectRow(codeNumber, inComponent: 0, animated: false)
    }

    /**
     Generates a string based on a country code number.
     e.g. (CO) +57
     e.g. United States +1
     - Parameters:
        - codeNumber: The order number in the list of countries for the desired country.
        - fullName: Whether or not the full name of the country should be displayed.
     */
    private static func stringForCountryCode(_ codeNumber: Int, fullName: Bool) -> String {
        let countryCodePair = RootViewController.countryInfo[codeNumber]
        let countryCodeName = fullName ? countryCodePair.1 : "(" + countryCodePair.0 + ")"
        return countryCodeName + " +" + countryCodePair.2
    }
}

// MARK:- UITableViewDataSource, UITableViewDelegate

extension RootViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentBlockedNumbers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let blockedNumber = currentBlockedNumbers[indexPath.row]
        cell.textLabel?.text = PhoneNumber.formatNumber(countryCode: blockedNumber.countryCode,
                                                        phoneNumber: blockedNumber.phoneNumber)
        cell.textLabel?.textColor = RootViewController.textColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeNumber(currentBlockedNumbers[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            if currentBlockedNumbers.count == 0 {
                setTableViewEditMode(false)
            }
        }
    }
}

// MARK:- UIPickerViewDataSource, UIPickerViewDelegate
extension RootViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return RootViewController.countryInfo.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return RootViewController.stringForCountryCode(row, fullName: true)
    }
}

// MARK:- UITextFieldDelegate
extension RootViewController: UITextFieldDelegate {

    /**
     Auto-formats any text typed into the input field so it has spaces the way a normal 10 digit number would have.
     Prevents the user from typing more than 10 digits.
     e.g. 612 867 5309
     */
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return false }
        if range.length == 1 {
            // Deletion
            if range.location == 4 || range.location == 8 {
                textField.text = String(currentText.dropLast(2)) // Delete the charaacter and the extra space.
                return false
            }
        } else {
            // Addition
            if range.location == 3 || range.location == 7 {
                textField.text = currentText + " "
                return true
            }
            
            if range.location > 11 {
                return false
            }
        }
        return true
    }
}
