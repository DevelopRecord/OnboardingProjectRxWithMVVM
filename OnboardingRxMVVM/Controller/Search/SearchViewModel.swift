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

enum Mode {
    /// 검색하지 않은 최초 상태거나, 검색 도중 검색어를 삭제했을 떄
    case onboarding
    /// 검색모드
    case search
}

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
    /// 취소 버튼
    case cancelled
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
    /// 사파리 URL
    private let presentSafari = PublishRelay<URL>()
    /// 선택한 책 ISBN13
    private let pushSelectedBook = PublishRelay<String?>()
    /// 모드 상태
    private let modeState = PublishRelay<Mode>()
    /// 책 리스트 유무
    private var isEmptyBookList = PublishRelay<Bool>()
    /// 아웃풋 요청 타입
    private var outputRequest = PublishRelay<OutputRequestType>()

    struct Input {
        let viewDidLoaded: Observable<Void>
        let action: PublishRelay<SearchTriggerType>
    }

    struct Output {
        let booksRelay: Observable<[Book]>
        let isEmptyBookList: PublishRelay<Bool>
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
                      isEmptyBookList: isEmptyBookList,
                      outputRequest: outputRequest)
    }

    func actionTriggerRequest(trigger: SearchTriggerType) {
        switch trigger {
        case .searchQuery(let query):
            self.query.accept(query)
        case .modeState(let state):
            if state == .onboarding {       // 온보딩 상태
                fetchNewBooks()
                isEmptyBookList.accept(booksRelay.value.isEmpty ? false : true)
            } else {                        // 검색 상태
                query
                    .withUnretained(self)
                    .subscribe(onNext: { owner, text in
                        owner.booksRelay.accept([])
                        owner.fetchSearchBooks(text, page: owner.page.value)
                }).disposed(by: disposeBag)
                isEmptyBookList.accept(booksRelay.value.isEmpty ? false : true)
            }
            modeState.accept(state)
        case .isLoadMore(let state):
            let value = page.value
            isLoadMore.accept(state)

            if !query.value.isEmpty && booksRelay.value.count != 0 {
                if isLoadMore.value {
                    if 1 <= page.value && page.value < endPage {
                        page.accept(value + 1)
                        fetchSearchBooks(query.value, page: page.value)
                        isEmptyBookList.accept(booksRelay.value.isEmpty ? false : true)
                    }
                }
            }
        case .cancelled:
            query.accept("")
            resetProperties()
            self.isEmptyBookList.accept(true)
        case .selectedBook(let book):
            outputRequest.accept(.pushSelectedBook(book.isbn13))
        case .presentSafari(let str):
            guard let urlString = str, let url = URL(string: urlString) else { return }
            outputRequest.accept(.presentSafari(url))
        }
    }
    
    /// 프로퍼티 리셋
    private func resetProperties() {
        booksRelay.accept([])
        page.accept(1)
        endPage = 0
    }
}

extension SearchViewModel {
    private func fetchNewBooks() {
        let result: Single<BookResponse> = APIService.shared.fetchNewBooks()

        result.subscribe { [weak self] state in
            guard let `self` = self else { return }
            switch state {
            case .success(let response):
                if let books = response.books {
                    self.booksRelay.accept(books)
                    self.isEmptyBookList.accept(books.isEmpty ? false : true)
                }
            case .failure(_):
                Toast.shared.showToast(R.SearchViewTextMessage.failListMessage)
            }
        }.disposed(by: disposeBag)
    }

    private func fetchSearchBooks(_ query: String, page: Int) {
        let result: Single<BookResponse> = APIService.shared.fetchSearchBooks(query: query, page: page)

        result.subscribe { [weak self] state in
            guard let `self` = self else { return }
            switch state {
            case .success(let response):
                if let book = response.books {
                    self.isEmptyBookList.accept(book.isEmpty ? false : true)
                    /// 책 리스트 개수
                    guard let total = response.total else { return }
                    /// 마지막 페이지
                    let endPage = self.getEndPage(total)
                    self.endPage = endPage

                    if 1 <= self.page.value && self.page.value < endPage {
                        var booksValue: [Book] = self.booksRelay.value
                        booksValue.append(contentsOf: book)
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

extension SearchViewModel {
    /// 아웃풋 요청 타입
    enum OutputRequestType {
        case presentSafari(URL)
        case pushSelectedBook(String?)
    }
}
