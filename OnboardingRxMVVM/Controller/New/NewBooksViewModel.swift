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

/// 액션 트리거 타입
enum NewBooksTriggerType {
    /// 책 선택
    case selectedBook(Book)
    /// 사파리 이동
    case presentSafari(String?)
}

class NewBooksViewModel: ViewModelType {

    // MARK: - ViewModelType Protocol

    typealias ViewModel = NewBooksViewModel

    private var disposeBag: DisposeBag = DisposeBag()
    /// 책 리스트
    private var booksRelay: PublishRelay<[Book]> = PublishRelay<[Book]>()
    /// 사파리 이동 URL
    private var presentSafari = PublishRelay<URL>()
    /// 선택한 책 ISBN13
    private var pushSelectedBook = PublishRelay<String?>()
    /// 아웃풋 요청 타입
    private var outputRequest = PublishRelay<OutputRequestType>()

    struct Input {
        let viewDidLoaded: Observable<Void>
        let action: PublishRelay<NewBooksTriggerType>
    }

    struct Output {
        let booksRelay: Observable<[Book]>
        let outputRequest: PublishRelay<OutputRequestType>
    }

    func transform(req: ViewModel.Input) -> ViewModel.Output {
        req.viewDidLoaded
            .subscribe(onNext: fetchNewBooks)
            .disposed(by: disposeBag)

        req.action
            .subscribe(onNext: actionTriggerRequest)
            .disposed(by: disposeBag)

        return Output(booksRelay: booksRelay.asObservable(),
                      outputRequest: outputRequest)
    }

    func actionTriggerRequest(action: NewBooksTriggerType) {
        switch action {
        case .selectedBook(let book):
            outputRequest.accept(.pushSelectedBook(book.isbn13))
        case .presentSafari(let urlString):
            guard let urlString = urlString, let url = URL(string: urlString) else { return }
            outputRequest.accept(.presentSafari(url))
        }
    }
}

extension NewBooksViewModel {
    private func fetchNewBooks() {
        let result: Single<BookResponse> = APIService.shared.fetchNewBooks()

        result.subscribe({ [weak self] state in
            guard let `self` = self else { return }
            switch state {
            case .success(let bookResponse):
                if let book = bookResponse.books {
                    self.booksRelay.accept(book)
                }
            case .failure(_):
                Toast.shared.showToast(R.NewBooksTextMessage.failListMessage)
            }
        }).disposed(by: disposeBag)
    }
}

extension NewBooksViewModel {
    /// 아웃풋 요청 타입
    enum OutputRequestType {
        case presentSafari(URL)
        case pushSelectedBook(String?)
    }
}
