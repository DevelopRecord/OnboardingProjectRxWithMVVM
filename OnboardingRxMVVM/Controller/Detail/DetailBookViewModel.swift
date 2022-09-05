//
//  DetailBookViewModel.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DetailBookViewModel: ViewModelType {
    
    // MARK: - ViewModelType Protocol
    typealias ViewModel = DetailBookViewModel
    
    private var disposeBag: DisposeBag = DisposeBag()

    /// collectionView에 뿌려줄 데이터 리스트
    private var booksRelay: BehaviorRelay<Book> = BehaviorRelay<Book>(value: Book(title: "", subtitle: "", isbn13: "", price: "", image: "", url: ""))
    /// VC로부터 받아온 고유번호(isbn13)
    private var isbn13: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
    
    private let apiService: APIService

    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    struct Input {
        let action: Observable<Void>
        let isbn13: BehaviorRelay<String?>
    }
    
    struct Output {
        let booksRelay: Observable<Book>
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        isbn13.accept(req.isbn13.value)
        
        req.action
            .subscribe(onNext: fetchDetailBook)
            .disposed(by: disposeBag)
        
        return Output(booksRelay: booksRelay.asObservable())
    }
}

extension DetailBookViewModel {
    private func fetchDetailBook() {
        guard let isbn13 = isbn13.value else { return }
        let result: Single<Book> = apiService.fetchDetailBook(isbn13: isbn13)

        result.subscribe { [weak self] state in
            guard let `self` = self else { return }
            switch state {
            case .success(let response):
                self.booksRelay.accept(response)
            case .failure(_):
                Toast.shared.showToast(R.DetailBookTextMessage.failDetailMessage)
            }
        }.disposed(by: disposeBag)
    }
}
