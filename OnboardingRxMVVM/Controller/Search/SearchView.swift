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
    private var actionTriggers: PublishRelay<SearchTriggerType> = PublishRelay<SearchTriggerType>()
    
    // MARK: - View

    let flowLayout = UICollectionViewFlowLayout()

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
        $0.backgroundColor = .clear
        $0.keyboardDismissMode = .onDrag
        $0.register(SearchViewCell.self, forCellWithReuseIdentifier: SearchViewCell.identifier)
        $0.register(SearchResultsCell.self, forCellWithReuseIdentifier: SearchResultsCell.identifier)
    }

    /// 검색할때 사용하는 서치 컨트롤러
    lazy var searchController = UISearchController(searchResultsController: nil).then {
        $0.searchBar.placeholder = R.SearchViewTextMessage.enterSearchQuery
        $0.obscuresBackgroundDuringPresentation = false
        $0.searchBar.setupKeyboardToolbar()
        $0.searchResultsUpdater = self
    }
    
    /// 키보드 Dismiss 가짜뷰
    lazy var fakeView = UIView().then {
        $0.backgroundColor = .clear
        $0.frame = searchController.view.frame
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        bindData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    override func setupLayout() {
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func bindData() {
        searchController.searchBar.rx.text          // 서치바 텍스트 변경
            .orEmpty
            .debounce(.milliseconds(350), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map { .searchQuery($0) }
            .bind(to: actionTriggers)
            .disposed(by: disposeBag)

        collectionView.rx.modelSelected(Book.self)  // 컬렉션 셀 선택
            .map { .selectedBook($0) }
            .bind(to: actionTriggers)
            .disposed(by: disposeBag)

        mode.distinctUntilChanged()                 // 모드 변경
            .map { .modeState($0) }
            .bind(to: actionTriggers)
            .disposed(by: disposeBag)

        collectionView.rx.didScroll                 // 컬렉션 뷰 스크롤 감지
            .throttle(.milliseconds(750), scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] in
            guard let `self` = self else { return }

            let offSetY = self.collectionView.contentOffset.y
            let contentHeight = self.collectionView.contentSize.height
            if offSetY > (contentHeight - self.collectionView.frame.size.height) {
                if self.mode.value == .search {
                    self.actionTriggers.accept(.isLoadMore(true))
                }
            }
        }).disposed(by: disposeBag)

        searchController.searchBar.rx.cancelButtonClicked
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.actionTriggers.accept(.cancelled)
        }).disposed(by: disposeBag)
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

                if self.mode.value == .onboarding {
                    /// 온보딩 셀로 보여줌
                    let searchViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchViewCell.identifier, for: IndexPath(item: index, section: 0)) as? SearchViewCell ?? SearchViewCell()
                    self.flowLayout.minimumLineSpacing = 20
                    searchViewCell.setupRequest(with: book)
                    searchViewCell.setupDI(action: self.actionTriggers, urlString: book.url)
                    return searchViewCell
                } else {
                    /// 서치 셀로 보여줌
                    let searchResultsCell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchResultsCell.identifier, for: IndexPath(item: index, section: 0)) as? SearchResultsCell ?? SearchResultsCell()
                    self.flowLayout.minimumLineSpacing = 5
                    searchResultsCell.setupRequest(with: book)
                    return searchResultsCell
                }
            }.disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)

        return self
    }
    
    @discardableResult
    func setupDI(isEmptyBook: PublishRelay<Bool>) -> Self {
        let tap = UITapGestureRecognizer()
        fakeView.addGestureRecognizer(tap)
        
        isEmptyBook.bind(onNext: { [weak self] bool in
            guard let `self` = self else { return }
            self.fakeView.isHidden = bool

            if !bool {              // bool == false == 값이 없음
                self.searchController.view.addSubview(self.fakeView)
            } else {                // bool == true == 값이 있음
                self.fakeView.removeFromSuperview()
            }
        }).disposed(by: disposeBag)
        
        tap.rx.event
            .bind(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.searchController.searchBar.endEditing(true)
            }).disposed(by: self.disposeBag)
        
        return self
    }

    /// 액션 바인딩
    @discardableResult
    func setupDI(action: PublishRelay<SearchTriggerType>) -> Self {
        actionTriggers
            .bind(to: action)
            .disposed(by: disposeBag)

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
        let result = mode.value == .onboarding ? CGSize(width: frame.width, height: 255) : CGSize(width: frame.width, height: 160)
        return result
    }
}
