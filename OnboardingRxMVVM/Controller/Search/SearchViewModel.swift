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
    case searchState(Bool)
    case cancelled

    /// 원시값 대신 사용하기 위함. 연관값과 원시값을 동시에 사용할 수 없기때문에.
    var index: Int {
        switch self {
        case .searchQuery(_): return 0
        case .selectedBook(_): return 1
        case .modeState(_): return 2
        case .presentSafari(_): return 3
        case .isLoadMore(_): return 4
        case .searchState(_): return 5
        case .cancelled: return 6
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

    /// Paging 처리에 필요한 전역 프로퍼티
    private var page = BehaviorRelay<Int>(value: 1)
    /// 마지막 페이지
    private var endPage: Int = 0
    /// 검색 쿼리문
    private var query = BehaviorRelay<String>(value: "")
    /// 더보기 했을 때 나오는 책 리스트
    private var moreBooksList: BehaviorRelay<[Book]> = BehaviorRelay<[Book]>(value: [])
    /// 더보기 여부
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
    }

    func transform(req: ViewModel.Input) -> ViewModel.Output {
        req.viewDidLoaded
            .subscribe(onNext: fetchNewBooks)
            .disposed(by: disposeBag)

        req.action
            .subscribe(onNext: actionTriggerRequest)
            .disposed(by: disposeBag)

        return Output(booksRelay: booksRelay.asObservable())
    }

    func actionTriggerRequest(trigger: SearchTriggerType) {
        switch trigger {
        case .searchQuery(let query):
            self.query.accept(query)
            print(self.query.value)
            print(query)
        case .modeState(let state):
            if state == .onboarding {
                /// 온보딩 상태
                fetchNewBooks()
            } else {
                /// 검색 상태
                query.subscribe(onNext: { [weak self] query in
                    guard let `self` = self else { return }
                    self.booksRelay.accept([])
                    self.fetchSearchBooks(query, page: self.page.value)
                }).disposed(by: disposeBag)
            }
            modeState.accept(state)
        case .isLoadMore(let state):
            let value = page.value
            self.isLoadMore.accept(state)

            if !query.value.isEmpty && booksRelay.value.count != 0 {
                if isLoadMore.value {
                    isLoadMore.accept(false)
                    if 1 <= page.value && page.value < endPage {
                        page.accept(value + 1)
                        
                        fetchSearchBooks(query.value, page: page.value)
                    }
                }
            }
        case .cancelled:
            query.accept("")
            resetProperties()

        default: break
        }
    }
    
    private func resetProperties() {
        booksRelay.accept([])
        page.accept(1)
        endPage = 0
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
                        var booksValue: [Book] = []
                        if self.page.value > 1 {
                            booksValue = self.booksRelay.value
                        }

                        self.moreBooksList.accept(book)
                        booksValue.append(contentsOf: self.moreBooksList.value)
                        self.booksRelay.accept(booksValue)

                    } else if self.page.value == endPage {
                        Toast.shared.showToast(R.SearchViewTextMessage.finalPage)
                    }
                } else {
                    Toast.shared.showToast(R.SearchViewTextMessage.failListMessage)
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
