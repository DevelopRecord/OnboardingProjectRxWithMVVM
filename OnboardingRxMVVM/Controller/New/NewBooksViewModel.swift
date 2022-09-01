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
    case selectedBook(Book)
    case presentSafari(String?)
    
    var index: Int {
        switch self {
        case .selectedBook(_): return 0
        case .presentSafari(_): return 1
        }
    }
}

class NewBooksViewModel: ViewModelType {

    // MARK: - ViewModelType Protocol

    typealias ViewModel = NewBooksViewModel

    private var disposeBag: DisposeBag = DisposeBag()
    private var booksRelay: PublishRelay<[Book]> = PublishRelay<[Book]>()
    private var detailBookRelay: PublishRelay<Book> = PublishRelay<Book>()

    private let apiService: APIService

    init(apiService: APIService) {
        self.apiService = apiService
    }

    struct Input {
        let viewDidLoaded: Observable<Void>
        let action: PublishRelay<NewBooksTriggerType>
    }

    struct Output {
        let booksRelay: Observable<[Book]>
        let detailBookRelay: PublishRelay<Book>
    }

    func transform(req: ViewModel.Input) -> ViewModel.Output {
        req.viewDidLoaded
            .subscribe(onNext: fetchNewBooks)
            .disposed(by: disposeBag)

        req.action
            .subscribe(onNext: actionTriggerRequest)
            .disposed(by: disposeBag)

        return Output(booksRelay: booksRelay.asObservable(), detailBookRelay: detailBookRelay)
    }

    func actionTriggerRequest(action: NewBooksTriggerType) {
        switch action {
        case .selectedBook(let book):
            if let isbn13 = book.isbn13 {
                self.fetchDetailBook(isbn13: isbn13)
            }
        default:
            break
        }
    }
}

extension NewBooksViewModel {
    private func fetchNewBooks() {
        let result: Single<BookResponse> = self.apiService.fetchNewBooks()

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

    private func fetchDetailBook(isbn13: String?) {
        guard let isbn13 = isbn13 else { return }
        let result: Single<Book> = self.apiService.fetchDetailBook(isbn13: isbn13)

        result.subscribe({ [weak self] state in
            switch state {
            case .success(let book):
                self?.detailBookRelay.accept(book)
            case .failure(_):
                Toast.shared.showToast(R.NewBooksTextMessage.failDetailMessage)
            }
        }).disposed(by: disposeBag)
    }
}
