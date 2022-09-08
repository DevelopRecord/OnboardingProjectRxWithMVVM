//
//  UIView+.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//

import UIKit

extension UIView {
    
    /// 한번에 여러 View를 addSubview() 동작을 수행하는 함수
    func addSubviews(views: [UIView]) {
        views.forEach { self.addSubview($0) }
    }
    
    /// UIView Width 설정 함수
    func setWidth(_ width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    /// UIView Height 설정 함수
    func setHeight(_ height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    /// UIView Width, Height 설정 함수
    func setDimensions(width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
}
