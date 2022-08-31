//
//  UIViewController+.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//

import UIKit

extension UIViewController {

    /// 네비게이션바 설정 함수
    func setupNavigationBar(title: String, isLargeTitle: Bool, searchController: UISearchController? = nil) {
        self.navigationItem.title = title
        self.navigationController?.navigationBar.prefersLargeTitles = isLargeTitle
        self.navigationItem.searchController = searchController
    }

    /// 토스트 함수
    func showToast(message: String) {
        let width: CGFloat = 20
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else { return }
            
            let toastLabel = UILabel(frame: CGRect(x: width, y: window.frame.size.height / 2 + 50, width: window.frame.size.width - 2 * width, height: 55))
            toastLabel.backgroundColor = UIColor.systemGray5
            toastLabel.textAlignment = .center
            toastLabel.font = UIFont.boldSystemFont(ofSize: 20)
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10
            toastLabel.clipsToBounds = true
            self.view.addSubview(toastLabel)
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                
                 /// withDuration: 사라지는 속도
                 /// delay: 뷰가 몇초동안 존재하는지
                 /// curveEaseOut - 빠르게 나타났다 느리게 사라지는 애니메이션
                toastLabel.alpha = 0.0 // alpha값을 0으로 줘서 사라지게 함
            }, completion: { (isCompleted) in
                    toastLabel.removeFromSuperview() // SuperView로부터 삭제
                })
        }
    }

    /// 뷰에서 키보드를 제외한 주변 탭 시 키보드 dismiss 설정 함수
    func dismissKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }
}
