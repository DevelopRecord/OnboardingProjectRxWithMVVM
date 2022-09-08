//
//  UISearchBar+.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/09/08.
//

import UIKit
import RxSwift
import RxCocoa

extension UISearchBar {

    /// 키보드 툴바
    func setupKeyboardToolbar() {
        let screenWidth = UIScreen.main.bounds.width
        let toolbar = UIToolbar(frame: .init(x: 0, y: 0, width: screenWidth, height: 50))
        toolbar.barStyle = .default
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        lazy var doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(dismissKeyboard))
        
        toolbar.sizeToFit()
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        inputAccessoryView = toolbar
    }
    
    @objc private func dismissKeyboard() {
        resignFirstResponder()
    }
}
