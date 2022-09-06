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
    /// 모드 상태
    case modeState(Mode)
    /// 사파리 URL 주소
    case presentSafari(String?)
    /// 더보기
    case isLoadMore(Bool)

    /// 원시값 대신 사용하기 위함. 연관값과 원시값을 동시에 사용할 수 없기때문에.
    var index: Int {
        switch self {
        case .searchQuery(_): return 0
        case .selectedBook(_): return 1
        case .modeState(_): return 2
        case .presentSafari(_): return 3
        case .isLoadMore(_): return 4
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
    private var booksRelay: BehaviorRelay<[Book]> = BehaviorRelay<[Book]>(value: [])
    private var detailBookRelay: PublishRelay<Book> = PublishRelay<Book>()

    /// Paging 처리에 필요한 전역 프로퍼티
    private var page = BehaviorRelay<Int>(value: 1)
    private var endPage: Int = 0
    private var query = BehaviorRelay<String>(value: "")
    private var moreBooksList: BehaviorRelay<[Book]> = BehaviorRelay<[Book]>(value: [])
    private var isLoadMore: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)

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
            self.query.accept(query)
            if !self.query.value.isEmpty {
                fetchSearchBooks(self.query.value, page: page.value)
            }
        case .selectedBook(_):
            print("searchViewModel selectedBook")
        case .modeState(let state):
            print("상태: \(state)")
            if state == .onboarding {
                booksRelay.accept([])
                fetchNewBooks()
            } else if state == .search {
                if query.value.isEmpty {
                    booksRelay.accept([])
                } else {
                    fetchSearchBooks(query.value, page: page.value)
                }
            }
            modeState.accept(state)
        case .isLoadMore(let state):
            let value = page.value // 1
            self.isLoadMore.accept(state)

            if isLoadMore.value {
                isLoadMore.accept(false)
                if 1 <= page.value && page.value < endPage {
                    page.accept(value + 1)
                    fetchSearchBooks(query.value, page: page.value)
                    isLoadMore.accept(true)
                }
            }
        case .presentSafari(_): break
        }
    }
}

extension SearchViewModel {
    private func fetchNewBooks() {
        let result: Single<BookResponse> = apiService.fetchNewBooks()

        result.subscribe { [weak self] state in
            guard let `self` = self else { return }
            switch state {
            case .success(let response):
                if let books = response.books {
                    self.booksRelay.accept(books)
                }
            case .failure(_):
                Toast.shared.showToast(R.SearchViewTextMessage.failListMessage)
            }
        }.disposed(by: disposeBag)
    }

    private func fetchSearchBooks(_ query: String, page: Int) {
        let result: Single<BookResponse> = apiService.fetchSearchBooks(query: query, page: page)

        result.subscribe { [weak self] state in
            guard let `self` = self else { return }
            switch state {
            case .success(let response):
                if let book = response.books {
                    /// 책 리스트 개수
                    guard let total = response.total else { return }
                    /// 마지막 페이지
                    let endPage = self.getEndPage(total)
                    self.endPage = endPage

                    if 1 <= self.page.value && self.page.value < endPage {
                        var booksValue = self.booksRelay.value
                        print("카운트: \(booksValue.count)")
                        self.moreBooksList.accept(book)
                        booksValue.append(contentsOf: self.moreBooksList.value)
                        self.booksRelay.accept(booksValue)

                    } else if self.page.value == endPage {
                        print("마지막 페이지")
                    }

                    print("페이지: \(self.page.value), 토탈카운트: \(response.total), 끝페이지: \(endPage)")
                } else {
                    Toast.shared.showToast(R.SearchViewTextMessage.failListMessage)
                    self.booksRelay.accept([])
                }

            case .failure(_):
                Toast.shared.showToast(R.SearchViewTextMessage.noSearchRequestMessage)
            }
        }.disposed(by: disposeBag)
    }

    /// endPage를 구하기 위한 메서드
    private func getEndPage(_ total: String) -> Int {
        return Int(ceil(Double(total)! / 10.0))
    }
}
