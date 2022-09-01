//
//  SearchViewModel.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

enum SearchTriggerType {
    /// 검색 쿼리문
    case searchQuery(String)
    /// 책 선택
    case selectedBook(Book)
    case modeState(Mode)
    case presentSafari(String?)

    /// 원시값 대신 사용하기 위함. 연관값과 원시값을 동시에 사용할 수 없기때문에.
    var index: Int {
        switch self {
        case .searchQuery(_): return 0
        case .selectedBook(_): return 1
        case .modeState(_): return 2
        case .presentSafari(_): return 3
        }
    }
}

enum Mode {
    /// 검색하지 않은 최초 상태거나, 검색 도중 검색어를 삭제했을 떄
    case onboarding
    /// 검색모드
    case search
}

class SearchViewModel: ViewModelType {

    // MARK: - ViewModelType Protocol

    typealias ViewModel = SearchViewModel

    private var disposeBag: DisposeBag = DisposeBag()

    /// collectionView에 뿌려줄 데이터 리스트
    private var booksRelay: PublishRelay<[Book]> = PublishRelay<[Book]>()
    private var detailBookRelay: PublishRelay<Book> = PublishRelay<Book>()

    /// Paging 처리에 필요한 전역 프로퍼티
    private var page: Int = 1

    let modeState = BehaviorRelay<Mode>(value: .onboarding)

    private let apiService: APIService

    init(apiService: APIService) {
        self.apiService = apiService
    }

    struct Input {
        let viewDidLoaded: Observable<Void>
        let action: PublishRelay<SearchTriggerType>
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

    func actionTriggerRequest(trigger: SearchTriggerType) {
        switch trigger {
        case .searchQuery(let query):
            self.fetchSearchBooks(query)
        case .selectedBook(let book):
            if let isbn13 = book.isbn13 {
                self.fetchDetailBook(isbn13)
            }
        case .modeState(let state):
            print("모드 상태: \(state)")
            if state == .onboarding {
                self.fetchNewBooks()
            } else {
                self.fetchSearchBooks("")
            }
            modeState.accept(state)
        default:
            break
        }
    }
}

extension SearchViewModel {
    private func fetchNewBooks() {
        let result: Single<BookResponse> = self.apiService.fetchNewBooks()

        result.subscribe { [weak self] state in
            guard let `self` = self else { return }
            switch state {
            case .success(let response):
                if let books = response.books {
                    self.booksRelay.accept(books)
                }
            case .failure(_):
                print(R.SearchViewTextMessage.failListMessage)
            }
        }.disposed(by: disposeBag)
    }

    private func fetchSearchBooks(_ query: String) {
        let result: Single<BookResponse> = self.apiService.fetchSearchBooks(query: query, page: page)

        result.subscribe { [weak self] state in
            guard let `self` = self else { return }
            switch state {
            case .success(let response):
                // book에 모드값 판별해서
                if let book = response.books {
                    guard let page = response.page else { return }
                    self.page = Int(page) ?? 1
                    self.booksRelay.accept(book)
                } else {
                    print(R.SearchViewTextMessage.failListMessage)
                    self.booksRelay.accept([])
                }

            case .failure(_):
                print(R.SearchViewTextMessage.noSearchRequestMessage)
            }
        }.disposed(by: disposeBag)
    }

    private func fetchDetailBook(_ isbn13: String?) {
        guard let isbn13 = isbn13 else { return }
        let result: Single<Book> = self.apiService.fetchDetailBook(isbn13: isbn13)

        result
            .subscribe { [weak self] state in
            guard let `self` = self else { return }
            switch state {
            case .success(let book):
                self.detailBookRelay.accept(book)
            case .failure(_):
                print(R.SearchViewTextMessage.failDetailMessage)
            }
        }.disposed(by: disposeBag)
    }
}
