//
//  UIBaseCollectionViewCell.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//

import UIKit

class UIBaseCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRequest()
        setupLayout()
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
        contentView.backgroundColor = .systemBackground
    }
}
