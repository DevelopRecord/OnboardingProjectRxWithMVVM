//
//  SearchViewController.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

class SearchViewController: UIBaseViewController {

    typealias ViewModel = SearchViewModel

    // MARK: - ViewModelProtocol

    var viewModel: ViewModel!

    // MARK: - Properties
    
    private var requestTrigger: PublishRelay<Void> = PublishRelay<Void>()
    private var actionTriggers: PublishRelay<SearchTriggerType> = PublishRelay<SearchTriggerType>()

    /// 검색한 책 리스트
    private var searchBooks: PublishRelay<[Book]> = PublishRelay<[Book]>()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bindingViewModel()

        requestTrigger.accept(())
    }

    // MARK: - Binding
    func bindingViewModel() {
        let response = viewModel.transform(req: ViewModel.Input(
                                            viewDidLoaded: requestTrigger.asObservable(),
                                            action: actionTriggers))

        /// bindingViewModel 메서드 안의 이 아래의 subView 관련 코드들은 모두 DI 해줘야함. 안하면 subView를 만든 의미가 없음. 일단 동작부터 하게하고 이후에 리팩토링하자. 하려면 subView의 setupDI() 메서드 만들고 그 안에서 처리해야할듯.
        self.subView.collectionView.rx.setDelegate(self).disposed(by: self.disposeBag)
        
        subView
            .setupDI(observable: response.booksRelay)
            .setupDI(genericT: actionTriggers)
        
        response.detailBookRelay
            .subscribe(onNext: { [weak self] book in
                guard let `self` = self else { return }
                let controller = DetailBookViewController()
                controller.setupRequest(with: book)
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
        }).disposed(by: disposeBag)

    }

    // MARK: - View
    let subView = SearchView()

    override func setupLayout() {
        view.backgroundColor = .systemBackground
        setupNavigationBar(title: R.SearchViewTextMessage.searchBooks, isLargeTitle: true, searchController: subView.searchController)
        subView.searchController.searchResultsUpdater = self

        self.view.addSubview(subView)
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension SearchViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive {
            subView.collectionView.backgroundView = nil
        } else {
            subView.collectionView.backgroundView = SearchPlaceholderView()
        }
    }
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: view.frame.width, height: 255)
        } else {
            return CGSize(width: view.frame.width, height: 75)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    
}
