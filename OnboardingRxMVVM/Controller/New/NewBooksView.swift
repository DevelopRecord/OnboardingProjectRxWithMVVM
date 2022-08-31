//
//  NewBooksView.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class NewBooksView: UIBaseView {

    // MARK: - Properties
    
    private var newBooks: BookResponse?
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .clear
        $0.register(NewBooksCell.self, forCellWithReuseIdentifier: NewBooksCell.identifier)
    }
    
    // MARK: - Model type implemente

    typealias Model = Void

    // MARK: - Methods
    
    override func setupLayout() {
        backgroundColor = .clear

        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
