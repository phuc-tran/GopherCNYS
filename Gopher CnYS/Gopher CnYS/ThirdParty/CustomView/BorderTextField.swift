//
//  BorderTextField.swift
//  MemberCard
//
//  Created by Phung Minh Tri on 3/18/15.
//  Copyright (c) 2015 Current. All rights reserved.
//

import UIKit

class BorderTextField: UITextField {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        textColor = UIColor.whiteColor()
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        layer.borderColor = UIColor( red: 170/255, green: 201/255, blue:222/255, alpha: 1.0 ).CGColor
        layer.borderWidth = 1.0
        attributedPlaceholder = NSAttributedString(string:placeholder!, attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        let paddingView = UIView(frame: CGRectMake(0, 0, 10, frame.height))
        leftView = paddingView
        leftViewMode = UITextFieldViewMode.Always
    }
    
    func applyStyle(radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat, isFilled: Bool) {
        layer.borderColor = borderColor.CGColor
        layer.borderWidth = borderWidth
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
}
