//
//  UIBaseView.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//

import UIKit

import Kingfisher
import RxCocoa
import RxSwift
import SnapKit
import Then

/// UIView를 상속하는 BaseView
class UIBaseView: UIView {
    
    // MARK: - Properties
    
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupRequest()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    /// 데이터 셋업 메서드
    func setupRequest() {
        
    }
    
    /// 레이아웃 셋업 메서드
    func setupLayout() {
        backgroundColor = .systemBackground
    }
}
