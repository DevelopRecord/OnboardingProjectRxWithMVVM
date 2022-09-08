//
//  SearchViewController.swift
//  OnboardingRxMVVM
//
//  Created by 이재혁 on 2022/08/24.
//  Copyright (c) 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import SafariServices

import RxSwift
import RxCocoa
import SnapKit
import Then

class SearchViewController: UIBaseViewController {

    typealias ViewModel = SearchViewModel

    // MARK: - ViewModelProtocol

    var viewModel: ViewModel!

    // MARK: - Properties

    var disposeBag: DisposeBag = DisposeBag()

    /// 뷰 로드되고 온보딩 상태의 데이터 요청 트리거
    private var requestTrigger: PublishRelay<Void> = PublishRelay<Void>()
    /// 사용자의 액션을 담는 데이터 요청 트리거
    private var actionTriggers: PublishRelay<SearchTriggerType> = PublishRelay<SearchTriggerType>()

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

        subView
            .setupDI(book: response.booksRelay)
            .setupDI(action: actionTriggers)
            .setupDI(isEmptyBook: response.isEmptyBookList)
        
        response.presentSafari          // 사파리 이동
            .subscribe(onNext: { [weak self] url in
                guard let `self` = self else { return }
                let safariViewController = SFSafariViewController(url: url)
                self.present(safariViewController, animated: true)
            }).disposed(by: disposeBag)
        
        response.pushSelectedBook       // 상세정보 이동
            .bind(onNext: { [weak self] isbn13 in
                guard let `self` = self else { return }
                guard let isbn13 = isbn13 else {
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                let controller = DetailBookViewController()
                controller.viewModel = DetailBookViewModel(isbn13: isbn13)
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            }).disposed(by: disposeBag)
    }

    // MARK: - View
    
    let subView = SearchView()

    override func setupLayout() {
        view.backgroundColor = .systemBackground
        setupNavigationBar(title: R.SearchViewTextMessage.searchBooks, isLargeTitle: true, searchController: subView.searchController)

        self.view.addSubview(subView)
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
