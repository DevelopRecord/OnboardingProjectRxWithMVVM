//
//  SearchView.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import SafariServices

import SnapKit
import Then
import RxSwift
import RxCocoa

class SearchView: UIBaseView {

    var disposeBag: DisposeBag = DisposeBag()

    /// 온보딩, 서치 상태 관찰 프로퍼티
    private var mode: BehaviorRelay<Mode> = BehaviorRelay<Mode>(value: .onboarding)

    /// 사용자의 액션을 담는 데이터 요청 트리거
    private var action: PublishRelay<SearchTriggerType> = PublishRelay<SearchTriggerType>()

    // MARK: - View

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .clear
        $0.keyboardDismissMode = .onDrag
        $0.register(SearchViewCell.self, forCellWithReuseIdentifier: SearchViewCell.identifier)
        $0.register(SearchResultsCell.self, forCellWithReuseIdentifier: SearchResultsCell.identifier)
        $0.register(LoadingCell.self, forCellWithReuseIdentifier: LoadingCell.identifier)
    }

    /// 검색할때 사용하는 서치 컨트롤러
    lazy var searchController = UISearchController(searchResultsController: nil).then {
        $0.searchBar.placeholder = R.SearchViewTextMessage.enterSearchQuery
        $0.obscuresBackgroundDuringPresentation = false
        $0.becomeFirstResponder()
        $0.searchResultsUpdater = self
    }

    // MARK: - Methods

    override func setupLayout() {
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // MARK: - Dependency Injection
    /// 컬렉션뷰에 바인딩
    @discardableResult
    func setupDI(book: Observable<[Book]>) -> Self {
        self.mode.subscribe(onNext: { [weak self] state in
            guard let `self` = self else { return }
            self.collectionView.delegate = nil
            self.collectionView.dataSource = nil
            self.collectionView.rx.setDelegate(self).disposed(by: self.disposeBag)

            book.bind(to: self.collectionView.rx.items) { [weak self] collectionView, index, book -> UICollectionViewCell in
                guard let `self` = self else { return UICollectionViewCell() }

                if state == .onboarding {
                    /// 온보딩 셀로 보여줌
                    let searchViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchViewCell.identifier, for: IndexPath(item: index, section: 0)) as? SearchViewCell ?? SearchViewCell()
                    searchViewCell.linkButton.rx.tap
                        .map { _ in
                        print(book.title, book.url)
                        return SearchTriggerType.presentSafari(book.url)
                    }
                        .bind(to: self.action)
                        .disposed(by: searchViewCell.disposeBag)
                    searchViewCell.setupRequest(with: book)
                    return searchViewCell
                } else {
                    /// 서치 셀로 보여줌
                    print("서치 책정보22: \(book.title)")
                    if self.mode.value == .search && book.title == "" {
                        collectionView.backgroundView = SearchPlaceholderView()
                    }
                    let searchResultsCell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultsCell.identifier, for: IndexPath(item: index, section: 0)) as? SearchResultsCell ?? SearchResultsCell()
                    searchResultsCell.setupRequest(with: book)
                    print("서치 책정보2: \(book)")
                    return searchResultsCell
                }
            }.disposed(by: self.disposeBag)

        }).disposed(by: disposeBag)

        return self
    }

    /// @discardableResult를 명시해 버릴수 있다고 알리고 Xcode 경고 피함
    /// 사용자의 인터랙션
    @discardableResult
    func setupDI(action: PublishRelay<SearchTriggerType>) -> Self {
        searchController.searchBar.rx.text
            .orEmpty
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { .searchQuery($0) }
            .bind(to: action)
            .disposed(by: disposeBag)

        collectionView.rx.modelSelected(Book.self)
            .map { .selectedBook($0) }
            .bind(to: action)
            .disposed(by: disposeBag)

        mode
            .distinctUntilChanged()
            .map { .modeState($0) }
            .bind(to: action)
            .disposed(by: disposeBag)

        return self
    }

    /// 사파리 유저 액션
    @discardableResult
    func setupDI(relay: PublishRelay<SearchTriggerType>) -> Self {
        action.bind(to: relay).disposed(by: disposeBag)
        return self
    }
}

extension SearchView: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive {
            mode.accept(.search)
        } else if !searchController.isActive {
            mode.accept(.onboarding)
        }
    }
}

extension SearchView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            let result = mode.value == .onboarding ? CGSize(width: frame.width, height: 255) : CGSize(width: frame.width, height: 160)
            return result
        } else {
            return CGSize(width: frame.width, height: 75)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
}
