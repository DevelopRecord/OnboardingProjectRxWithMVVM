//
//  Toast.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/09/01.
//

import UIKit

/// 토스트 클래스
final class Toast: NSObject {
    
    /// 토스트 클래스 싱글톤
    static let shared = Toast()
    
    private lazy var toastMessageLabel = UILabel().then {
        $0.backgroundColor = UIColor.systemGray5
        $0.textAlignment = .center
        $0.font = UIFont.boldSystemFont(ofSize: 20)
        $0.alpha = 1
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    func showToast(_ message: String) {
        toastMessageLabel.text = message

        /// 최상위 뷰
        guard let window = UIApplication.shared.windows.first else { return }
        
        window.addSubview(toastMessageLabel)
        toastMessageLabel.frame = CGRect(x: 20.0, y: window.frame.size.height / 2, width: window.frame.size.width - 2 * 20.0, height: 55)
        UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: { [weak self] in
            guard let `self` = self else { return }
            self.toastMessageLabel.alpha = 0.0
        }, completion: { [weak self] (isCompleted) in
            guard let `self` = self else { return }
            self.toastMessageLabel.alpha = 1.0
            self.toastMessageLabel.removeFromSuperview()
            })
    }
}
