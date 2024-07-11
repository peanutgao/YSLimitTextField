//
//  ViewController.swift
//  YSLimitTextField
//
//  Created by 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 on 01/10/2024.
//  Copyright (c) 2024 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. All rights reserved.
//

import UIKit
import YSLimitTextField

class ViewController: UIViewController {

    let textField = YSLimitTextField(frame: CGRect(x: 20, y: 100, width: 200, height: 40))

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(textField)

        textField.borderStyle = .roundedRect
        textField.limitType = .numbersOnly
        textField.maxLength = 12
        textField.groupSize = 4
        textField.allowedPreformAction = .paste
        textField.contentInsets = .init(top: 5, left: 15, bottom: 0, right: 15)

        textField.backgroundColor = .lightGray
        textField.clearButtonMode = .whileEditing
        textField.text = "88888sss8888" // 123131231231
        textField.onTextChange = { str in
            print(str)
        }
        print(textField.text)
        print(textField.text?.count)
    }

    @IBAction func getText(_: Any) {
        print(textField.text)
        textField.text = nil
        print(textField.text)
    }
    @IBAction func enableChange(_ sender: Any) {
        
        textField.isEnabled = !textField.isEnabled
    }

}

