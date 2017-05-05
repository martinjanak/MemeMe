//
//  MemeTextFieldDelegate.swift
//  MemeMe
//
//  Created by Martin Janák on 05/05/2017.
//  Copyright © 2017 Martin Janák. All rights reserved.
//

import Foundation
import UIKit

class MemeTextFieldDelegate: NSObject, UITextFieldDelegate {

    let defaultText:String
    
    init(defaultText: String) {
        self.defaultText = defaultText
        super.init()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == defaultText {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }

}
