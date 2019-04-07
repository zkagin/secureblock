//
//  InfoViewController.swift
//  SecureBlock
//
//  Created by Zach Kagin on 4/6/19.
//  Copyright © 2019 Zach Kagin. All rights reserved.
//

import UIKit

enum InfoViewType {
    case info
    case enableBlocking
}

/**
 * Static page for displaying basic information about the app or instructions on how to enable blocking.
 */
class InfoViewController: UIViewController {

    let infoViewType: InfoViewType
    init(infoViewType: InfoViewType) {
        self.infoViewType = infoViewType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 1, alpha: 0.95)
        configureSubviews()
    }

    private func configureSubviews() {
        let infoLabel = InfoViewController.createInfoLabel(infoViewType: infoViewType)
        let exitButton = InfoViewController.createExitButton()

        view.addSubview(infoLabel)
        view.addSubview(exitButton)

        NSLayoutConstraint.activate([
            infoLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            infoLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            exitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            exitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])

        exitButton.addTarget(self, action: #selector(dismissPage), for: .touchUpInside)
    }

    private static func createInfoLabel(infoViewType: InfoViewType) -> UILabel {
        let infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        let infoString = infoLabelText(infoViewType: infoViewType)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.paragraphSpacing = 15.0
        let attributes = [NSAttributedString.Key.paragraphStyle : paragraphStyle]
        infoLabel.attributedText = NSAttributedString(string: infoString, attributes: attributes)
        infoLabel.numberOfLines = 0
        infoLabel.lineBreakMode = .byWordWrapping
        infoLabel.textAlignment = .center
        return infoLabel

    }

    private static func infoLabelText(infoViewType: InfoViewType) -> String {
        switch infoViewType {
        case .info:
            return "Source available at github.com/zkagin\n"
                   + "\u{00A9} 2019 Kagin Labs"
        case .enableBlocking:
            return "Steps to enable:\n"
                   + "1. Open Settings\n"
                   + "2. Open Phone Settings\n"
                   + "3. Open Call Blocking & Identification\n"
                   + "4. Turn on SecureBlock"
        }
    }

    private static func createExitButton() -> UIButton {
        let exitButton = UIButton(type: .system)
        exitButton.setTitle("\u{2716}", for: .normal)
        exitButton.setTitleColor(.black, for: .normal)
        exitButton.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .heavy)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        return exitButton
    }

    @objc private func dismissPage() {
        dismiss(animated: true, completion: nil)
    }

}
