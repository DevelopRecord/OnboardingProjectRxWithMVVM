//
//  NewBooksViewModel.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

enum NewBooksTriggerType {
    case viewLoadedTrigger
    case selectedBookTrigger
}

class NewBooksViewModel: ViewModelType {

    // MARK: - ViewModelType Protocol

    typealias ViewModel = NewBooksViewModel

    private var disposeBag: DisposeBag = DisposeBag()
    private var newBookRelay: PublishRelay<BookResponse> = PublishRelay<BookResponse>()
    private var selectedBook: PublishRelay<Book> = PublishRelay<Book>()
    private var isbn13: String = String()

    private let apiService: APIService

    init(apiService: APIService) {
        self.apiService = apiService
    }

    struct Input {
        let actionTrigger: PublishRelay<Void>

        /// 나중에 Input 액션 리팩토링 할 때 사용
//        let action: Observable<NewBooksTriggerType>
    }

    struct Output {
        let newBookRelay: PublishRelay<BookResponse>
    }

    func transform(req: ViewModel.Input) -> ViewModel.Output {
        req.actionTrigger
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.fetchNewBooks()
        }).disposed(by: disposeBag)

        return Output(newBookRelay: newBookRelay)
    }

    func actionTriggerRequest(action: NewBooksTriggerType) {
        switch action {
        case .viewLoadedTrigger:
            self.fetchNewBooks()
        case .selectedBookTrigger:
            self.fetchDetailBook()
        }
    }
}

extension NewBooksViewModel {
    private func fetchNewBooks() {
        self.apiService.fetchNewBooks()
            .subscribe(onSuccess: { [weak self] response in
                guard let `self` = self else { return }
                self.newBookRelay.accept(response)
        }, onFailure: { error in
                print(R.NewBooksTextMessage.failListMessage)
            }).disposed(by: disposeBag)
    }

    private func fetchDetailBook() {
        self.apiService.fetchDetailBook(isbn13: isbn13)
            .subscribe(onSuccess: { [weak self] response in
                guard let `self` = self else { return }
                self.selectedBook.accept(response)
        }, onFailure: { error in
                print(R.NewBooksTextMessage.failDetailMessage)
            }).disposed(by: disposeBag)
    }
}
