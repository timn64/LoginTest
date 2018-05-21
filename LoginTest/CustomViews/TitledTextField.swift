//
//  TitledTextField.swift
//  LoginTest
//
//  Created by Тимур Насыров on 17.05.2018.
//  Copyright © 2018 Тимур Насыров. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable class TitledTextField: CustomViewWithXib {

    override var xibFileName: String { return "TitledTextField" }
    
    @IBInspectable var isButtonHidden: Bool {
        get {
            return optionalButton.isHidden
        }
        set {
            optionalButton.isHidden = newValue
        }
    }
    @IBInspectable var fieldTitle: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    @IBInspectable var buttonTitle: String? {
        get {
            return optionalButton.title(for: .normal)
        }
        set {
            optionalButton.setTitle(newValue, for:.normal)
        }
    }
    
    @IBOutlet private weak var optionalButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var onButtonTouch: (()->Void)?
    
    override func onXibSetup() {
        isButtonHidden = true
        
        // рисуем рамку вокруг кнопки
        optionalButton.layer.borderWidth = 1.0
        optionalButton.layer.borderColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1).cgColor
        optionalButton.layer.cornerRadius = 5.0

        optionalButton.isHidden = isButtonHidden
        titleLabel.text = fieldTitle
    }
    
    @IBAction private func buttonTouched(_ sender: UIButton) {
        onButtonTouch?()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
