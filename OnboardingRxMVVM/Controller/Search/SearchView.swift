//
//  SearchView.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class SearchView: UIBaseView {

    // MARK: - Model type implemente
    typealias Model = Void

    private var mode: BehaviorRelay<Mode> = BehaviorRelay<Mode>(value: .onboarding)

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
        $0.delegate = self
    }

    // MARK: - Methods

    override func setupLayout() {
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // MARK: - Dependency Injection

    func setupDI<T>(observable: Observable<T>) -> Self {
        if let books = observable as? Observable<[Book]> {
            // TODO: 여기서 분기처리해서 온보딩 상태의 셀과 서치 상태의 셀을 구분해서 보여줘야하는데 어떻게 할까 그걸
            books.bind(to: collectionView.rx.items) { [weak self] collectionView, index, book -> UICollectionViewCell in
                guard let `self` = self else { return UICollectionViewCell() }
                if self.mode.value == .onboarding {
                    let searchViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchViewCell.identifier, for: IndexPath(item: index, section: 0)) as? SearchViewCell ?? SearchViewCell()
                    searchViewCell.setupRequest(with: book)
                    return searchViewCell
                } else {
                    let searchResultsCell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultsCell.identifier, for: IndexPath(item: index, section: 0)) as? SearchResultsCell ?? SearchResultsCell()
                    searchResultsCell.setupRequest(with: book)
                    return searchResultsCell
                }
            }.disposed(by: disposeBag)
        } else {
            NSLog("Occured error in Search DI")
        }

        return self
    }

    /// @discardableResult를 명시해 Xcode 경고 피함
    @discardableResult
    /// 사용자의 인터랙션
    func setupDI<T>(genericT: PublishRelay<T>) -> Self {
        if let searchQuery = genericT as? PublishRelay<SearchTriggerType> {
            searchController.searchBar.rx.text
                .orEmpty
                .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
                .distinctUntilChanged()
                .map { .searchQuery($0) }
                .bind(to: searchQuery)
                .disposed(by: disposeBag)

            collectionView.rx.modelSelected(Book.self)
                .map { .selectedBook($0) }
                .bind(to: searchQuery)
                .disposed(by: disposeBag)
        } else {
            NSLog("Occured error in Search DI")
        }

        return self
    }
}

/*
 
 self.searchBooks.asObservable()
     .bind(to: self.subView.collectionView.rx.items) { collectionView, index, book -> UICollectionViewCell in
         
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultsCell.identifier, for: IndexPath(item: index, section: 0)) as? SearchResultsCell ?? SearchResultsCell()
         cell.setupRequest(with: book)
         return cell
 }.disposed(by: self.disposeBag)
 */

extension SearchView: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        mode.accept(.search)
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        mode.accept(.onboarding)
    }
}
