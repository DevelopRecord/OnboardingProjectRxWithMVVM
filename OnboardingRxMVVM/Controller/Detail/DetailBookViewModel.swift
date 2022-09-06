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

enum DetailTriggerType {
    /// TextView의 text
    case saveText(String?)
    
    case textViewMode(Bool)
    case textViewTextColor(UIColor)
    case refresh
}

class DetailBookViewModel: ViewModelType {
    
    // MARK: - ViewModelType Protocol
    typealias ViewModel = DetailBookViewModel
    
    private var disposeBag: DisposeBag = DisposeBag()

    /// collectionView에 뿌려줄 데이터 리스트
    private var booksRelay: BehaviorRelay<Book> = BehaviorRelay<Book>(value: Book(title: "", subtitle: "", isbn13: "", price: "", image: "", url: ""))
    /// VC로부터 받아온 고유번호(isbn13)
    private var isbn13: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
    /// UserDefaults 싱글톤
    private let userDefaults = UserDefaults.standard
    /// 저장될 text
    private var userDefaultsText: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
    /// APIService 싱글톤
    private let apiService: APIService

    init(apiService: APIService) {
        self.apiService = apiService
    }
    
    struct Input {
        let viewDidLoaded: Observable<Void>
        let action: PublishRelay<DetailTriggerType>
        let isbn13: BehaviorRelay<String?>
    }
    
    struct Output {
        let booksRelay: Observable<Book>
        let savedText: BehaviorRelay<String?>
    }
    
    func transform(req: ViewModel.Input) -> ViewModel.Output {
        isbn13.accept(req.isbn13.value)
        
        req.viewDidLoaded
            .subscribe(onNext: fetchDetailBook)
            .disposed(by: disposeBag)
        
        req.action
            .subscribe(onNext: actionTriggerRequest)
            .disposed(by: disposeBag)
        
        return Output(booksRelay: booksRelay.asObservable(), savedText: userDefaultsText)
    }
    
    func actionTriggerRequest(type: DetailTriggerType) {
        switch type {
        case .saveText(let text):
            userDefaultsText.accept(text)
        case .textViewMode(let bool):
            guard let isbn13 = isbn13.value else { return }
            if bool {
                /// 텍스트뷰 수정 시작했을 떄
//                userDefaultsText.accept(userDefaults.string(forKey: isbn13))
            } else {
                /// 텍스트뷰 수정 끝냈을때
                userDefaults.set(userDefaultsText.value, forKey: isbn13)
            }
        case .refresh:
            guard let isbn13 = isbn13.value else { return }
            userDefaultsText.accept(userDefaults.string(forKey: isbn13))
        default: break
        }
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
