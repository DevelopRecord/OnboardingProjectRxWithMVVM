//
//  UIAnimatable.swift
//  PineoneTutorials
//
//  Created by 이재혁 on 2022/08/24.
//

import UIKit

// where Self란 UIAnimatable의 extension을 다른 클래스에서 UIAnimatable, UIViewController를 상속하지 않으면 사용할 수 없다는 의미
// 한줄요약: UIAnimatable, UIViewController를 상속하지 않으면 extension 기능 사용 못함
/// 로딩 애니메이션 프로토콜
protocol UIAnimatable {
    /// 로딩 애니메이션 보여주는 메서드
    func showLoadingAnimation()
    /// 로딩 애니메이션 숨겨주는 메서드
    func hideLoadingAnimation()
}

extension UIAnimatable {

    /// 로딩 애니메이션 표시
    func showLoadingAnimation() {
        /// 최상위 뷰 찾기. 아래 두가지 방법이 존재. 1번 방식은 iOS 15.0부터 deprecated 된다고 함
        /// 1. isKeyWindow
        /// 2. 연결된 scene 중에서 foreground 상태인지 확인후 UIWindowScene 다운캐스팅, nil 제거 및 옵셔널바인딩

        guard let window = UIApplication.shared.windows.first else { return }

        let loadingIndicatorView = UIActivityIndicatorView(style: .large).then {
            // 로딩 중 로딩 인디케이터 영역 밖 다른 UI를 터치하는 것을 방지하기 위해 최상위 뷰의 프레임에 맞춤
            $0.frame = window.frame
            $0.color = .systemBlue
        }

        window.addSubview(loadingIndicatorView)
        loadingIndicatorView.startAnimating()
    }

    /// 로딩 애니메이션 숨기기
    func hideLoadingAnimation() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else { return }

            /// $0이 UIActivityIndicator인지 타입 체크하고 맞으면 $0을 수퍼뷰로부터 제거
            window.subviews.filter({ $0 is UIActivityIndicatorView }).forEach { $0.removeFromSuperview() }
        }
    }
}
