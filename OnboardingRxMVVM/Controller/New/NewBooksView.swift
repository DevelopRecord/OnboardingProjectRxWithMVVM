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

    var disposeBag = DisposeBag()

    /// 사용자의 액션을 담는 데이터 요청 트리거
    private var actionTriggers: PublishRelay<NewBooksTriggerType> = PublishRelay<NewBooksTriggerType>()

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .clear
        $0.register(NewBooksCell.self, forCellWithReuseIdentifier: NewBooksCell.identifier)
    }

    // MARK: - Model type implemente

    typealias Model = Void

    override init(frame: CGRect) {
        super.init(frame: frame)
        bindData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    override func setupLayout() {
        backgroundColor = .clear

        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func bindData() {
        collectionView.rx.modelSelected(Book.self)      // 컬렉션 셀 선택
            .map { .selectedBook($0) }
            .bind(to: actionTriggers)
            .disposed(by: disposeBag)
    }
    
    @discardableResult
    func setupDI(book: Observable<[Book]>) -> Self {
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)

        book.bind(to: collectionView.rx.items(cellIdentifier: NewBooksCell.identifier, cellType: NewBooksCell.self)) { [weak self] row, book, cell in
            guard let `self` = self else { return }
            cell.setupDI(action: self.actionTriggers)
            cell.setupRequest(with: book)
        }.disposed(by: disposeBag)

        return self
    }

    /// 유저 액션
    @discardableResult
    func setupDI(action: PublishRelay<NewBooksTriggerType>) -> Self {
        actionTriggers
            .bind(to: action)
            .disposed(by: disposeBag)

        return self
    }
}

extension NewBooksView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width, height: 265)
    }
}
