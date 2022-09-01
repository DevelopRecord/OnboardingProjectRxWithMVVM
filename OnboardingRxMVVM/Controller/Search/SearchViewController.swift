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
    /// 검색한 책 리스트
    private var searchBooks: PublishRelay<[Book]> = PublishRelay<[Book]>()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        bindingViewModel()

        requestTrigger.accept(())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        urlBinding()
    }

    // MARK: - Binding
    func bindingViewModel() {
        let response = viewModel.transform(req: ViewModel.Input(
            viewDidLoaded: requestTrigger.asObservable(),
            action: actionTriggers))

        subView
            .setupDI(book: response.booksRelay)
            .setupDI(action: actionTriggers)
            .setupDI(relay: actionTriggers)

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

        self.view.addSubview(subView)
        subView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    /// 사파리 이동하기 위한 데이터 바인딩 메서드
    func urlBinding() {
        //        actionTriggers
        //            .subscribe(onNext: { [weak self] in
        //                guard let `self` = self else { return }
        //                if case SearchTriggerType.presentSafari(let urlString) = $0 {
        //                    guard let urlString = urlString, let url = URL(string: urlString) else { return }
        //                    let safariViewController = SFSafariViewController(url: url)
        //                    self.present(safariViewController, animated: true)
        //                }
        //            }).disposed(by: disposeBag)

        actionTriggers
            .filter { $0.index == 3 }
            .subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            switch $0 {
            case .presentSafari(let urlString):
                guard let urlString = urlString, let url = URL(string: urlString) else { return }
                let safariViewController = SFSafariViewController(url: url)
                self.present(safariViewController, animated: true)
            default:
                break
            }
        }).disposed(by: disposeBag)
    }
}
